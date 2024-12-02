import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // Tạo một instance duy nhất của SocketService
  static final SocketService _instance = SocketService._internal();
  
  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  late IO.Socket socket;

  void initialize(String url) {
    socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket']) // chỉ sử dụng websocket
        .enableAutoConnect()
        .build());

    socket.onConnect((_) {
      print('Connection established');
    });

    socket.onConnectError((data) {
      print('Connection error: $data');
    });

    socket.onDisconnect((_) {
      print('Socket.IO server disconnected');
    });
    socket.on('message', (data) => print(data));
  }

  void sendMessage(String message) {
    socket.emit('message', {
      'message': message.trim(),
      // 'sendAt': time,
    });
  }

  // Bạn có thể thêm các phương thức khác để lắng nghe các sự kiện từ server
}
