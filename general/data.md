# Dote data structure notes

Dote stores user data as individual-per-user json files; when one user's file is loaded, it should contain all their data.
Each datafile contains one large array that contains many Dote objects (todos, notes, tags), henceforth referred to as "items".

## Item

### Properties (global)

All items have three required properties.
`created`: (int, unix timestamp) Date of item creation.
`id`: (int, unique, primary key for items) May be reassigned when archiving data. *`id` must be continous from 1 to `n`, where `n` is the number of items in the file.*
`type`: (string) Type of item. For now, only ever `todo`, `tag`, `note`.

Specific fields expect specific datatypes. Quick list:
```
created = "date",
updated = "date",
target = "date",
deadline = "date",
done = "bool",
hidden = "bool",
id = "int",
tags = "deref", -- for lists of ids
children = "deref",
parents = "deref"
```

### Properties (todo/note)

Todo and note types are internally identical: their only difference is in how clients render them.

### Properties (tag)

Parent and child relationships have special meaning when used with tags.
Parent-child relationships are not different in internal function when used with tags--the difference is in how clients render tags as categories rather than items.

- A child item with a tag as a parent is considered to be tagged by that parent.
- A tag item's list of children is a list of items considered to be tagged with that tag.
    - When tagging/untagging items, make sure to update both the parent tag's `children` field and the tagged items' `parents` fields.
- When a tag item is the child of a non-tag item, the tag is considered "scoped" to that item (although this does not actually limit what items the tag in question may have as children).
- Tags tagged with other tags (tags with tag items as children) can also be considered "scoped" tags (though this again does not limit either tag's use at all.)
