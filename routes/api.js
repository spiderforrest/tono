const { auth, add } = require("../lib/users")
const router = require('express').Router();


router.post("/login", async (req, res) => {

  if (!req.body.username || !req.body.password) {
      res.status(400).json({ message: 'username or password missing' });
      return;
  }

  const checked_user = await auth(req.body.username, req.body.password)
  if (checked_user) {
    req.session.user = checked_user;
    res.status(200).json({ message: 'logged in'})
  } else {
    res.status(400).json({ message: 'username or password incorrect' });
  }
});

router.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/login");
});

module.exports = router;
