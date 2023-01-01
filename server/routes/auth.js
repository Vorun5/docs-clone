import express from "express";
import {User} from "../models/index.js";
import jwt from "jsonwebtoken";
import {auth} from "../middlewares/index.js";

const authRouter = express.Router();

authRouter.post('/api/signup', async (req, res) => {
    try {
        const {name, email, photoUrl} = req.body;

        let user = await User.findOne({email});

        if (!user) {
            user = new User({name, email, photoUrl});
            user = await user.save();
        }

        const token = jwt.sign({id: user._id}, "passwordKey");

        res.json({user, token});
    } catch (e) {
        res.status(500).json({error: e.message});
    }
})

authRouter.get('/', auth, async (req, res) => {
    try {
        const user = await User.findById(req.user);
        if (!user) {
            res.status(404).json({error: "User not found."});
        }

        res.json({user, token: req.token});
    } catch (e) {
        res.status(500).json({error: e.message});
    }
});

export default authRouter;
