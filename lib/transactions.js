const { readFile, writeFile } = require("fs/promises");
const { v4 } = require("uuid");
const path = require("path");

// not sure the way we'll want to handle it in actual implementation, so for now i'll be doing module scope
// storing of the actual data, like:
// let dumb_data_placeholder = null
// M.set_data = (x) => dumb_data_placeholder = x
// M.get_data = () => dumb_data_placeholder

async function get_data(uuid) {
  try {
    const result = await readFile(path.join(process.env.STORE_DIR, uuid + ".json"));
    return JSON.parse(result);
  } catch {
      console.log(error, "Failed to load user datafile!");
      return false; // do better
  }
}

async function set_data(uuid, data) {
  try {
    await writeFile(path.join(process.env.STORE_DIR, uuid + ".json"), JSON.stringify(data));
    return true;
  } catch {
      console.log(error, "Failed to write user datafile!");
      return false;
  }
}

// create a new item, and set any given fields
function create(fields) {
  let data = get_data();

  // set required fields
  fields.type = fields.type || "todo";
  fields.created = Date.now();
  fields.id = data.length + 1;
  fields.uuid = v4();

  data.push(fields);
  set_data(data);
}

function modify(id, fields) {
  let data = get_data();
  delete fields.uuid; // forcably clear out the uuid field, not reassignable

  // use object spread to merge the two, prioritizing the new changes
  // if you're wondering abt the -1, it's because there's no item with id 0
  // if you're wondering why, don't
  // stinky? stinky.
  data[id-1] = { ...data[id-1], ...fields };

  set_data(data);
  return data;
}

function remove(id) {
  let data = get_data()
  // go through every parent the item we're removing has
  for (const parent_id of data[id-1]?.parents) {
    // and remove this item from the parent's children list
    data[parent_id-1].children = data[parent_id-1]?.children.filter(child => child != id)
  }
  // same but opposite
  for (const parent_id of data[id-1]?.children) {
    data[parent_id-1].parents = data[parent_id-1]?.parents.filter(child => child != id)
  }

  // TODO: save item to a trash file

  // actually delete the item
  data.splice(id-1, 1)

  // repair the damage that just did yipee
}

module.exports = { get_data, set_data, create, modify, remove }
