# Dote data structure notes

Dote stores user data as individual-per-user JSON files; when one user's file is loaded, it should contain all their currently relevant data.
(In other words, one user's JSON data file should contain all the data a Dote client needs to render the user's full todo/notes list, excluding archived items and any non-default configuration files.)

Dote is also designed with the assumption that each user's datafile comes from a singular, authoritative source; when loading data, a Dote client expects to retrieve a complete JSON document from either a remote server or local device storage.
If a user's datafile needs to be synchronized across multiple servers or dynamically assembled from multiple sources on demand, *that work must be done before the datafile is provided to the Dote client.*

Each datafile contains one large array that contains many individual Dote objects (todos, notes, tags), henceforth referred to as "items".
(See the "Item notes" section below for details.)

Although Dote is built around the idea of parent/child relationships and inheritance of properties through those relationships,
the list of items in JSON form is a flat structure where every item is on the same level; no item is actually nested inside of another item in JSON.

## Item notes

Items take the form of individual JSON objects within the single array in the user's JSON datafile, and those objects contain key-value pairs that store data about the item in question.
Users can add arbitrary key-value pairs to items whenever they'd like.
However, Dote uses many specifically-named keys (such as `type`) for its core functionality, and Dote expects the values of these keys to have specific datatypes. Some must also be formatted or constructed in specific ways.
Users should avoid naming their custom keys anything that Dote recognizes as having special meaning.

### Properties (global)

All items have three required properties:

- `created`: (int, unix timestamp) Date of item creation.
- `id`: (int, unique, primary key for items) May be reassigned when archiving data. *`id` must be continuous from 1 to `n`, where `n` is the number of items in the file.*
- `type`: (string) Type of item. For now, only ever `todo`, `tag`, `note`.

Specific properties expect specific datatypes. Quick list:

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

Todo and note types are internally identical aside from their `type` value: their only other difference is in how clients render them.

### Properties (tag)

Parent and child relationships have special meaning when used with tags.
Parent-child relationships are not different in internal function when used with tags--the difference is in how clients render tags as categories rather than items.

- A child item with a tag as a parent is considered to be tagged by that parent.
- A tag item's list of children is a list of items considered to be tagged with that tag. Tags function similarly to categories in this way.
    - When tagging/untagging items, make sure to update both the parent tag's `children` field and the tagged items' `parents` fields.
- When a tag item is the child of a non-tag item, the tag is considered "scoped" to that item (although this does not actually limit what items the tag in question may have as children).
- Tags tagged with other tags (tags with tag items as children) can also be considered "scoped" tags (though this again does not limit either tag's use at all.)
