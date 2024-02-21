# Todofile

yeah yeah listen we gotta track stuff somehow before dote exists

## webclient/doteui

### Preliminary steps for GUI/web client

- ~draw primary UI mockup~
    - item editing mockup (slideup-from-bottom window?)
    - item relationship editing mockup (using drag+drop library?)
    - single-item ui element mockup (deciding what info should be positioned where, etc)
- ~decide on tooling (or yknow just vanilla JS)~
    - I'm sick of looking at sites for frameworks sponsored by panera bread i'm writing vanilla js
    - okay hold on a library with drag+drop functions would be super useful
    - hey, [you rang?](https://interactjs.io/)

#### Assorted doteui implementation details

- allie: just write func signatures for transaction lib while writing ui code, spood will adapt lib code

### Goal for web client MVP

- fully functional but not pretty web client
- can use as daily driver on phone + desktop
- supports todos, notes, and tags, and properly renders their parent-child relationships visually
- client/server communication

### farther out features

- user data encryption
- client delivers reminders/notifs via operating system notifications
    - will probably need to package into an app for this on mobile
- ability to share items with users on same doteserver, with or without shared item state
- ability to use markdown/custom text rendering/parsing in item bodies
    - allie this is your mindmap thing, check your project ideas dir
- viewmode `daily` or `task` that generates a suggested list of tasks for you to choose from based on due date, priority, other factors
- viewmode `progress` that shows your history of when you complete tasks over time
- viewmode `timechunk` for allocating worktime, running a visual timer to track your time
    - probably track worktime on tasks, storing data in todo items
    - may combine this with `daily`/`task` mode
- new item type: `tracker` or `log`, which is used to track user data over time (mood tracking, whether you took your meds, period tracking, whatever`
    - `tracker tracker` viewmode, for accessing your trackers quickly
- user-facing documentation that gives guidance, advice, and recommendations for how to most effectively use dote in your own life

### nice to have but not priority

- secret undocumented toggle that when on praises you for completing tasks
