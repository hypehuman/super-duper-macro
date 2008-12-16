Super Duper Macro
version 1.3.1
by hypehuman

Open the interface by typing /sdm

This addon allows you to create macros beyond the 255-character limit, and even beyond the 1023-character macrotext limit.  However, no individual line in a macro may be more than about 1000 characters.  The number of lines is virtually unlimited.

This mod allows you to make two types of macros:
¥ button macros ("b") can be placed on your action bar because they tie themselves to a regular macro.  Therefore, you can only make a limited number of these (36 global and 36 character-specific for each character).  To set an icon for a button macro, use the regular macro interface (/macro).
¥ floating macros ("f"), do not have buttons, and are accessed by /click.  You can make as many of these as you want.
¥ You can also make lua scripts ("s") of unlimited length that you can call using "/sdm run <name>" or via sdm_RunScript("name")

I haven't yet made the interface as pretty as I'd like (I'm just learning xml), and I haven't put in all the error handling features that I want to.  Some of them are:

¥ Clickable menu of macros
¥ Add the ability to change button-macro icons from within the SDM interface (currently you have to switch over to the regular macro window to do this)

Over the next few weeks, I'm going to be updating the interface and adding features.  If anyone has an idea, please let me know on wowinterface.com, or add it yourself and upload it :)  I haven't gotten a lot of feedback on this addon, but I know people have been using it.  So please let me know what you like about it and what you don't!

Special thanks to:
¥ SuperMacro, which inspired the idea for this addon.
¥ Behaviors, from which I shamelessly copied many UI elements.



Change Log

1.3.1 (12/16/08)
¥ÊFixed an occasional bug with the "Get Link" and "Delete" buttons
¥ Blocked you from attempting to make more button macros than the standard macro interface can hold

1.3 (12/15/08)
¥ You can now use the addon to store long scripts and call them via a function or slash command.
¥ SDM now keeps track of the button macros it creates, and deletes orphaned ones upon login. If you are upgrading from a previous version, you can delete the old button macros that SDM created (the text of the new ones all start with "#sdm").
¥ Because of this, SDM will no longer ever replace your macros, and their names do not need to be unique at all.  Floating macros and Scripts still have some restrictions on naming, you will get a warning it you try to violate them.
¥ Added many UI improvements to make working with the addon more intuitive:
 Ð Pressing tab will now add four spaces
 Ð Pressing enter will now be equivalent to the appropriate button click
 - Moved some buttons around to more appropriate places
 - Added buttons that link between the regular macro window and the SDM window
 Ð Buttons will now "gray out" when appropriate
 Ð The SDM window will now become unresponsive during confirmation dialogs

1.2 (12/13/08)
Fixed a bug that caused major problems when there were no macros in the list.

1.1 (12/12/08)
More UI improvements. Some UI elements are still placeholders.

1.0 (11/13/08)
just two minor updates in code to make it 3.0-ready. More UI improvements to come!