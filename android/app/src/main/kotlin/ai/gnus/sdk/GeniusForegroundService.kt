package ai.gnus.sdk

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch

/**
 * Android foreground Service that keeps the GeniusSDK C++ process alive
 * when the app is backgrounded and CRDT processing is active.
 *
 * Displays a persistent notification with live processing status from
 * GeniusSDKGetProcessingStatus(): "PROCESSING: X%", "IDLE", or "DISABLED".
 *
 * Per RESEARCH.md Pitfall 2: startForeground() MUST be called within 5 seconds
 * of onStartCommand(). We call it IMMEDIATELY with a placeholder notification.
 *
 * Per RESEARCH.md Pitfall 5: foregroundServiceType="dataSync" required for API 34+.
 * startForeground() with ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC on API 34+.
 *
 * Per D-09: notification shows ONLY status/percentage — never internal data.
 * Per D-11: no graceful shutdown handler — let Android kill the process.
 *
 * Mitigation T-01-02: FOREGROUND_SERVICE_IMMEDIATE used on API 31+.
 * Mitigation T-01-03: notification content sanitized — no job IDs, addresses, CRDT state.
 * Mitigation T-01-05: notification channel created defensively in onCreate().
 * Mitigation T-01-08: notification VISIBILITY_PUBLIC — safe for lock screen.
 * Mitigation T-01-09: startForeground with FOREGROUND_SERVICE_TYPE_DATA_SYNC on API 34+.
 * Mitigation T-01-10: no PendingIntent set (notification tap does nothing).
 *
 * Battery drain prevention (V14 Configuration):
 *   - DISABLED status → stop service immediately
 *   - IDLE for 60+ consecutive polls → stop service (prevent persistent notification)
 *
 * Pattern: RESEARCH.md Pattern 3 (Foreground Service with Processing Status Notification)
 */
class GeniusForegroundService : Service() {

    companion object {
        private const val TAG = "GeniusForeground"
        const val NOTIFICATION_ID = 1001
        private const val IDLE_STOP_THRESHOLD = 60  // 60 consecutive polls = ~60 seconds

        /**
         * Processing status returned from C++ via JNI.
         *
         * status: 0=DISABLED, 1=IDLE, 2=PROCESSING
         */
        data class ProcessingStatusInfo(
            val status: Int,
            val percentage: Float
        )

        /**
         * JNI native method — calls GeniusSDKAndroid.cpp
         * Java_ai_gnus_sdk_GeniusForegroundService_nativeGetProcessingStatus
         */
        private external fun nativeGetProcessingStatus(): ProcessingStatusInfo
    }

    private val serviceScope = CoroutineScope(Dispatchers.Main + Job())
    private var statusPollJob: Job? = null
    private var idlePollCount: Int = 0

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "GeniusForegroundService onCreate")

        // Defensive notification channel creation
        // Mitigation T-01-05: ensures channel exists even if
        // BackgroundServiceManager.initialize() hasn't been called
        createNotificationChannel()
    }

    /**
     * Called when the service is started.
     *
     * Per Pitfall 2: calls startForeground() IMMEDIATELY with a placeholder
     * notification, then launches a coroutine to poll C++ for live status updates.
     *
     * @return START_STICKY — service is recreated after process kill
     */
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, "GeniusForegroundService onStartCommand (flags=$flags, startId=$startId)")

        // Build placeholder notification and call startForeground IMMEDIATELY
        // Per T-01-02: must be within 5 seconds of onStartCommand()
        val notification = buildNotification(
            channelId = BackgroundServiceManager.NOTIFICATION_CHANNEL_ID,
            contentTitle = "SuperGenius Processing",
            contentText = "Starting..."
        )

        // Per T-01-09 / RESEARCH.md Pitfall 5:
        // On API 34+, startForeground() MUST include the foregroundServiceType
        // that matches the manifest declaration (dataSync).
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // API 29-33: still declare the type if available
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        // Reset idle counter on service start
        idlePollCount = 0

        // Start polling C++ for live processing status
        startStatusPolling()

        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        Log.i(TAG, "GeniusForegroundService onDestroy")

        // Stop polling coroutine
        statusPollJob?.cancel()
        serviceScope.cancel()

        // Remove the notification
        stopForeground(STOP_FOREGROUND_REMOVE)

        super.onDestroy()
    }

    // ========================================================================
    // Notification helpers
    // ========================================================================

    /**
     * Create the notification channel defensively.
     * Mitigation T-01-05: ensures channel exists before posting notification.
     */
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelName = getString(R.string.genius_notification_channel_name)
            val channelDescription =
                getString(R.string.genius_notification_channel_description)

            val channel = NotificationChannel(
                BackgroundServiceManager.NOTIFICATION_CHANNEL_ID,
                channelName,
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = channelDescription
                setShowBadge(false)
            }

            val notificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    /**
     * Build a notification for the foreground service.
     *
     * SECURITY: notification content must not leak internal state.
     * Per D-09 / T-01-03 / V9 Client-Side:
     *   - contentText shows ONLY the status string ("PROCESSING: X%", "IDLE", "DISABLED")
     *   - Never includes: GeniusNodeInstance internal state, CRDT job IDs,
     *     libp2p peer addresses, transaction hashes, or any data beyond
     *     the processing status returned by GeniusSDKGetProcessingStatus()
     *
     * Per T-01-08: notification VISIBILITY_PUBLIC — safe for lock screen
     * because content is limited to processing status only.
     *
     * Per T-01-10: no PendingIntent set — tap does nothing.
     * This is a background status notification, not a user-interactive one.
     *
     * @param channelId    Notification channel ID
     * @param contentTitle Notification title
     * @param contentText  Notification content text (status string only)
     */
    private fun buildNotification(
        channelId: String,
        contentTitle: String,
        contentText: String
    ): Notification {
        val builder = NotificationCompat.Builder(this, channelId)
            .setContentTitle(contentTitle)
            // SECURITY: contentText receives ONLY the status string from
            // nativeGetProcessingStatus().status and .percentage.
            // No other data (CRDT jobs, addresses, internal state) passes through.
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            // T-01-08: safe for lock screen — contains only processing status
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)

        // Per T-01-02: FOREGROUND_SERVICE_IMMEDIATE on API 31+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setForegroundServiceBehavior(
                Notification.FOREGROUND_SERVICE_IMMEDIATE
            )
        }

        return builder.build()
    }

    // ========================================================================
    // Status polling
    // ========================================================================

    /**
     * Start a coroutine that polls C++ for processing status every 1000ms
     * and updates the notification with live status.
     *
     * Per D-09: notification shows "PROCESSING: X%" / "IDLE" / "DISABLED".
     *
     * Battery drain prevention (V14 Configuration):
     *   - DISABLED → cancel polling and stop service immediately
     *   - IDLE for 60+ consecutive polls → cancel and stop (prevents
     *     persistent foreground service when node is truly idle)
     *   - PROCESSING → reset idle counter (service stays alive)
     */
    private fun startStatusPolling() {
        statusPollJob = serviceScope.launch {
            Log.i(TAG, "Status polling started")

            while (isActive) {
                try {
                    val status = nativeGetProcessingStatus()
                    val statusText = statusToString(status)
                    val contentText = when (status.status) {
                        2 -> "$statusText: ${status.percentage.toInt()}%"
                        else -> statusText
                    }

                    updateNotification(contentText, status)

                    // Battery drain prevention: auto-stop logic
                    when (status.status) {
                        0 -> {
                            // DISABLED — stop service immediately
                            Log.i(TAG, "Node status is DISABLED — stopping service")
                            stopForeground(STOP_FOREGROUND_REMOVE)
                            stopSelf()
                            return@launch
                        }
                        1 -> {
                            // IDLE — increment counter, stop if threshold reached
                            idlePollCount++
                            if (idlePollCount >= IDLE_STOP_THRESHOLD) {
                                Log.i(TAG, "Node idle for $idlePollCount polls " +
                                        "(>= $IDLE_STOP_THRESHOLD) — stopping service")
                                stopForeground(STOP_FOREGROUND_REMOVE)
                                stopSelf()
                                return@launch
                            }
                        }
                        2 -> {
                            // PROCESSING — reset idle counter, keep service alive
                            idlePollCount = 0
                        }
                    }

                } catch (e: Exception) {
                    Log.e(TAG, "Status polling error", e)
                }

                delay(1000)
            }

            Log.i(TAG, "Status polling stopped")
        }
    }

    /**
     * Update the foreground service notification with current status.
     *
     * Per D-09: shows progress bar when PROCESSING (setProgress).
     *
     * @param contentText Status text for notification content
     * @param status      Current ProcessingStatusInfo
     */
    private fun updateNotification(contentText: String, status: ProcessingStatusInfo) {
        val notification = buildNotification(
            channelId = BackgroundServiceManager.NOTIFICATION_CHANNEL_ID,
            contentTitle = "SuperGenius Processing",
            contentText = contentText
        )

        // For PROCESSING status, show progress bar
        if (status.status == 2) {
            val builder = NotificationCompat.Builder(
                this,
                BackgroundServiceManager.NOTIFICATION_CHANNEL_ID
            )
                .setContentTitle("SuperGenius Processing")
                .setContentText(contentText)
                .setSmallIcon(android.R.drawable.ic_dialog_info)
                .setOngoing(true)
                .setProgress(100, status.percentage.toInt(), false)

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                builder.setForegroundServiceBehavior(
                    Notification.FOREGROUND_SERVICE_IMMEDIATE
                )
            }

            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIFICATION_ID, builder.build())
        } else {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.notify(NOTIFICATION_ID, notification)
        }
    }

    /**
     * Convert ProcessingStatusInfo to a human-readable status string.
     *
     * Per D-09 / T-01-03: returns ONLY "DISABLED", "IDLE", or "PROCESSING".
     * Never includes internal state.
     */
    private fun statusToString(status: ProcessingStatusInfo): String {
        return when (status.status) {
            0 -> "DISABLED"
            1 -> "IDLE"
            2 -> "PROCESSING"
            else -> "UNKNOWN"
        }
    }
}
