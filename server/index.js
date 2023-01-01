import express from "express";
import mongoose from "mongoose";
import {authRouter, documentRouter} from "./routes/index.js";
import {Document} from "./models/index.js";
import http from "http";
import Socket from "socket.io";
import cors from "cors";

const PORT = process.env.PORT | 3001;

mongoose.set("strictQuery", false);
mongoose.connect('mongodb://localhost/docs')
    .then(() => console.log('DB connected'))
    .catch((err) => console.log('DB error ', err));

const app = express();
let server = http.createServer(app);
let io = new Socket(server);

app.use(cors());
app.use(express.json());

app.use(authRouter);
app.use(documentRouter);

io.on('connection', (socket) => {
    socket.on('join', (documentId) => {
        socket.join(documentId);
    });

    socket.on('typing', (data) => {
        socket.broadcast.to(data.room).emit('changes', data);
    });

    socket.on('save', async (d) => {
        await saveData(d);
    });
});

const saveData = async (data) => {
    try {
        await Document.findByIdAndUpdate(data.room, {content: data.delta});
    } catch (e) {
        console.log(e.message);
    }
};

server.listen(PORT, "0.0.0.0", () => {
    console.log(`connected at port ${PORT}`);
});

