const router = require('express').Router();
const path = require('path');

const auth = require("../lib/auth")

router.get("/", auth, (_req, res) => {
 res.sendFile(path.join(__dirname, "/../public/home.html"));
});

router.get("/login", (_req, res) => {
 res.sendFile(path.join(__dirname, "/../public/login.html"));
});
router.get("/signup", (_req, res) => {
 res.sendFile(path.join(__dirname, "/../public/signup.html"));
});


module.exports = router;
