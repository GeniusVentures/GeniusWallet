import Cocoa
import FlutterMacOS
import WebKit
import webview_flutter_wkwebview

class MainFlutterWindow: NSWindow {
  private var gnusBridge: GnusWebBridge?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame

    // Paint the window the boot canvas colour BEFORE Flutter's first frame.
    // Everything in main()'s appRunner (Hive, secure storage, providers,
    // wallet load) runs ahead of runApp(), and until that first frame lands
    // macOS shows this window's own background — which defaults to black, so
    // the app opened on a black rectangle and only then revealed the logo.
    //
    // Keep in sync with `_kBootCanvas` in lib/screens/splash.dart (#06070B).
    self.backgroundColor = NSColor(
      srgbRed: 0x06 / 255.0,
      green: 0x07 / 255.0,
      blue: 0x0B / 255.0,
      alpha: 1.0
    )

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    gnusBridge = GnusWebBridge(
      messenger: flutterViewController.registrar(forPlugin: "GnusWebBridge").messenger,
      registry: flutterViewController)

    super.awakeFromNib()
  }
}

/// Installs window.gnus on a WKWebView that webview_flutter created, as a
/// main-frame-only script. The handler drops messages from other frames and
/// passes the origin WebKit names; Dart checks it against the allowlist.
final class GnusWebBridge {
  private let channel: FlutterMethodChannel
  private let registry: FlutterPluginRegistry
  private static let handlerName = "gnusBridge"

  init(messenger: FlutterBinaryMessenger, registry: FlutterPluginRegistry) {
    self.channel = FlutterMethodChannel(
      name: "ai.gnus.genius_wallet/gnus_bridge", binaryMessenger: messenger)
    self.registry = registry
    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result)
    }
  }

  private func handle(_ call: FlutterMethodCall, _ result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    guard let id = (args?["webViewId"] as? NSNumber)?.int64Value else {
      result(call.method == "install" ? false : nil)
      return
    }
    switch call.method {
    case "install":
      result(install(id, shim: args?["shim"] as? String))
    case "uninstall":
      webView(id)?.configuration.userContentController.removeScriptMessageHandler(
        forName: GnusWebBridge.handlerName)
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func webView(_ id: Int64) -> WKWebView? {
    FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: id, withPluginRegistry: registry)
  }

  private func install(_ id: Int64, shim: String?) -> Bool {
    guard let shim = shim, let view = webView(id) else {
      return false
    }
    let controller = view.configuration.userContentController
    // A name can be added once, and the controller retains its handler.
    controller.removeScriptMessageHandler(forName: GnusWebBridge.handlerName)
    controller.add(
      GnusMessageHandler(channel: channel, webViewId: id), name: GnusWebBridge.handlerName)
    // ponytail: WKUserContentController cannot remove one script, so a second
    // install on the same view adds a second copy. The shim installs once per
    // document, so the copy does nothing.
    controller.addUserScript(
      WKUserScript(source: shim, injectionTime: .atDocumentStart, forMainFrameOnly: true))
    return true
  }
}

private final class GnusMessageHandler: NSObject, WKScriptMessageHandler {
  private weak var channel: FlutterMethodChannel?
  private let webViewId: Int64

  init(channel: FlutterMethodChannel, webViewId: Int64) {
    self.channel = channel
    self.webViewId = webViewId
  }

  func userContentController(
    _ userContentController: WKUserContentController, didReceive message: WKScriptMessage
  ) {
    guard message.frameInfo.isMainFrame, let body = message.body as? String else {
      return
    }
    let origin = message.frameInfo.securityOrigin
    var source = "\(origin.protocol)://\(origin.host)"
    if origin.port != 0 {
      source += ":\(origin.port)"
    }
    channel?.invokeMethod(
      "message", arguments: ["webViewId": webViewId, "message": body, "source": source])
  }
}
