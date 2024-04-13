# Dote Data Structure

Dote stores user data as individual-per-user JSON files; when one user's file is loaded, it should contain all their currently relevant data.
(In other words, one user's JSON data file should contain all the data a Dote client needs to render the user's full todo/notes list, excluding archived items and any non-default configuration files.)

Dote is also designed with the assumption that each user's datafile comes from a singular, authoritative source; when loading data, a Dote client expects to retrieve a complete JSON document from either a remote server or local device storage.
If a user's datafile needs to be synchronized across multiple servers or dynamically assembled from multiple sources on demand, *that work must be done before the datafile is provided to the Dote client.*

Each datafile contains one large array that contains many individual Dote objects (todos, notes, tags), henceforth referred to as "items".
(See the *Items* section below for details.)

Although Dote is built around the idea of parent/child relationships and inheritance of properties through those relationships,
the list of items in JSON form is a flat array; no item is actually nested inside of another item in JSON.

## Items

Items take the form of individual JSON objects within the single array in the user's JSON datafile, and those objects contain key-value pairs that store data about the item in question.

Users can add arbitrary key-value pairs to items whenever they'd like.

However, Dote uses many specifically-named keys (such as `type`) for its core functionality, and Dote expects the values of these keys to have specific datatypes. Some must also be formatted or constructed in specific ways.

Users should avoid naming their custom keys anything that Dote recognizes as having special meaning.

### Parent/Child relationships

Dote allows users to "stack" items in a tree structure, where items may be "sub-items" of other items; this is intended to be used as a way of representing dependency and scope relationships between items.

For example, a `todo` item that is the child of another `todo` item can be considered a "sub-task" that must be completed before its parent task can be accomplished.

Similarly, a `note` item that is the child of another item can be considered "scoped" to its parent, indicating that it is relevant only in the context of its parent item. (For example, a `todo` item titled "repair my car" could have a `note` item as a child detailing the parts and steps required to accomplish the repair job.)

### Properties (global)

All items have a number of **required** properties. These key-value pairs should be set whenever a new item is created.

| Key | Type | Description | Default value |
| ---------- | ---------- | ---------- | ---------- |
| `created` | int (unix timestamp) | Time/date of item's creation. | Current time at item creation |
| `id` | int | User-specific item identifier. Always contiguous from 1 to `n`, where `n` is the total number of items in a user's list. Only assigned/modified by server. This value is arbitrarily assigned and not used for ordering items by default. **Not constant: when items are added or removed from a user's list, this value may be reassigned.** | `n + 1` |
| `type` | string | The item's type (see *Item Types* section below). Always lowercase (ex: "todo", "note") | configurable |
| `title` | string | The item's user-facing name. In the client, this is the primary "name" displayed for an item. | configurable |
| `children` | array of ints | List of other items this item has as children, specified by `id`. | `[]` |
| `parents` | array of ints | List of other items this item has as parents, specified by `id`. | `[]` |
| `uuid` | string | UUID for item. No items should ever share a UUID, even if owned by different users. **Does not change after item creation.** | generated at item creation |

Items may also have **optional** properties. For these items, a value of `undefined` is permitted.

As these options are not required for core Dote functionality, they have no default value.

| Key | Type | Description |
| ---------- | ---------- | ---------- |
| `body` | string | Information about the item too long for the `title` field, that is supplementary in nature. |
| `updated` | int (unix timestamp) | Date item was most recently updated. |
| `complete` | bool | Indicates whether the item is still relevant to the user. If all items in a subtree (meaning a root item and all its children, direct or indirect) have `complete: true` set, that subtree will be automatically archived by Dote after a configurable amount of time. |

Some other properties we want to add later, but not yet:
target = "date",
deadline = "date",
hidden = "bool",

## Item Types

Item types denote specific functionality the user wishes the item to have, and are what Dote clients use to determine the most appropriate method for displaying the item in question.

Each item type represents a specific kind of information the user wishes to keep track of.

For example, an item with type `todo` is most appropriate for keeping track of a task the user must complete, and has properties specifically for tracking this type of information.

In contrast, an item with type `note` lacks the functionality of `todo` (for example, the `done` field), and is most appropriate for recording information the user wishes to have easy access to, but is not closely tied to a specific task.

Details on specific types and their unique properties are listed below.

### todo

The `todo` item type is intended for task tracking, and has a few properties for this purpose.

| Key | Type | Description | Required? | Default value |
| --- | ---- | ----------- | --------- | ------------- |
| `complete` | bool | For todo type, whether or not the task is complete. | yes | `false` |

### note

The `note` item type is intended for storing information in text form.

### tag

The `tag` item type is intended for sorting and categorizing other items.

Parent and child relationships between items have special meaning when used with tags.

Parent-child relationships don't behave any differently with tags compared to other item types--the only difference is in how clients render tags compared to other items.

- A child item with a tag as a parent, *directly or indirectly*, is considered to be tagged by that parent.
- A tag item's children, *direct or indirect*, are considered to be tagged with that tag. Tags function similarly to categories in this way.
    - When tagging/untagging items, make sure to update both the parent tag's `children` field and the tagged items' `parents` fields.
- When a tag item is the child of a non-tag item, the tag is considered "scoped" to that item (although this does not actually limit what items the tag in question may have as children).
- Tags tagged with other tags (tags with tag items as children) can also be considered "scoped" tags (though this again does not limit either tag's use at all.)
