
// WIP js lib that a server or client can pull in to handle making actual transactions against the
// user's data
const M = {} // can you tell i like lua more

const err = () => {
  console.log('temp error message i guess')
}
// not sure the way we'll want to handle it in actual implementation, so for now i'll be doing module scope
// storing of the actual data, like:
let dumb_data_placeholder = null
M.set_data = (x) => dumb_data_placeholder = x
M.get_data = () => dumb_data_placeholder

// create a new item, and set any given fields
M.create = (fields) => {
  let data = M.get_data()

  // set required fields
  fields.type = fields.type || "todo"
  fields.created = Date.now()
  fields.id = data.length + 1
  fields.uid = data.uid_counter
  data.uid_counter += 1 // increment uid counter after setting, for the next item

  data.push(fields)
  M.set_data(data)
}

M.modify = (id, fields) => {
  let data = M.get_data()
  delete fields.uid // clear out the uid field, not reassignable

  // use object spread to merge the two, prioritizing the new changes
  data[id-1] = { ...data[id-1], ...fields }

  M.set_data(data)
  return data
}

module.exports = M

