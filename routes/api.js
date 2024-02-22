const { auth, add } = require("../lib/users");
const { get_data } = require("../lib/transactions");
const auth_middleware = require("../lib/auth");
const router = require('express').Router();


// user stuff
router.post("/login", async (req, res) => {

  if (!req.body.username || !req.body.password) {
      res.status(400).json({ message: 'username or password missing' });
      return;
  }

  const checked_user = await auth(req.body.username, req.body.password);
  if (checked_user) {
    req.session.user = checked_user;
    res.status(200).json({ message: 'logged in' });
  } else {
    res.status(400).json({ message: 'username or password incorrect' });
  }
});

router.post("/signup", async (req, res) => {
  const new_user = await add(req.body.username, req.body.password);
  if (new_user) {
    req.session.user = new_user;
    res.status(200).json({ message: 'signed up' });
  } else {
    res.status(400).json({ message: 'error signing up' });
  }
});

router.get("/logout", (req, res) => {
  req.session.destroy();
  res.redirect("/login");
});


// data stuff
// honestly should split this file into two controllers files and a routes file
// dare i say
// stinky

router.get("/full-data", auth_middleware, async (req, res) => {
  // shared notes will probably be a seperate file
  // named `${shared_tag_uid}.json`, like the user stores
  // this wouldn't work with that, deal with it when i implement that
  // does that make this not futere proof
  // and ssssstinky?
  try {
    const data = await get_data(req.session.user.uuid)
    res.status(200).json({ data });
  } catch {
    res.status(400).json({ message: 'something went wrong and this error message sucks' })
  }
});



module.exports = router;
