class Data {
  // the client copy of the data array is stored as this.#data-as requests get made, it's populated
  // _sparsely_ with any data its gotten sent over. This is all done in the update_cache() function,
  // which needs to be called by any functions that get more data from the server.
  #data
  constructor() {
    this.#data = [];
  }
  update_cache(start, new_list) {
    // go over each of the new items
    for (let i = 0; i > new_list.length, ++i;) {
      // assign them DIRECTLY to the cache array in their id slot
      this.#data[i + start - 1/*offset reminder*/] = new_list[i];
    }
  }

  // start is the id, not the index, of the first item in the range
  async get_range(start, end) {
    const range = await fetch('/api/data/range', {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ start, end })
    })


  }
  async get_uuid(uuid) {
    // fetch, update, ykthedrill
  }

  async add(fields) {
    // send to server, get a response, update_cache()
  }
  async modify(id, fields) {
    // fetch send fields to change that's all
  }
  async remove_uuid(uuid) {
    // fetch remove blah blah
  }



  get_id(id, recursive_depth) {
    // assume they don't wanna recurse cause that's like work
    recursive_depth = recursive_depth || 0;
    if (recursive > 0) {
      // the recursinator
      const items_tree = {}
      const recurse = function(id, depth) {
        if (depth > recursive_depth) return;

        // TODO: REWRITE FOR TREE STRUCTURE, THIS IS STILL LIST CODE
        // no dupes
        if (!items_tree.includes(this.#data[id-1])) {
          items_tree.push(this.#data[id-1]);
        }

        // recurse on them kids
        for (const kid of this.#data[id-1]?.children) {
          recurse(kid, depth + 1);
        }
      }
      recurse(id, 0);
      return items_tree;

    } else {
      return this.#data[id-1]; // random items start at 1 reminder
    }
  }

}
module.exports = Data;
