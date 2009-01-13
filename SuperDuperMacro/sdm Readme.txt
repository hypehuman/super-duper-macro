Super Duper Macro
version 1.5.1
by hypehuman

Check for updates at http://www.wowinterface.com/downloads/info10496

Open the interface by typing /sdm

This addon allows you to create macros beyond the 255-character limit, and even beyond the 1023-character macrotext limit.  However, no individual line in a macro may be more than 1023 characters long (you will get a warning).  The number of lines is unlimited.

This mod allows you to make two types of macros:
¥ button macros ("b") can be placed on your action bar because they tie themselves to a regular macro.  Therefore, you can only make a limited number of these (36 global and 36 character-specific for each character).  To set an icon for a button macro, use the regular macro interface (/macro).
¥ floating macros ("f"), do not have buttons, and are accessed by /click.  You can make as many of these as you want.
¥ You can also make lua scripts ("s") of unlimited length that you can call using "/sdm run <name>" or via sdm_RunScript("name")

Features yet to be implemented:
¥ Clickable, scrollable menu of macros with collapsible drop-down bars (like the quest log interface)
¥ A way to change button-macro icons from within the SDM interface (currently you have to switch over to the regular macro window to do this)
¥ Allow users to share macros with each other in-game

Suggestions and bug reports are always welcome.  You can post comments on the wowinterface.com page for this addon, or if you want to add something yourself, you can upload it in the "Optional Files" tab.

Special thanks to:
¥ SuperMacro, which inspired the idea for this addon.
¥ Behaviors, from which I shamelessly copied many UI elements.
¥ÊAll the regulars on the UI & Macro forums, who have been guiding me through this process.



Change Log

1.5.1 (1/12/09)
¥ÊMinor bug fixes

1.5 (1/12/09)
¥ÊAdded the ability to share macros with other players (click "Send/Receive" to check it out!)
¥ Fixed a bug where the Save button was sometimes inappropriately disabled

1.4.1 (1/9/09)
¥ÊFixed a minor bug that sometimes occurred while loading

1.4 (1/8/09)
¥ Added an option to show/hide the text on macro buttons
¥ Fixed ">" to be more accurate
¥ SDM will no longer attempt to create, delete, or modify macros during combat.  You can still do these things, but the changes will not take effect until after combat.
¥ÊDeleting floating macros will now actually disable them
¥ Greatly increased the efficiency of operations like saving and deleting
¥ÊIncreased the limit on the length of each line to 1023, and made the number of lines limitless (actually, the maximum length of any string is 2^24 characters, so the limit is somewhere below that, but that's the length of about 20 average novels and it will probably crash your client).
¥ÊChanged the structure of the macro frames to eliminate the chance of a recently discovered "C stack overflow" error on very long macros

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