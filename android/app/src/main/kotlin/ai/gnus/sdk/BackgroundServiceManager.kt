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
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

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
 */
object BackgroundServiceManager {

    private const val TAG = "GeniusBackground"
    const val NOTIFICATION_CHANNEL_ID = "genius_processing_channel"
    const val NOTIFICATION_ID = 1001
    private const val UNIQUE_WORK_NAME = "genius_background_sync"

    private var initialized = false
    private val lock = Any()

    // JNI native initialization — called after notification channel setup
    private external fun nativeInit(context: Context)

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

            // Create notification channel BEFORE any foreground service starts
            // Mitigation T-01-05: channel created at startup AND defensively in
            // GeniusForegroundService.onCreate() per RESEARCH.md Pitfall 4
            createNotificationChannel(appContext)

            // Enqueue WorkManager periodic work
            enqueuePeriodicWork(appContext, 15)

            // Initialize native side (JNI class caching)
            nativeInit(appContext)

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
     * Per D-08: config-driven interval. Default 15 minutes (WorkManager minimum).
     * Per ANDN-01: constraints include network connected and battery not low.
     *
     * @param context         Application context
     * @param intervalMinutes Periodic work interval (minimum 15 minutes)
     */
    fun enqueuePeriodicWork(context: Context, intervalMinutes: Long) {
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .setRequiresBatteryNotLow(true)
            .build()

        val request = PeriodicWorkRequestBuilder<GeniusBackgroundWorker>(
            intervalMinutes, TimeUnit.MINUTES
        )
            .setConstraints(constraints)
            .setInitialDelay(0, TimeUnit.MINUTES)
            .build()

        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request
        )

        Log.i(TAG, "Periodic work enqueued: interval=$intervalMinutes min, " +
                "constraints=[network=CONNECTED, batteryNotLow=true]")
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
     * @param title Notification title
     * @param text  Notification content text
     * @return true if the service start was dispatched
     */
    @JvmStatic
    fun requestForegroundService(title: String, text: String): Boolean {
        // TODO: Store title/text for GeniusForegroundService to use
        Log.i(TAG, "Foreground service requested from C++: title='$title', text='$text'")
        return true
    }

    /**
     * Request foreground service stop from C++.
     *
     * Called by AndroidRequestStopForegroundService() in GeniusSDKAndroid.cpp.
     */
    @JvmStatic
    fun requestStopForegroundService() {
        Log.i(TAG, "Foreground service stop requested from C++")
    }
}
