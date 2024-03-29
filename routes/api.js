const { auth, add } = require("../lib/users");
const { get_data_from_disk, get_range, get_uuid, remove } = require("../lib/userdata");
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
    req.session.user.data = await get_data_from_disk(checked_user.uuid);

    res.status(200).json({ message: 'logged in' });
  } else {
    res.status(400).json({ message: 'username or password incorrect' });
  }
});

router.post("/signup", async (req, res) => {
  const new_user = await add(req.body.username, req.body.password);
  if (new_user) {
    req.session.user = new_user;

    req.session.user.data = await get_data_from_disk(new_user.uuid); // unneeded but honestly just a sanity check

    res.status(200).json({ message: 'signed up' });

  } else {
    res.status(400).json({ message: 'error signing up' });
  }
});



// data stuff
router.get("/data/all", auth_middleware, (req, res) => {
  // shared notes will probably be a seperate file
  // named `${shared_tag_uid}.json`, like the user stores
  // this wouldn't work with that, deal with it when i implement that
  // does that make this not futere proof
  // and ssssstinky?
  res.status(200).json({ data: req.session.user.data });
});

// still think GET should be used for this but i don't write rfcs
router.post("/data/range", auth_middleware, (req, res) => {
  const range = get_range(req.session.user, req.body.start, req.body.end)
  if (range) {
    res.status(200).json({ range });
  } else {
    res.status(400).json({ message: 'range empty'});
  }
})

router.post("/data/uuid", auth_middleware, (req, res) => {
  const item = get_uuid(req.session.user, req.body.uuid)
  if (item) {
    res.status(200).json({ item });
  } else {
    res.status(400).json({ message: 'item not found'});
  }
})

router.put("/data/add", auth_middleware, (req, res) => {
})

router.delete("/data/uuid", auth_middleware, (req, res) => {
  const id = get_uuid(req.session.user, req.body.uuid).id
  if (id) {
    remove(req.session.user, id)
  }
})


module.exports = router;
