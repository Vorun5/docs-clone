import mongoose from "mongoose";

const documentSchema = new mongoose.Schema({
    uid: {
        type: String,
        require: true,
    },
    createdAt: {
        type: Number,
        require: true,
    },
    title: {
        type: String,
        require: true,
        trim: true,
    },
    content: {
        type: Array,
        default: [],
    },
});

const Document = mongoose.model('Document', documentSchema);

export default Document;
