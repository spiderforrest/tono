const { readFile, writeFile } = require("fs");
// const { v4 } = require('uuid');
const bcrypt = require("bcrypt")


// to entirely be rewritten, this is just quick and as dirty as it gets to work on other stuff


const user_store_path = 'users_idk.json';
let user_store = [];


function initialize() {
  readFile(user_store_path, (error, data) => {
    if (error) console.log(error, "Failed to read the user store!");
    user_store = JSON.parse(data);
  });
}
initialize()

function get() {
  return user_store;
}

function add(username, password) {
  if (user_store.find((user) => user.username == username)) {
    // duplicate username, do better later
    return false;
  }
 bcrypt.hash(password, 10, (_err, hash) => {
    user_store.push({
      username,
      password: hash
      // uuid: v4()
    });

    // stinkyyyyyy
    writeFile(user_store_path, JSON.stringify(user_store),
      error => {
        if (error) console.log("Failed to write the user store!")
      }
    );

  });

}

function remove() {
}

async function auth(username, password) {
  const user = user_store.find((user) => user.username == username);

  if (!user) return false;

  const result = await bcrypt.compare(password, user.password)
  if (result) return user;
  return false;
}

module.exports = { get, add, remove, auth }
