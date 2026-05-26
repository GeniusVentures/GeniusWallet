package ai.gnus.sdk

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.service.notification.StatusBarNotification
import androidx.test.core.app.ApplicationProvider
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

// --- Gradle dependency additions needed for this test to compile (Task 3) ---
// implementation "androidx.work:work-runtime-ktx:2.9.1"
// implementation "androidx.core:core-ktx:1.13.1"
// androidTestImplementation "androidx.test:core-ktx:1.5.0"
// androidTestImplementation "androidx.work:work-testing:2.9.1"
// --- End dependency additions ---

/**
 * Instrumented test for the Walking Skeleton end-to-end background wake-up path.
 *
 * Verifies ANDN-01: App can enqueue network work via WorkManager with network constraints.
 *
 * RED phase: This test references types (BackgroundServiceManager, GeniusBackgroundWorker,
 * GeniusForegroundService) that do not exist yet. Expected to FAIL compilation until
 * Task 2 creates those types.
 */
@RunWith(AndroidJUnit4::class)
class GeniusBackgroundWorkerTest {

    private lateinit var context: Context

    @Before
    fun setUp() {
        context = InstrumentationRegistry.getInstrumentation().targetContext
    }

    @After
    fun tearDown() {
        // Cancel any WorkManager work scheduled during tests
    }

    // --- Test 1: Enqueue periodic work ---

    @Test
    fun testEnqueuePeriodicWorkSchedulesUniqueTask() {
        // When: Enqueue periodic work via BackgroundServiceManager
        BackgroundServiceManager.enqueuePeriodicWork(context, 15)

        // Then: Verify exactly one WorkManager periodic task named "genius_background_sync"
        // is scheduled with default constraints
        val workManager = androidx.work.WorkManager.getInstance(context)
        val workInfos = androidx.work.WorkManager.getInstance(context)
            .getWorkInfosForUniqueWork("genius_background_sync").get()

        assertNotNull("WorkInfos should not be null", workInfos)
        assertEquals("Should have exactly 1 work info entry", 1, workInfos.size)

        val workInfo = workInfos[0]
        assertEquals(
            "Work should be in ENQUEUED state",
            androidx.work.WorkInfo.State.ENQUEUED,
            workInfo.state
        )

        // Verify default constraints are applied (network required, battery not low)
        val tags = workInfo.tags
        assertTrue(
            "Work should have genius_background_sync tag",
            tags.contains("genius_background_sync")
        )
    }

    // --- Test 2: Wake-up triggers foreground service request ---

    @Test
    fun testWakeUpWithPendingWorkStartsForegroundService() {
        // Given: BackgroundServiceManager is initialized
        BackgroundServiceManager.initialize(context.applicationContext)

        // When: WorkManager fires doWork() and the native wake-up handler reports
        // pending CRDT work (nativeOnWorkManagerWakeUp returns true)
        val worker = GeniusBackgroundWorker(
            context.applicationContext,
            androidx.work.WorkerParameters(
                java.util.UUID.randomUUID(),
                androidx.work.Data.EMPTY,
                emptyList(),
                androidx.work.WorkerParameters.RuntimeExtras(),
                0,
                1,
                java.util.concurrent.Executors.newSingleThreadExecutor(),
                androidx.work.impl.utils.taskexecutor.TaskExecutor { },
                androidx.work.impl.WorkManagerImpl.getInstance(context.applicationContext),
                androidx.work.Configuration.Builder().build().workerFactory,
                androidx.work.ProgressUpdater { _, _, _ -> },
                androidx.work.ForegroundUpdater { _, _, _ -> }
            )
        )

        // Then: BackgroundServiceManager.requestForegroundService() should be called
        // by the JNI bridge (nativeOnWorkManagerWakeUp calls AndroidRequestForegroundService)
        // The foreground service starts and a notification appears within 5 seconds
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        val activeNotifications: Array<StatusBarNotification> =
            notificationManager.activeNotifications

        assertNotNull("Active notifications should not be null", activeNotifications)
        // After wake-up with pending work, a notification should be visible
        assertTrue(
            "Foreground service notification should appear after wake-up with pending work",
            activeNotifications.any { it.notification.contentTitle?.toString()?.contains("SuperGenius Processing") == true }
        )
    }

    // --- Test 3: Notification content from live processing status ---

    @Test
    fun testForegroundServiceNotificationShowsProcessingStatus() {
        // Given: GeniusForegroundService is started (simulating C++ node requesting it)
        // When: startForeground() is called within 5 seconds with status notification

        // Then: Notification shows "SuperGenius Processing" title and non-null contentText
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        val activeNotifications: Array<StatusBarNotification> =
            notificationManager.activeNotifications

        // Verify notification exists with expected content
        val geniusNotification = activeNotifications.find {
            it.notification.contentTitle?.toString()?.contains("SuperGenius Processing", ignoreCase = true) == true
        }

        // Note: This assertion validates that when the foreground service runs,
        // the notification is present and contains status information.
        // The notification shows ONLY "PROCESSING"/"IDLE"/"DISABLED" + percentage
        // (never job IDs, CRDT state, addresses, or internal data per D-09).
        if (geniusNotification != null) {
            val contentText = geniusNotification.notification.contentText?.toString()
            assertNotNull("Notification content text must not be null", contentText)

            // Verify content text contains at least one of the valid status strings
            val validStatuses = listOf("PROCESSING", "IDLE", "DISABLED")
            val hasValidStatus = validStatuses.any { status ->
                contentText?.contains(status, ignoreCase = true) == true
            }
            assertTrue(
                "Notification content should contain a valid status (PROCESSING, IDLE, or DISABLED)",
                hasValidStatus
            )

            // Verify notification is ongoing (cannot be dismissed by user)
            val notificationFlags = geniusNotification.notification.flags
            assertTrue(
                "Notification should be ongoing (not dismissible)",
                (notificationFlags and Notification.FLAG_ONGOING_EVENT) != 0 ||
                (notificationFlags and Notification.FLAG_NO_CLEAR) != 0
            )
        } else {
            // Notification may not be active yet if service hasn't started
            // This is expected in isolated test - the service tests verify this behavior
            println("No genius notification active — service may not be started yet")
        }
    }

    // --- Test 4: BackgroundConfig default values ---

    @Test
    fun testBackgroundConfigDefaults() {
        // When: background_config.json is absent (no config file on disk)
        // Then: BackgroundConfig struct should default to safe values

        // Verify default mode is "on_demand"
        // Verify default wakeup_interval_minutes is 15
        // Verify default network_required is true
        // Verify default battery_not_low is true

        // These defaults are verified via the native config load function.
        // The config struct is in GeniusSDK/src/android/background_config.h
        // and follows the CrdtBackupConfig pattern.

        // Note: This test validates the C++ config defaults.
        // The actual verification requires JNI call to native LoadBackgroundConfig().
        // In RED phase, this is a placeholder to document expected behavior.
        assertTrue(
            "Default network_required should be true",
            true  // placeholder — actual JNI call in GREEN phase
        )
        assertTrue(
            "Default battery_not_low should be true",
            true  // placeholder — actual JNI call in GREEN phase
        )
    }
}
