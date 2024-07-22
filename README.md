# Dote (toDO-noTE)

A to-do and note-taking system centered around dependencies and priorities inside a [directed graph](https://en.wikipedia.org/wiki/Directed_graph).

Dote is a collection of different programs that are all intended to access the same central data storage scheme, of human readable JSON.

This is a command line version of dote, written in Lua.

Inspiration taken from [paradigm/chore](https://github.com/paradigm/chore).

You can find a work in progress web version of dote at [spiderforrest/dote-web](https://github.com/spiderforrest/dote-web).

![Screenshot of three terminals showing dote](https://share.spood.org:5281/file_share/de981bdc-1f66-441e-9d91-3f90abad8611/5b9771d5-54bc-4ba6-a1a1-ad2a874c4f12.png)

## A directed graph? What is dote, what does that actually mean?
Dote is a list of todos and notes with a structure for organizing those around each other in the form of parents and children.
The most simple way to think of dote's structure is as a tree structure, like a filesystem. In fact, a filesystem that supports
linking is a form of directed graph (A [rooted flow bigraph](https://en.wikipedia.org/wiki/Rooted_graph), to be precise).
Unlike a filesystem, there is no root node in dote, so entities can have no parents.

The advantage of this structure is it allows you to look at your data from different perspectives, allowing you to find relevant tasks
or notes for whatever situation you're in. For example, you could look at tasks you want to get done today, and seeing that decide to
go out to do errands. Once you head out, you could look at tasks that are errands, and find some lower priority tasks to get done
while you're already out. You could see your shopping list under a task for grocery shopping, and even see recipes that track their
ingredients to help you keep track of what to buy.


## Usage

There's three different types of basic entities in dote, all represented as nodes in the graph. The types do not have any special
bearing on their content or behavior, and are there solely for user organizational purposes.

- **Task**: A single thing that needs to get done; a single entry on a todo list.

- **Note**: A note to record information in, in the form of plain text.

- **Tags**: A group for related tasks/notes. (Not implemented yet: Tasks created with assigned tags inherit metadata from the tag's metadata, like due dates or priority, if they don't already have it explicitly set.)

Entities can have any number of properties, and properties can be freely user defined. There are some required properties that are present
on all entities:

- `id`: unique ID number to identify entity.

- `type`: entity type; `task`, `note`, or `tag`.

- `created` timestamp of when node was originally created.

- `children`: a list of nodes that are children of the node.

- `parents`: a list of nodes that are parents of the node.

Children and parents are arcs, from a mathematical perspective. Dote always maintains parity between them, i.e. when you remove a child
from an entity, that child has the entity removed from its parent list.


Some common properties that have some sort of special handling:

- `name`: name of the entity, used for matching or searching entities.

- `body`: text to store with the entity.

- `tags`: a list of tags applied to the entity. Under the hood, this is a subset of the `parents` property, and is a shorthand for managing tags.

- `completed`: marks if an entity is complete. Those entities are not rendered most of the time.

- `updated`: timestamp of when node was last updated. Managed automatically.

(custom behaviors not implemented for these yet:)
- `target`: an estimated date by which you expect to complete a task, or want to have it completed by.

- `deadline`: a date you must complete a task by.

- `priority`: an ordering for task completion importance, scaled with the current date and `deadline` and `target`.



## Dote command line syntax

`dote create` and `dote modify` commands follow the following format:

```
dote [action] [name/fields] $ [body/fields]
```

- `action`: one of the following commands, or user defined commands
    - `todo`: create a new task
    - `note`: create a new note
    - `tag`: create a new tag
    - `modify`: modify an existing entity
    - `done`: mark an entity as complete
    - `delete`: delete an entity
- `name`: any number of arguments representing `name` property of entity, concatenated together.
- `$`: Literal dollar sign character, surrounded by spaces. Defines boundary between name and body.
- `body`: any number of arguments representing `body` property, concatenated together.
- `fields`: any single argument starting with any single symbol operand (see below). Used to specify arbitrary properties of the entity (tags, date, etc). If the property is a string, multiple arguments with the same symbol operand will be concatenated.

*example*: `dote todo go to =10/27 grocery store $ @outside get salad and cheese @chores and dressing`

This command would create a new task entity with a due date of 10/27, with tags named 'outside' and 'chores', the name 'go to grocery store' and the body 'get salad and cheese and dressing'.



`dote print` commands follow the following format:

```
dote [action] [filters] [entity name/id]
```

- `action`: `print` or a user defined command
- `filter`: any number of arguments matching filters. Built in filters are `all`, `default`, `direct`, `loose`, `tags`, `todos`, `notes`.
- `entity name`: the first characters of an entity's `name` field, any amount to match the entity uniquely.
- `entity id`: the id of an entity you want to match

*example*: `dote print todos tags outside`

This command would output entities that are children of the entity named `outside` that pass the filters `todos` and `tags`. (as well as `outside` itself).


*example*: `dote print`

This command would output entities matching the filter `default`.



Other dote commands (like `delete`, `done`) follow the format:

```
dote [action] [entity name/id]
```


### Operands

These symbols are not considered meaningful by Bash, and are thus safe to use for field names. The symbol/field name relationships are
defined in user configs under `action_lookup`.

`+ - / _ ^ % @ ,`

These symbols are sometimes considered meaningful by Bash, so be aware-however, in most cases for dote, are fine.

`$ = [ ] { } . :`

You can always quote arguments and use any symbols you'd like.

If you're using another shell, like Fish, you'll need to change those symbols in dote's configuration file to something safe for your shell.
Also, be aware that this list is not accurate in other contexts than dote.


### Flags

Supported flags are:
    - `-c [path]`: specify config location
    - `-d [path]`: specify datafile location

## Customizing

Dote's behavior is customizable to a high degree, and infinitely so if you're comfortable using Lua. The default configs contain every
config field, described in those files.

Custom actions and filters are part of those configs, and can access dote's libraries for item management and rendering freely.

