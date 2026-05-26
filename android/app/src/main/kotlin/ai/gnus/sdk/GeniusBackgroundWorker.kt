package ai.gnus.sdk

import android.content.Context
import android.util.Log
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

/**
 * WorkManager CoroutineWorker for periodic Genius background sync.
 *
 * Extends CoroutineWorker for Kotlin coroutine support.
 * Each periodic wake-up fires doWork() which calls into native code
 * via JNI to check CRDT state and request foreground service if needed.
 *
 * Per D-08: WorkManager wake-up re-checks node state.
 * Per D-12: no polling of node readiness — just call and handle errors.
 *
 * Pattern: RESEARCH.md Pattern 2 (WorkManager-JNI Wake-Up Bridge)
 */
class GeniusBackgroundWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "GeniusBackground"

        /**
         * JNI native method — calls GeniusSDKAndroid.cpp
         * Java_ai_gnus_sdk_GeniusBackgroundWorker_nativeOnWorkManagerWakeUp
         *
         * @return true if the node had pending CRDT work and requested foreground service
         */
        private external fun nativeOnWorkManagerWakeUp(): Boolean

        /**
         * Factory method to enqueue periodic WorkManager work.
         *
         * Per D-08: configurable interval. Uses ExistingPeriodicWorkPolicy.KEEP
         * to avoid replacing existing work when re-initializing.
         *
         * @param context         Application context
         * @param intervalMinutes Periodic interval (minimum 15 minutes)
         */
        fun enqueuePeriodic(context: Context, intervalMinutes: Long) {
            val constraints = androidx.work.Constraints.Builder()
                .setRequiredNetworkType(androidx.work.NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            val request = androidx.work.PeriodicWorkRequestBuilder<GeniusBackgroundWorker>(
                intervalMinutes, TimeUnit.MINUTES
            )
                .setConstraints(constraints)
                .setInitialDelay(0, TimeUnit.MINUTES)
                .build()

            androidx.work.WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    "genius_background_sync",
                    androidx.work.ExistingPeriodicWorkPolicy.KEEP,
                    request
                )

            Log.i(TAG, "Periodic work enqueued: interval=$intervalMinutes min")
        }
    }

    /**
     * WorkManager entry point — called when periodic task fires.
     *
     * Calls into native code via JNI to check if the C++ node has
     * pending CRDT work. If so, the native handler requests foreground
     * service start via AndroidRequestForegroundService().
     *
     * @return Result.success() always — failures are handled gracefully;
     *         WorkManager retry is deferred to Phase 1 Plan 02 (ANDN-03)
     */
    override suspend fun doWork(): Result {
        Log.i(TAG, "doWork() triggered — waking native GeniusSDK node")

        return try {
            val hasPendingWork = nativeOnWorkManagerWakeUp()

            if (hasPendingWork) {
                Log.i(TAG, "Native wake-up reported pending work — " +
                        "foreground service requested")
            } else {
                Log.i(TAG, "Native wake-up: no pending work — node is idle")
            }

            Result.success()
        } catch (e: Exception) {
            Log.e(TAG, "doWork() failed with exception", e)
            // Per Walking Skeleton (ANDN-01): always succeed.
            // Retry with backoff is deferred to Phase 1 Plan 02 (ANDN-03).
            Result.success()
        }
    }
}
