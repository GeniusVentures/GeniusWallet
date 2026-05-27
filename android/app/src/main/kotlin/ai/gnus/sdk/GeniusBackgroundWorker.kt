package ai.gnus.sdk

import android.content.Context
import android.util.Log
import androidx.work.BackoffPolicy
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.OutOfQuotaPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkRequest
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
 * Per ANDN-03: exponential backoff retry on failure (3 attempts max).
 * Per ANDN-04: setExpedited for Doze maintenance window priority.
 *
 * Pattern: RESEARCH.md Pattern 2 (WorkManager-JNI Wake-Up Bridge)
 */
class GeniusBackgroundWorker(
    context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    companion object {
        private const val TAG = "GeniusBackground"
        private const val UNIQUE_WORK_NAME = "genius_background_sync"

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
         * Configures WorkManager with:
         *   - BackoffPolicy.EXPONENTIAL for automatic retry backoff (ANDN-03)
         *   - setExpedited for Doze maintenance window priority (ANDN-04)
         *   - ExistingPeriodicWorkPolicy.KEEP to preserve existing work
         *
         * Per RESEARCH.md Don't Hand-Roll: WorkManager handles retry and
         * Doze natively — no custom retry loops or power-state checks needed.
         *
         * @param context         Application context
         * @param intervalMinutes Periodic interval (minimum 15 minutes)
         */
        fun enqueuePeriodic(context: Context, intervalMinutes: Long) {
            val constraints = androidx.work.Constraints.Builder()
                .setRequiredNetworkType(NetworkType.CONNECTED)
                .setRequiresBatteryNotLow(true)
                .build()

            val request = PeriodicWorkRequestBuilder<GeniusBackgroundWorker>(
                intervalMinutes, TimeUnit.MINUTES
            )
                .setConstraints(constraints)
                // ANDN-03: exponential backoff starting at ~10 seconds per
                // RESEARCH.md Don't Hand-Roll guidance (MIN_BACKOFF_MILLIS)
                .setBackoffCriteria(
                    BackoffPolicy.EXPONENTIAL,
                    WorkRequest.MIN_BACKOFF_MILLIS,
                    TimeUnit.MILLISECONDS
                )
                // ANDN-04: prioritize in Doze maintenance windows
                // RUN_AS_NON_EXPEDITED_WORK_REQUEST ensures task still
                // executes even if expedited quota is exhausted
                .setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
                .setInitialDelay(0, TimeUnit.MINUTES)
                .build()

            WorkManager.getInstance(context)
                .enqueueUniquePeriodicWork(
                    UNIQUE_WORK_NAME,
                    ExistingPeriodicWorkPolicy.KEEP,
                    request
                )

            Log.i(TAG, "Periodic work enqueued: interval=$intervalMinutes min, " +
                    "backoff=EXPONENTIAL, expedited=true")
        }
    }

    /**
     * WorkManager entry point — called when periodic task fires.
     *
     * Calls into native code via JNI to check if the C++ node has
     * pending CRDT work. If so, the native handler requests foreground
     * service start via AndroidRequestForegroundService().
     *
     * Retry logic (ANDN-03):
     *   - Exception caught AND runAttemptCount < 3 → Result.retry()
     *     (WorkManager applies BackoffPolicy.EXPONENTIAL between retries)
     *   - Exception caught AND runAttemptCount >= 3 → Result.failure()
     *     (task marked as permanently failed — no further retries)
     *   - Success → Result.success()
     *
     * @return Result indicating work outcome (success, retry, or failure)
     */
    override suspend fun doWork(): Result {
        Log.i(TAG, "doWork() triggered (attempt ${runAttemptCount}) — " +
                "waking native GeniusSDK node")

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
            Log.e(TAG, "doWork() failed with exception (attempt ${runAttemptCount}/3)", e)

            if (runAttemptCount < 3) {
                // ANDN-03: retry with exponential backoff (WorkManager handles timing)
                Log.i(TAG, "Retrying — attempt ${runAttemptCount} of 3")
                Result.retry()
            } else {
                // ANDN-03: permanent failure after 3 attempts
                Log.e(TAG, "Permanent failure after ${runAttemptCount} attempts — " +
                        "giving up")
                Result.failure()
            }
        }
    }
}
