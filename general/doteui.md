# Doteui client notes

![mockup of doteui overview viewmode](./mockup/overview_mockup_v1.png)

## Design

Doteui is a "single page application" (though without any client-side routing) where page elements are dynamically generated on demand using client-side Javascript.
It's designed to be used on both desktop and touch screen interfaces.

### Viewmodes

Doteui displays user data in different **viewmodes**, selectable via big, obvious, primary UI element.
**Viewmodes** organize, sort, and present the user's data to them in varying formats: one viewmode could organize and sort the user's items by tag, while another might organize them by priority determined by due date.
Viewmodes can have entirely different layouts and designs, too--for example, a calendar view that displays items on their due dates.
Each viewmode has a client-visible name and (not client-visible) render function, allowing users to add their own custom viewmodes if they so desire.

#### Viewmode list

`overview`: renders tree sorted by top-level tags. Ideal for seeing the state of all your projects at a glance.
`debug`: Prints and prettifies the user's JSON datafile directly onto the webpage. For debug purposes.

### Rendering items and the item tree

*See `data.md` for information on how Dote items are structured.*

The exact method of rendering items varies based on the `viewmode` Dote is currently in.
Each `viewmode` should, as its name suggest, provide a *different view or perspective* of the user's data.

For example, the `overview` mode shows everything in the user's tree, with a focus on items and elements relevant to the current moment; thus, by default, when opening in this mode, completed tasks and item bodies are collapsed and minimized. It's an overview of everything relevant to when you retrieve the data, in other words.

#### In `overview` viewmode

When items with children are displayed (and Doteui is in a viewmode that displayes items in a list format), they're rendered in a "cascading list" style, where each item's children are displayed within their parent's UI element.
Items in `overview` are rendered like this.

(`+` symbols denote toggle-able section show/hide buttons.)

```
= --------------------------------------------------------------------------------------------------- =
| + [item title] | ([item type]) [show/hide body toggle (if body exists)] [item creation/update date] |
| \ [ if set to display and existent, body displays here, otherwise this section is absent]           |
|  | [ other item properties on this line: target, deadline, so on ]                                  |
|  | + ------------------------------------------------------------------------------------------ = - =
|  | \ [ item children, if any exist ]                                                            |   |
|  |  = ----------------------------------------------------------------------------------------- = - =
= --------------------------------------------------------------------------------------------------- =
```
