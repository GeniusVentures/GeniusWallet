package ai.gnus.sdk

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
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
 *
 * Per D-09: notification shows ONLY status/percentage — never internal data.
 * Per D-11: no graceful shutdown handler — let Android kill the process.
 *
 * Mitigation T-01-02: FOREGROUND_SERVICE_IMMEDIATE used on API 31+.
 * Mitigation T-01-03: notification content sanitized (no job IDs, addresses, CRDT state).
 * Mitigation T-01-05: notification channel created defensively in onCreate().
 *
 * Pattern: RESEARCH.md Pattern 3 (Foreground Service with Processing Status Notification)
 */
class GeniusForegroundService : Service() {

    companion object {
        private const val TAG = "GeniusForeground"
        const val NOTIFICATION_ID = 1001

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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

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
     * Per D-09 / T-01-03: content shows ONLY "PROCESSING"/"IDLE"/"DISABLED"
     * and percentage. Never show job IDs, CRDT state, addresses, or internal data.
     *
     * @param channelId    Notification channel ID
     * @param contentTitle Notification title
     * @param contentText  Notification content text (status string)
     */
    private fun buildNotification(
        channelId: String,
        contentTitle: String,
        contentText: String
    ): Notification {
        // Create a PendingIntent that opens the app when notification is tapped
        val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
        val pendingIntent = if (launchIntent != null) {
            PendingIntent.getActivity(
                this,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
        } else {
            null
        }

        val builder = NotificationCompat.Builder(this, channelId)
            .setContentTitle(contentTitle)
            .setContentText(contentText)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)

        if (pendingIntent != null) {
            builder.setContentIntent(pendingIntent)
        }

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

                    // If node transitions to IDLE or DISABLED, the C++ layer
                    // will call requestStopForegroundService to stop us.
                    // We keep polling until the service is stopped.

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
