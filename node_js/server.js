const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const { Server } = require('socket.io');
const io = new Server(server);
const messages = []
// app.get('/', (req, res) => {
//   res.sendFile(join(__dirname, 'index.html'));
// });

io.on('connection', (socket) => {
  const username = socket.handshake.query.username;
  const userId = socket.handshake.query.uid;
  console.log('Client '+ userId +' connected');
  socket.on('message', (data) => {
    const message = {
      sender: username,
      sender_uid: userId,
      receiver_uid: data.receiver_uid,
      messages: data.message,
      sendAt: new Date(data.sendAt),
    }
    messages.push(message);
    console.log(message);
    io.emit('message', message);
  });
  socket.on('disconnect', () => {
    console.log('Client ' + userId + ' disconnected');
  });
});

server.listen(4000, () => {
  console.log('Server is running on http://localhost:4000');
});