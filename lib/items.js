const { readFile, writeFile } = require("fs/promises");
const { v4 } = require("uuid");
const path = require("path");



async function get_data_from_disk(uuid) {
  try {
    const result = await readFile(path.join(process.env.STORE_DIR, uuid + ".json"));
    return JSON.parse(result);
  } catch (error) {
    console.log(error, `Failed to load user ${uuid} datafile!`);
    return '[]'; // do better, stink
  }
}

async function save_data_to_disk(user) {
  try {
    await writeFile(path.join(process.env.STORE_DIR, user.uuid + ".json"), JSON.stringify(user.data));
  } catch (error) {
    console.log(error, `Failed to write user ${uuid} datafile!`);
  }
}

// start/end is the id, not the index, of the first item in the range
function get_range(user, start, end) {
 // verbose math to make clear -1 for id offset and +1 for inclusive, i can't count to 1
  const range = user.data.slice(start - 1, end - 1 + 1)
  if (range.length == 0) return false;
  return range;
}

// get item by uuid
function get_uuid(user, uuid) {
  return user.data.find(item => item.uuid == uuid);
}

// create a new item, and set any given fields
function create(user, fields) {
  // set required fields
  fields.type = fields.type || "todo";
  fields.created = Date.now();
  fields.id = data.length + 1; // see stinky comment below
  fields.uuid = v4();

  user.data.push(fields);
  save_data_to_disk(user);
}

function modify(user, id, fields) {
  delete fields.uuid; // forcably clear out the id fields, not manually reassignable
  delete fields.id;

  // use object spread to merge the two, prioritizing the new changes
  // if you're wondering abt the -1, it's because there's no item with id 0
  // if you're wondering why, don't
  // stinky? stinky.
  user.data[id-1] = { ...user.data[id-1], ...fields };

  save_data_to_disk(user);
}

function remove(user, id) {
  // go through every parent the item we're removing has
  for (const parent_id of user.data[id-1]?.parents) {
    // and remove this item from the parent's children list
    user.data[parent_id-1].children = user.data[parent_id-1]?.children.filter(child => child != id)
  }
  // same but opposite
  for (const parent_id of user.data[id-1]?.children) {
    user.data[parent_id-1].parents = user.data[parent_id-1]?.parents.filter(child => child != id)
  }

  // TODO: save item to a trash file

  // actually delete the item
  user.data.splice(id-1, 1)

  // repair the damage that just did yipee
}

module.exports = { get_data_from_disk, save_data_to_disk, get_range, get_uuid, create, modify, remove };
