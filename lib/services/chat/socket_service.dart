import 'package:app/services/auth/auth_service.dart';
import 'package:app/services/user/user_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  // user current
  late String useruid;
  late String username;
  // Tạo một instance duy nhất của SocketService
  static final SocketService _instance = SocketService._internal();
  
  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  late IO.Socket socket;

  void initialize(String url) async {
    useruid = AuthService().getCurrentUser()!.uid;
    username = await UserData().getUserName(useruid);
    socket = IO.io(url, IO.OptionBuilder()
        .setTransports(['websocket']) // chỉ sử dụng websocket
        .setQuery({'username': username, 'uid': useruid })
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

  void sendMessage(String uid, String message, Timestamp time) {
    socket.emit('message', {
      'sender': username,
      'sender_uid': useruid,
      'receiver_uid': uid,
      'message': message.trim(),
      'sendAt': time.millisecondsSinceEpoch,
    });
  }

  // Bạn có thể thêm các phương thức khác để lắng nghe các sự kiện từ server
}
