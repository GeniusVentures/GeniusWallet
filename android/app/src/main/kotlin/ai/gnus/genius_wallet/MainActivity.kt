package ai.gnus.genius_wallet

import ai.gnus.sdk.BackgroundServiceManager
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.lang.reflect.InvocationTargetException

class MainActivity: FlutterActivity() {
	companion object {
		private const val CHANNEL = "ai.gnus.genius_wallet/platform"
		private const val TAG = "GeniusWallet"
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		// Walking Skeleton: initialize background processing on app startup.
		// Creates notification channel and enqueues WorkManager periodic work.
		try {
			BackgroundServiceManager.initialize(this)
			Log.i(TAG, "BackgroundServiceManager initialized")
		} catch (e: Exception) {
			Log.e(TAG, "Failed to initialize BackgroundServiceManager", e)
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
			.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
				when (call.method) {
					"initializeAndroidKeyStore" -> {
						try {
							initializeAndroidKeyStore()
							result.success(true)
						} catch (e: Throwable) {
							val rootCause = if (e is InvocationTargetException && e.cause != null) {
								e.cause!!
							} else {
								e
							}
							Log.e(TAG, "Failed to initialize KeyStoreHelper", e)
							result.error(
								"KEYSTORE_INIT_FAILED",
								rootCause.message ?: rootCause.toString(),
								null,
							)
						}
					}

					else -> result.notImplemented()
				}
			}
	}

	private fun initializeAndroidKeyStore() {
		try {
			// Java native method resolution for KeyStoreHelper.nativeInit requires System.loadLibrary.
			System.loadLibrary("GeniusWallet")
		} catch (_: UnsatisfiedLinkError) {
			// Ignore: may already be loaded in this process by another path.
		}

		val context = applicationContext
		val helperClass = Class.forName("ai.gnus.sdk.KeyStoreHelper")
		val initializeMethod = helperClass.getMethod("initialize", android.content.Context::class.java)
		initializeMethod.invoke(null, context)
	}
}
