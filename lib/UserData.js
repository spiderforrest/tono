const { readFile, writeFile } = require("fs/promises");
const { v4 } = require("uuid");
const path = require("path");


class UserData {
  // cache data here, instances of this can be stored in the user's session
  #data;
  constructor(uuid) {
    this.uuid = uuid;
    this.#data = [];
  };
  get data() { return this.#data }

  async get_data_from_disk() {
    try {
      const result = await readFile(path.join(process.env.STORE_DIR, this.uuid + ".json"));
      this.#data = JSON.parse(result);
    } catch {
      console.log(error, `Failed to load user ${this.uuid} datafile!`);
    }
  }

  async save_data_to_disk(data) {
    try {
      await writeFile(path.join(process.env.STORE_DIR, this.uuid + ".json"), JSON.stringify(data));
    } catch {
      console.log(error, `Failed to write user ${this.uuid} datafile!`);
    }
  }

  get_uuid(uuid) {
    return this.#data.find(item => item.uuid == uuid);
  }

  // create a new item, and set any given fields
  create(fields) {
    // set required fields
    fields.type = fields.type || "todo";
    fields.created = Date.now();
    fields.id = this.#data.length + 1;
    fields.uuid = v4();

    this.#data.push(fields);
    this.save_data_to_disk();
  }

  modify(id, fields) {
    delete fields.uuid; // forcably clear out the uuid field, not reassignable

    // use object spread to merge the two, prioritizing the new changes
    // if you're wondering abt the -1, it's because there's no item with id 0
    // if you're wondering why, don't
    // stinky? stinky.
    this.#data[id-1] = { ...this.#data[id-1], ...fields };

    this.save_data_to_disk();
  }

  remove(id) {
    // go through every parent the item we're removing has
    for (const parent_id of this.#data[id-1]?.parents) {
      // and remove this item from the parent's children list
      this.#data[parent_id-1].children = this.#data[parent_id-1]?.children.filter(child => child != id)
    }
    // same but opposite
    for (const parent_id of this.#data[id-1]?.children) {
      this.#data[parent_id-1].parents = this.#data[parent_id-1]?.parents.filter(child => child != id)
    }

    // TODO: save item to a trash file

    // actually delete the item
    this.#data.splice(id-1, 1)

    // repair the damage that just did yipee
  }
}

module.exports = UserData;
