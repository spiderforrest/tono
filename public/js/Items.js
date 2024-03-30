class Items {
  // the client copy of the items array is stored as this.#items-as requests get made, it's populated
  // _sparsely_ with any data its gotten sent over. This is all done in the update_cache() function,
  // which needs to be called by any functions that get more data from the server.
  #items;
  constructor() {
    this.#items = [];
  }
  #update_cache(new_list) {
    // go over each of the new items
    for (let i = 0; i <= new_list.length; ++i) {
      const id = new_list[i].id
      // assign them DIRECTLY to the cache array in their id slot
      this.#items[id - 1] = new_list[i]
    }
  }

  get_cache() {
    return this.#items;
  }
  // first/last is the id, not the index, of the first item in the range
  async get_range(first, last) {
    const res = await fetch(`/api/data/range?first=${first}&last=${last}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    })

    const range = await res.json()
    if (range) this.#update_cache(range); // no overwrite bad resp
    return range;
  }


  async get_recursive(id, depth) {
    const res = await fetch(`/api/data/range?id=${id}&depth=${depth}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    })

    const bundle = await res.json()
    if (bundle) this.#update_cache(bundle); // no overwrite bad resp
    return bundle;
  }

  async get_uuid(uuid) {
    const match = this.#items.find(item => item?.uuid == uuid);
    if (match) return match;

    // searches may need to fallback to serverside
    const res = await fetch(`/api/data/uuid/${uuid}`, {
      method: 'GET',
      headers: { 'Content-Type': 'application/json' },
    })
    const item = await res.json();

    if (item) this.#update_cache([item]);
    return item;
  }

  async add(fields) {
    const res = await fetch(`/api/data/add/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { fields }
    })
    const item = await res.json()

    if (item) this.#update_cache([item]);
    return item;
  }

  async modify(id, fields) {
    const res = await fetch(`/api/data/modify/`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: { id, fields }
    })
    const item = await res.json()

    if (item) this.#update_cache([item]);
    return item;
  }

  async remove_uuid(uuid) {
    await fetch(`/api/data/uuid/${uuid}`, {
      method: 'DELETE',
      headers: { 'Content-Type': 'application/json' },
    })

    // we need to totally reset the cache here bc the ids will alll get shuffled
    // probably trigger some sort of refresh, but that's front(er) end stuff
    // for now just:
    this.#items = [];
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
        if (!items_tree.includes(this.#items[id-1])) {
          items_tree.push(this.#items[id-1]);
        }

        // recurse on them kids
        for (const kid of this.#items[id-1]?.children) {
          recurse(kid, depth + 1);
        }
      }
      recurse(id, 0);
      return items_tree;

    } else {
      return this.#items[id-1]; // random items start at 1 reminder
    }
  }
}
