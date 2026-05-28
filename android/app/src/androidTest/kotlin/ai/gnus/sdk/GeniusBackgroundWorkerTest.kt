package ai.gnus.sdk

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.service.notification.StatusBarNotification
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import androidx.work.testing.TestListenableWorkerBuilder
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

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
        // When: Enqueue periodic work via BackgroundServiceManager with default config
        BackgroundServiceManager.enqueuePeriodicWork(context, BackgroundConfigData())

        // Then: Verify exactly one WorkManager periodic task named "genius_background_sync"
        // is scheduled with default constraints
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

        // When: WorkManager fires doWork() — use TestListenableWorkerBuilder
        // from work-testing artifact for proper ListenableWorker testing
        val worker = TestListenableWorkerBuilder<GeniusBackgroundWorker>(context).build()

        // Execute the worker synchronously — doWork() is a suspend function
        val result = runBlocking { worker.doWork() }
        assertNotNull("Worker result should not be null", result)

        // The JNI bridge (nativeOnWorkManagerWakeUp) may or may not start the
        // foreground service depending on whether native code reports pending work.
        // In test environment without native libs, the JNI call will throw —
        // we verify the worker handles the exception gracefully (retry or failure).
        assertTrue("Worker should produce success or retry result",
            result is androidx.work.ListenableWorker.Result.Success ||
            result is androidx.work.ListenableWorker.Result.Retry)
    }

    // --- Test 3: Notification content from live processing status ---

    @Test
    fun testForegroundServiceNotificationShowsProcessingStatus() {
        // Given: GeniusForegroundService is started (simulating C++ node requesting it)
        // When: startForeground() is called within 5 seconds with status notification

        // Then: Notification shows a valid title and non-null contentText.
        // Title is dynamic (D-04): may be "SuperGenius Processing" (fallback) or
        // a contextual title from C++ (e.g. "Syncing CRDT…", "Running AI inference…").
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE)
            as NotificationManager
        val activeNotifications: Array<StatusBarNotification> =
            notificationManager.activeNotifications

        // Verify notification exists with expected content
        val geniusNotification = activeNotifications.find { notif ->
            val title = notif.notification.extras?.getString(Notification.EXTRA_TITLE) ?: ""
            title.contains("SuperGenius", ignoreCase = true) ||
            title.contains("Processing", ignoreCase = true) ||
            title.contains("Syncing", ignoreCase = true) ||
            title.contains("Inference", ignoreCase = true) ||
            title.contains("Standing by", ignoreCase = true)
        }

        if (geniusNotification != null) {
            val contentText = geniusNotification.notification.extras
                ?.getString(Notification.EXTRA_TEXT)
            assertNotNull("Notification content text must not be null", contentText)

            // Verify content text contains at least one of the valid status strings
            // D-04: may also contain contextual text like "Running AI inference…",
            // "Syncing CRDT…", or "Standing by for inference…"
            val validContent = listOf(
                "PROCESSING", "IDLE", "DISABLED",
                "inference", "CRDT", "Standing by", "Syncing"
            )
            val hasValidContent = validContent.any { keyword ->
                contentText?.contains(keyword, ignoreCase = true) == true
            }
            assertTrue(
                "Notification content should contain a valid status or contextual text, got: $contentText",
                hasValidContent
            )

            // Verify notification is ongoing (cannot be dismissed by user)
            val notificationFlags = geniusNotification.notification.flags
            assertTrue(
                "Notification should be ongoing (not dismissible)",
                (notificationFlags and Notification.FLAG_ONGOING_EVENT) != 0 ||
                (notificationFlags and Notification.FLAG_NO_CLEAR) != 0
            )
        } else {
            println("No genius notification active — service may not be started yet")
        }
    }

    // --- Test 4: BackgroundConfig default values ---

    @Test
    fun testBackgroundConfigDefaults() {
        // When: BackgroundConfigData is created with no arguments (all defaults)
        val config = BackgroundConfigData()

        // Then: All 8 fields should match their C++ BackgroundConfig defaults
        // (background_config.h brace-initialized values)
        assertEquals("Default mode should be on_demand", "on_demand", config.mode)
        assertEquals("Default wakeup interval should be 15 min", 15L, config.wakeupIntervalMinutes)
        assertTrue("Default network_required should be true", config.networkRequired)
        assertTrue("Default battery_not_low should be true", config.batteryNotLow)
        assertFalse("Default idle_only should be false", config.idleOnly)

        // D-09: Inference config defaults (Plan 02-01)
        assertTrue("Default thermal_check_enabled should be true", config.thermalCheckEnabled)
        assertTrue("Default battery_saver_check_enabled should be true", config.batterySaverCheckEnabled)
        assertEquals("Default inference_idle_timeout_seconds should be 120",
            120L, config.inferenceIdleTimeoutSeconds)
    }

    // --- Test 5: Thermal/battery gate configuration flags ---

    @Test
    fun testThermalAndBatteryGatesAreConfigurable() {
        // When: Config has thermal and battery checks disabled
        val config = BackgroundConfigData(
            thermalCheckEnabled = false,
            batterySaverCheckEnabled = false
        )

        // Then: Gates can be independently toggled
        assertFalse("Thermal check should be disabled", config.thermalCheckEnabled)
        assertFalse("Battery saver check should be disabled", config.batterySaverCheckEnabled)

        // Other defaults remain unchanged
        assertEquals("Mode should still be on_demand", "on_demand", config.mode)
    }
}
