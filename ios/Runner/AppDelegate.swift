import UIKit
import Flutter
import WebKit
import webview_flutter_wkwebview

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var gnusBridge: GnusWebBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "GnusWebBridge") {
      gnusBridge = GnusWebBridge(messenger: registrar.messenger(), registry: self)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
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
