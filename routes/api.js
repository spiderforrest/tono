const { auth, add } = require("../lib/users");
const UserData = require("../lib/UserData");
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

    // lack of error handling is stinky, also ram bloat
    
    // haaah
    // so
    // don't work
    // express flattens classes to json
    req.session.UserData = new UserData(checked_user.uuid);
    await req.session.UserData.get_data_from_disk();
    console.log(req.session.UserData.data)

    res.status(200).json({ message: 'logged in' });
  } else {
    res.status(400).json({ message: 'username or password incorrect' });
  }
});

router.post("/signup", async (req, res) => {
  const new_user = await add(req.body.username, req.body.password);
  if (new_user) {
    req.session.user = new_user;

    req.session.UserData = new UserData(checked_user.uuid);
    await req.session.UserData.get_data_from_disk();

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

router.get("/data/all", auth_middleware, (req, res) => {
  // shared notes will probably be a seperate file
  // named `${shared_tag_uid}.json`, like the user stores
  // this wouldn't work with that, deal with it when i implement that
  // does that make this not futere proof
  // and ssssstinky?
  console.log(req.session)
  console.log(req.session.UserData.data)

  res.status(200).json({ data: req.session.UserData.data });
});

router.get("/data/range", auth_middleware, (req, res) => {
// todo lol
})

router.get("/data/uuid", auth_middleware, (req, res) => {
  const item = req.session.UserData.get_uuid(req.body.uuid)
  if (item) {
    res.status(200).json({ item });
  } else {
    res.status(400).json({ message: 'item not found'});
  }
})

router.delete("/data/uuid", auth_middleware, (req, res) => {
  const id = req.session.UserData.get_uuid(req.body.uuid);
  if (id) {
    req.session.UserData.remove(id);
  }
})


module.exports = router;
