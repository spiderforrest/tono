##Tono (TOdo-NOte) or maybe Dote (toDO-noTE) or something else idk

A todo and note taking system centered around dependencies and priorities.
Inspiration taken from [paradigm/chore](https://github.com/paradigm/chore)


Project plan, written in the planned format for the pretty file:

```
#tono $03/03 $mid @portfolio &1 [
    X write this todo &2 >3
    settle on final syntax &3 <2 (
        current syntax plan is:
        @ for tag
        $ for due date and priority
        # for project
        <>  for soft dependency
        [] for hard dependency
        & for uuid for linking to
        () for an aside, for writing out note like this
    )
    settle on JSON naming scheme &4 (
        id: int
        type: str (item, project, tag)
        name: str
        body: str (stuff in parenthesis)
        due: date
        tags: str array
        projects: str array
        hardSupers: str array
        hardSubs: str array
        softSupers: str array
        softSubs: str array
    )

    parse script $low
    pretty generate script
    graph renderer
    cli i/o script $high <
        add
        done
        remove/delete
        modify
        undo $low
        list/show
    >
    parse dates and adjust priority $low
```
