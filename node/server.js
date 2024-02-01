const express = require("express");
const http = require("http");
const socketIo = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const messages = [];

io.on("connection", (socket) => {
  console.log("Nowe połączenie:", socket.id);

  // Wysyłanie historii wiadomości do nowo połączonego urządzenia
  socket.emit("chatHistory", messages);

  // Obsługa nowej wiadomości
  socket.on("sendMessage", (data) => {
    const message = {
      senderId: socket.id,
      text: data.text,
    };

    // dodawanie wiadomości do tablicy `messages`
    messages.push(message);

    // Emitowanie wiadomości do wszystkich połączonych klientów
    io.emit("receiveMessage", message);
  });

  // Obsługa rozłączenia klienta
  socket.on("disconnect", () => {
    console.log("Rozłączono:", socket.id);
  });
});

const PORT = 3000;

server.listen(PORT, () => {
  console.log(`Serwer nasłuchuje na porcie ${PORT}`);
});
