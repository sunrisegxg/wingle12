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
  console.log('Username: ');
  // const username = socket.handshake.query.username;
  socket.on('message', (data) => {
    const message = {
      messages: data.message,
      // sendAt: Date.now(),
    }
    messages.push(message);
    io.emit('message', message);
  });
  socket.on('disconnect', () => {
    console.log('User disconnected');
  });
});

server.listen(4000, () => {
  console.log('Server is running on http://localhost:4000');
});