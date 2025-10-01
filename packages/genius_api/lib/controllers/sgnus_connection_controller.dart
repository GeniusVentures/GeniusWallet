import 'dart:async';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:rxdart/rxdart.dart';

class SGNUSConnectionController {
  // Private StreamController
  final _controller = BehaviorSubject<SGNUSConnection>.seeded(
    SGNUSConnection(sgnusAddress: "", walletAddress: "", connection: null),
  );

  // Expose the stream for listeners
  Stream<SGNUSConnection> get stream => _controller.stream;

  // Add data to the stream
  void updateConnection(SGNUSConnection connection) {
    _controller.add(connection);
  }

  void emptyConnection() {
    _controller.add(SGNUSConnection(
        sgnusAddress: "", walletAddress: "", connection: null),
    );
  }

  // Close the controller when done
  void dispose() {
    _controller.close();
  }
}
