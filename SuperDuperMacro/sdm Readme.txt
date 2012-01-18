Super Duper Macro
version 2.4.5
by hypehuman

Check for updates at http://www.wowinterface.com/downloads/info10496

Open the interface by typing /sdm

This addon allows you to create macros beyond the 255-character limit, and even beyond the 1023-character macrotext limit.  However, no individual line in a macro may be more than 1023 characters long (you will get a warning).  The number of lines is unlimited.  Super Duper Macro also allows you to share macros with your friends in-game.

This mod allows you to make two types of macros:
¥ Button macros are just like regular macros, but they can be as long as you want.  You cannot make an unlimited number of them; they share a limit with your regular macros (36 global and 18 character-specific for each character).
¥ Floating macros do not have buttons, and are accessed by /click.  You can make as many of these as you want.
¥ You can also make lua scripts of unlimited length that you can call using "/sdm run <name>" or via sdm_RunScript("name")

Suggestions and bug reports are always welcome.  You can post comments on the wowinterface.com page for this addon, or if you want to add something yourself, you can upload it in the "Optional Files" tab.

Special thanks to:
¥ SuperMacro, which inspired the idea for this addon.
¥ÊAll the regulars on the UI & Macro forums, who have been guiding me through this process.



Change Log

2.4.5 (1/17/12)
¥ÊFixed a bug that caused the "Change Name/Icon" window to sometimes be unresponsive
¥ÊNow the "Change Name/Icon" always deselects the icon when it opens so that you don't accidentally change the icon of one of your macros

2.4.4 (12/17/11)
¥ÊFixed a bug where the button on the macro frame that opens SDM would sometimes appear in the wrong place.

2.4.3 (11/30/11)
¥ÊRe-enabled the text that shows how many more button macros you can create

2.4.2 (11/30/11)
¥ÊFixed a minor error that occurs when running SDM for the first time
¥ÊWhen attempting to pick up a macro during combat, you will get an error message created by SDM instead of Blizzard's "Interface action failed due to an addon".

2.4.1 (11/30/11)
¥ÊUpdated for version 4.0 - you will lose any custom icons for your macros.  Sorry!

2.4 (11/20/11)
¥ÊFixed the Send/Receive feature; now you can share macros with your friends again, as long as you are both using the latest version.
¥ Fixed a bug where buttons on the SDM frame would sometimes stretch away
¥ÊMany UI Improvements

2.3 (11/16/11)
¥ÊThe SDM frame now hides when you press escape!
¥ÊAdded more tooltips; still more to come

2.2.1 (11/15/11)
¥ÊFixed a bug where the macro list sometimes became unclickable

2.2 (11/4/11)
¥ÊUpgraded macros will now appropriately change their icons based on the macro code (unless an icon other than the Question Mark icon was selected).  If you upgraded a macro with version 2.1, you will need to manually change the icon to the Question Mark icon.
¥ÊAdded a "Downgrade" button that converts a Super Duper macro into a standard macro
¥ÊAdded a "Claim"/"Disown" button that allows you to have a single character-specific macro or script that applies to multiple characters
¥ÊAdded a "Save As..." button that allows you to save an existing macro as a different type or character.  For example, you can save a button macro as a floating macro if you want to free up a macro slot.
¥ÊSeveral UI improvements; more to come!

2.1 (10/19/11)
¥ÊAdded an "Upgrade" button to the standard macro frame, allowing you to convert a standard macro into a Super Duper macro
¥ÊRemoved an overbearing version-checking system

2.0 (10/16/11)
¥ Incorporated compatibility updates by survivorx and ambro

1.8.3 (2/26/09)
¥ÊChanging the name of a macro will now properly update the title text above the edit box.
¥ÊImproved the "/sdm test" function.  Please re-test it and submit your results!

1.8.2 (2/26/09)
¥ÊFixed a bug that caused the image on button macros to show as a question mark more often than necessary.
¥ÊAdded a command "/sdm test" that does nothing but check some nyi code.  Please run this command and report the results at wowinterface.com.

1.8.1 (2/21/09)
¥ÊSDM no longer conflicts with LayMacroTooltip or with other addons that modify the macro frame.

1.8 (2/20/09)
¥ÊAdded the option of creating folders to organize your macros
¥ÊNumerous minor UI improvements

1.7 (2/8/09)
¥ÊMade the macro list better
 - Color-coded the different macro types
 - Created a slider below the menu to adjust the size of the icons
 - Added drop-down menus to filter the list by type and character
¥ÊChanged the storage of macros in preparation for a future version that will include a sortable macro list with user-defined folders
¥ÊBug fixes
 - The save confirmation dialog box now shows while dead
 - Fixed a typo in the "Usage..." text for scripts

1.6.1 (1/27/09)
¥ÊFixed a serious bug that happened upon login after leaving "different name on button" blank.  You may now safely leave it blank if you wish to show no text on the button.

1.6 (1/19/09)
¥ Changed the slash command to run a floating macro.  Also added a command to run button macros.  Click the "Usage..." button for more details.
¥ÊAdded an interface for changing the name and icon of a macro within the SDM window.
¥ Button macro names now conflict with each other (unless they are specific to different characters)
¥ Disallowed some characters in macro/script names because they were causing problems.  You may find that some of these problematic characters still work on button macros, for which you can select a different name in the Change Name/Icon frame.
¥ÊChanged the appearance of button macros when viewed in the default macro frame
¥ Added a clickable, scrolling menu of macros.  This will be further improved later.
¥ÊSeveral efficiency improvements.  As a consequence, your SDM-created button macros will be removed from action bars and lose thieir icons.  Sorry!

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
 - Pressing tab will now add four spaces
 - Pressing enter will now be equivalent to the appropriate button click
 - Moved some buttons around to more appropriate places
 - Added buttons that link between the regular macro window and the SDM window
 - Buttons will now "gray out" when appropriate
 - The SDM window will now become unresponsive during confirmation dialogs

1.2 (12/13/08)
Fixed a bug that caused major problems when there were no macros in the list.

1.1 (12/12/08)
More UI improvements. Some UI elements are still placeholders.

1.0 (11/13/08)
just two minor updates in code to make it 3.0-ready. More UI improvements to come!