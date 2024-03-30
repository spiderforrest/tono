
const dat = new Items()

dat.get_range(4,10).then(()=> {
  console.log(dat.get_cache())

  dat.get_uuid("c8c24341-90af-43ad-80b5-2f1f3e964764").then(()=> {
    console.log(dat.get_cache())
  })
})

