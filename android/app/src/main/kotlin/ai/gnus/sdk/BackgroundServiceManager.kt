package ai.gnus.sdk

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import androidx.core.content.ContextCompat
import androidx.work.Constraints
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.BackoffPolicy
import androidx.work.OutOfQuotaPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkRequest
import java.util.concurrent.TimeUnit
import org.json.JSONObject

/**
 * Data class mirroring BackgroundConfig from C++ (background_config.h).
 *
 * Populated from nativeGetConfigJson() after nativeInit.
 * Default values match background_config.h brace-initialized defaults:
 *   mode = "on_demand", interval = 15, network = true,
 *   battery_not_low = true, idle_only = false
 */
data class BackgroundConfigData(
    val mode: String = "on_demand",
    val wakeupIntervalMinutes: Long = 15,
    val networkRequired: Boolean = true,
    val batteryNotLow: Boolean = true,
    val idleOnly: Boolean = false
)

/**
 * Singleton manager for Android background processing.
 *
 * Handles notification channel creation, WorkManager periodic work enqueue,
 * and foreground service lifecycle (start/stop).
 *
 * Follows the singleton + synchronized initialize pattern from KeyStoreHelper.java
 * (lines 28-55). Kotlin `object` is the idiomatic replacement for Java static+synchronized.
 *
 * Per D-09: notification channel uses IMPORTANCE_LOW (no sound — status display only).
 * Per D-08: enqueueUniquePeriodicWork with KEEP policy uses configured interval.
 * Per ANDN-02: constraints and interval are config-driven via background_config.json.
 */
object BackgroundServiceManager {

    private const val TAG = "GeniusBackground"
    const val NOTIFICATION_CHANNEL_ID = "genius_processing_channel"
    const val NOTIFICATION_ID = 1001
    private const val UNIQUE_WORK_NAME = "genius_background_sync"

    private var initialized = false
    private val lock = Any()

    // Config values loaded from native layer after nativeInit
    private var backgroundConfig: BackgroundConfigData = BackgroundConfigData()

    // Application context stored for foreground service lifecycle
    private var appContext: Context? = null

    // JNI native initialization — called after notification channel setup
    private external fun nativeInit(context: Context)

    // JNI native config retrieval — returns JSON string from C++ layer
    private external fun nativeGetConfigJson(): String

    /**
     * Initialize the background service manager.
     *
     * Must be called once at app startup (MainActivity.onCreate()).
     * Creates the notification channel and enqueues WorkManager periodic work.
     *
     * Pattern: KeyStoreHelper.initialize() lines 44-55
     *
     * @param context Application or Activity context
     */
    fun initialize(context: Context) {
        synchronized(lock) {
            if (initialized) {
                Log.w(TAG, "BackgroundServiceManager already initialized")
                return
            }

            val appContext = context.applicationContext

            // Store app context for foreground service lifecycle (called from JNI upcalls)
            this.appContext = appContext

            // Create notification channel BEFORE any foreground service starts
            // Mitigation T-01-05: channel created at startup AND defensively in
            // GeniusForegroundService.onCreate() per RESEARCH.md Pitfall 4
            createNotificationChannel(appContext)

            // Initialize native side (JNI class caching + config loading)
            nativeInit(appContext)

            // Retrieve parsed config from native layer
            // nativeGetConfigJson returns a JSON string serialized from
            // the BackgroundConfig struct loaded by LoadBackgroundConfig()
            try {
                val configJson = nativeGetConfigJson()
                if (configJson != null && configJson.isNotEmpty()) {
                    val json = JSONObject(configJson)
                    backgroundConfig = BackgroundConfigData(
                        mode = json.optString("mode", "on_demand"),
                        wakeupIntervalMinutes = json.optLong("wakeupIntervalMinutes", 15),
                        networkRequired = json.optBoolean("networkRequired", true),
                        batteryNotLow = json.optBoolean("batteryNotLow", true),
                        idleOnly = json.optBoolean("idleOnly", false)
                    )
                    Log.i(TAG, "Config loaded from native: mode=${backgroundConfig.mode}, " +
                            "interval=${backgroundConfig.wakeupIntervalMinutes}min, " +
                            "network=${backgroundConfig.networkRequired}, " +
                            "batteryNotLow=${backgroundConfig.batteryNotLow}, " +
                            "idleOnly=${backgroundConfig.idleOnly}")
                } else {
                    Log.w(TAG, "nativeGetConfigJson returned null/empty — using defaults")
                }
            } catch (e: Exception) {
                Log.e(TAG, "Failed to parse native config JSON — using defaults", e)
            }

            // Enqueue WorkManager periodic work with config-driven constraints
            // Mode "disabled" → skip enqueue entirely
            if (backgroundConfig.mode == "disabled") {
                Log.w(TAG, "Background processing disabled by config — " +
                        "WorkManager periodic work NOT enqueued")
            } else {
                enqueuePeriodicWork(appContext, backgroundConfig)
            }

            initialized = true
            Log.i(TAG, "BackgroundServiceManager initialized successfully")
        }
    }

    /**
     * Create the notification channel for foreground service.
     *
     * Per D-09: IMPORTANCE_LOW (no sound), setShowBadge(false).
     * Channel must exist before any foreground service can post notifications.
     */
    private fun createNotificationChannel(context: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = context.getString(R.string.genius_notification_channel_name)
            val channelDescription = context.getString(R.string.genius_notification_channel_description)

            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = channelDescription
                setShowBadge(false)
            }

            val notificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)

            Log.i(TAG, "Notification channel '$NOTIFICATION_CHANNEL_ID' created")
        }
    }

    /**
     * Enqueue a WorkManager periodic task for Genius background sync.
     *
     * Config-driven: constraints (network, battery, idle) and interval
     * are read from BackgroundConfigData, which was populated from
     * background_config.json via the native layer.
     *
     * Per RESEARCH.md Pitfall 3 (Correct Constraint Semantics):
     *   - setRequiresBatteryNotLow(true) → defers when battery IS low (CORRECT)
     *   - setRequiredNetworkType(CONNECTED) → requires network (correct for CRDT sync)
     *   - Do NOT use setRequiresDeviceIdle(true) unless task can wait hours
     *
     * Per ANDN-02: work executes when constraints are met.
     *
     * @param context Application context
     * @param config  BackgroundConfigData with constraint and interval values
     */
    fun enqueuePeriodicWork(context: Context, config: BackgroundConfigData) {
        // Build constraints from config values
        val constraintsBuilder = Constraints.Builder()

        if (config.networkRequired) {
            constraintsBuilder.setRequiredNetworkType(NetworkType.CONNECTED)
        }
        if (config.batteryNotLow) {
            // Correct semantics: defers when battery IS low
            constraintsBuilder.setRequiresBatteryNotLow(true)
        }
        if (config.idleOnly) {
            // Only for truly opportunistic tasks; default is false
            // per RESEARCH.md Pitfall 3 guidance
            constraintsBuilder.setRequiresDeviceIdle(true)
        }

        val constraints = constraintsBuilder.build()

        // Enforce WorkManager minimum interval (15 minutes)
        val intervalMinutes = if (config.wakeupIntervalMinutes < 15) {
            Log.w(TAG, "Configured interval ${config.wakeupIntervalMinutes}min < 15min " +
                    "minimum — clamping to 15min")
            15L
        } else {
            config.wakeupIntervalMinutes
        }

        val request = PeriodicWorkRequestBuilder<GeniusBackgroundWorker>(
            intervalMinutes, TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            // ANDN-03: exponential backoff starting at ~10 seconds
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                WorkRequest.MIN_BACKOFF_MILLIS,
                TimeUnit.MILLISECONDS
            )
            // ANDN-04: prioritize in Doze maintenance windows
            .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
            .setInitialDelay(0, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request
        )

        Log.i(TAG, "Periodic work enqueued: interval=$intervalMinutes min, " +
                "constraints=[network=${config.networkRequired}, " +
                "batteryNotLow=${config.batteryNotLow}, idleOnly=${config.idleOnly}], " +
                "backoff=EXPONENTIAL, expedited=true")
    }

    /**
     * Start the GeniusForegroundService.
     *
     * Called from C++ via JNI upcall when the node detects pending CRDT work.
     * Uses ContextCompat.startForegroundService for API 26+ compatibility.
     *
     * @param context Application context
     */
    fun startForegroundService(context: Context) {
        val intent = Intent(context, GeniusForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ContextCompat.startForegroundService(context, intent)
        } else {
            context.startService(intent)
        }
        Log.i(TAG, "Foreground service start requested")
    }

    /**
     * Stop the GeniusForegroundService.
     *
     * Called from C++ via JNI upcall when the node transitions to idle.
     */
    fun stopForegroundService(context: Context) {
        val intent = Intent(context, GeniusForegroundService::class.java)
        context.stopService(intent)
        Log.i(TAG, "Foreground service stop requested")
    }

    // ========================================================================
    // JNI bridge methods — called FROM C++ via JNI upcalls
    // ========================================================================

    /**
     * Request foreground service start from C++.
     *
     * Called by AndroidRequestForegroundService() in GeniusSDKAndroid.cpp.
     * Posts to main looper since JNI calls may come from C++ IO threads.
     *
     * Stores title/text for GeniusForegroundService to use in notification,
     * then starts the foreground service via startForegroundService().
     *
     * @param title Notification title
     * @param text  Notification content text
     * @return true if the service start was dispatched
     */
    @JvmStatic
    fun requestForegroundService(title: String, text: String): Boolean {
        val ctx = appContext
        if (ctx == null) {
            Log.e(TAG, "requestForegroundService: appContext is null — not initialized")
            return false
        }
        Log.i(TAG, "Foreground service requested from C++: title='$title', text='$text'")
        startForegroundService(ctx)
        return true
    }

    /**
     * Request foreground service stop from C++.
     *
     * Called by AndroidRequestStopForegroundService() in GeniusSDKAndroid.cpp.
     */
    @JvmStatic
    fun requestStopForegroundService() {
        val ctx = appContext
        if (ctx == null) {
            Log.e(TAG, "requestStopForegroundService: appContext is null — not initialized")
            return
        }
        Log.i(TAG, "Foreground service stop requested from C++")
        stopForegroundService(ctx)
    }
}
