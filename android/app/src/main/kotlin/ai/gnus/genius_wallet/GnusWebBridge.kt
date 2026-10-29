package ai.gnus.genius_wallet

import android.os.Handler
import android.os.Looper
import android.webkit.WebView
import androidx.webkit.ScriptHandler
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi

/**
 * Installs window.gnus on a WebView that webview_flutter created, only for the
 * allowed origins. Main-frame messages reach Dart with the origin WebView names.
 * A WebView without both features gets no bridge.
 */
class GnusWebBridge(
	private val engine: FlutterEngine,
	private val channel: MethodChannel,
) {
	private class Installed(val view: WebView, val script: ScriptHandler)

	private val installed = HashMap<Long, Installed>()
	private val main = Handler(Looper.getMainLooper())

	init {
		channel.setMethodCallHandler { call, result -> onCall(call, result) }
	}

	private fun onCall(call: MethodCall, result: MethodChannel.Result) {
		val id = call.argument<Number>("webViewId")?.toLong()
		when (call.method) {
			"install" -> result.success(id != null && install(id, call))
			"uninstall" -> {
				if (id != null) {
					uninstall(id)
				}
				result.success(null)
			}
			else -> result.notImplemented()
		}
	}

	private fun install(id: Long, call: MethodCall): Boolean {
		val origins = call.argument<List<String>>("origins")?.toSet()
		val shim = call.argument<String>("shim")
		if (origins.isNullOrEmpty() || shim == null) {
			return false
		}
		if (!WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER) ||
			!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
		) {
			return false
		}
		val view = WebViewFlutterAndroidExternalApi.getWebView(engine, id) ?: return false
		uninstall(id)
		try {
			WebViewCompat.addWebMessageListener(view, NAME, origins) { _, message, sourceOrigin, isMainFrame, _ ->
				if (isMainFrame && message.type == WebMessageCompat.TYPE_STRING) {
					val data = message.data
					if (data != null) {
						val args = mapOf(
							"webViewId" to id,
							"message" to data,
							"source" to sourceOrigin.toString(),
						)
						main.post { channel.invokeMethod("message", args) }
					}
				}
			}
			try {
				installed[id] = Installed(view, WebViewCompat.addDocumentStartJavaScript(view, shim, origins))
			} catch (e: RuntimeException) {
				WebViewCompat.removeWebMessageListener(view, NAME)
				return false
			}
			return true
		} catch (e: IllegalArgumentException) {
			// An origin rule WebView does not accept.
			return false
		}
	}

	private fun uninstall(id: Long) {
		val entry = installed.remove(id) ?: return
		try {
			WebViewCompat.removeWebMessageListener(entry.view, NAME)
			entry.script.remove()
		} catch (e: RuntimeException) {
			// The WebView is already gone.
		}
	}

	private companion object {
		const val NAME = "gnusBridge"
	}
}
