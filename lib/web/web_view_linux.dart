/// * We are not using this as of now there will be no native support for the wallet for linux

// import 'package:flutter/material.dart';
// import 'package:desktop_webview_window/desktop_webview_window.dart';
// import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

// class WebViewLinux extends StatefulWidget {
//   final String url;

//   const WebViewLinux({Key? key, required this.url}) : super(key: key);

//   @override
//   WebViewLinuxState createState() => WebViewLinuxState();
// }

// class WebViewLinuxState extends State<WebViewLinux> {
//   Webview? _webView;
//   final TextEditingController _urlController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _initializeLinuxWebView(widget.url);
//   }

//   /// **Initialize or Relaunch WebView**
//   Future<void> _initializeLinuxWebView(String url) async {
//     if (_webView == null) {
//       _webView = await WebviewWindow.create();
//       _webView?.onClose.whenComplete(() {
//         _webView = null; // Reset WebView when closed
//       });
//     }
//     _webView?.launch(url);
//     _urlController.text = url;

//     // Listen for URL changes & update search bar
//     _webView?.addOnUrlRequestCallback((newUrl) {
//       setState(() {
//         _urlController.text = newUrl;
//       });
//     });
//   }

//   /// **Load a new URL and relaunch if necessary**
//   void _loadUrl() {
//     String url = _urlController.text.trim();
//     if (url.isNotEmpty && !url.startsWith("http")) {
//       url = "https://$url";
//     }

//     if (_webView == null) {
//       _initializeLinuxWebView(url); // Relaunch if closed
//     } else {
//       _webView?.launch(url);
//     }
//   }

//   @override
//   void dispose() {
//     _webView?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor:
//           GeniusWalletColors.deepBlueTertiary, // Dark blue background
//       body: Column(
//         children: [
//           const SizedBox(height: 8), // Space at the top
//           _buildSearchBar(), // Search bar
//           const Expanded(
//             child: Center(
//               child: Text(
//                 "Browser Launched in Separate Window...",
//                 style: TextStyle(fontSize: 16, color: Colors.white70),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// **Search Bar with Navigation Buttons**
//   Widget _buildSearchBar() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//           horizontal: 20, vertical: 10), // Padding outside search bar
//       child: Container(
//         padding: const EdgeInsets.symmetric(
//             horizontal: 10, vertical: 8), // Padding inside search bar
//         decoration: BoxDecoration(
//           color: GeniusWalletColors.deepBlueCardColor, // Search bar background
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildIconButton(Icons.arrow_back, () {
//               _webView?.back();
//             }),
//             _buildIconButton(Icons.arrow_forward, () {
//               _webView?.forward();
//             }),
//             _buildIconButton(Icons.refresh, () {
//               _webView?.launch(_urlController.text); // Reload URL
//             }),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 controller: _urlController,
//                 style:
//                     const TextStyle(color: Colors.white), // White text in input
//                 decoration: InputDecoration(
//                   hintText: "Enter URL...",
//                   hintStyle: const TextStyle(color: Colors.white70),
//                   filled: true,
//                   fillColor: GeniusWalletColors
//                       .deepBlueTertiary, // Darker blue input background
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 onSubmitted: (_) => _loadUrl(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// **Reusable Icon Button**
//   Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
//     return IconButton(
//       icon: Icon(icon),
//       color: GeniusWalletColors.lightGreenPrimary, // Default color
//       iconSize: 24, // Standard icon size
//       onPressed: onPressed,
//     );
//   }
// }
