import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
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

    super.awakeFromNib()
  }
}
