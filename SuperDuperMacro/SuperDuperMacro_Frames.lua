local f

-----------------------------------------
--[[ Creation of the main SDM window ]]--
-----------------------------------------

-- The following few lines are a bit weird, but they ensure that:
-- (1) when the user presses escape, the SDM frame will hide,
-- (2) when that happens, SDM will get a chance to show a dialog box, and
-- (3) the game menu doesn't show unless there were no windows open when escape was pressed.
tinsert(UISpecialFrames, "sdm_mainFrame")
hooksecurefunc("CloseSpecialWindows", function()
	sdm_mainFrame:Show()
	sdm_Quit()
end)

-- Red buttons:

f = CreateFrame("Button", "sdm_quitButton", sdm_mainFrame, "UIPanelCloseButton")
f:SetPoint("TOPRIGHT", 3, -8)
f:SetScript("OnClick", function() sdm_Quit() end)

f = CreateFrame("Button", "sdm_aboutButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("About SDM")
f:SetWidth(100)
f:SetHeight(19)
f:SetPoint("RIGHT", sdm_quitButton, "LEFT", 5,0)
f:SetScript("OnClick", sdm_About)

f = CreateFrame("Button", "sdm_linkToMacroFrame", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Standard Macros")
f:SetWidth(125)
f:SetHeight(19)
f:SetPoint("TOPLEFT", 68,-14)
f:SetScript("OnClick", function() sdm_Quit(" ShowMacroFrame()") end)
sdm_SetTooltip(f, "Show the default macro interface")

f = CreateFrame("Button", "sdm_newButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("New")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("TOPLEFT", 75, -42)
f:SetScript("OnClick", sdm_NewButtonClicked)
sdm_AddToExclusiveGroup(f, "centerwindows", true)
sdm_SetTooltip(f, "Create a new macro or script")

f = CreateFrame("Button", "sdm_sendReceiveButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Send/Receive")
f:SetWidth(120)
f:SetHeight(22)
f:SetPoint("TOPLEFT", sdm_newButton, "TOPRIGHT")
f:SetScript("OnClick", function() sdm_sendReceiveFrame:Show() end)
sdm_SetTooltip(f, "Share macros with your friends")

f = CreateFrame("Button", "sdm_saveButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Save")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("BOTTOMRIGHT", -8,14)
f:SetScript("OnClick", function()
	sdm_Edit(sdm_macros[sdm_currentEdit], sdm_mainFrame_editScrollFrame_text:GetText())
	sdm_UpdateList()
end)

f = CreateFrame("Button", "sdm_deleteButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Delete")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_saveButton, "LEFT")
f:SetScript("OnClick", sdm_DeleteButtonClicked)

f = CreateFrame("Button", "sdm_usageButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Usage...")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_deleteButton, "LEFT")
f:SetScript("OnClick", function() sdm_ShowUsage(sdm_macros[sdm_currentEdit]) end)

f = CreateFrame("Button", "sdm_changeIconButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("Change Name/Icon")
f:SetWidth(150)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_usageButton, "LEFT")
f:SetScript("OnClick", function() sdm_changeIconFrame:Show() end)
sdm_AddToExclusiveGroup(f, "centerwindows", true)

f = CreateFrame("Button", "sdm_saveAsButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_saveButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_saveButton)
f:SetHeight(sdm_saveButton:GetHeight())
f:SetText("Save As...")
f:SetScript("OnClick", sdm_SaveAsButtonClicked)
sdm_SetTooltip(f, "Saves a copy of the current item. You may change the type, or make it global or character-specific.")

f = CreateFrame("Button", "$parent_downgradeButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_deleteButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_deleteButton)
f:SetHeight(sdm_deleteButton:GetHeight())
f:SetText("Downgrade")
f:SetScript("OnClick", sdm_DowngradeButtonClicked)
sdm_SetTooltip(f, "Turns this macro into a default macro. Anything over 255 characters will be lost.")

f = CreateFrame("Button", "$parent_claimButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_usageButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_usageButton)
f:SetHeight(sdm_usageButton:GetHeight())
f:SetText("Claim")
f:SetScript("OnClick", sdm_ClaimButtonClicked)
sdm_SetTooltip(f, "Did you know that character-specific items can belong to multiple characters? Click this button to claim this item for your current character.")

f = CreateFrame("Button", "$parent_disownButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetAllPoints(sdm_mainFrame_claimButton)
f:SetText("Disown")
f:SetScript("OnClick", sdm_DisownButtonClicked)
sdm_SetTooltip(f, "Removes this item from your current character's list. Other characters will still be able to use it.")

f = CreateFrame("Button", "sdm_newFolderButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetText("New Folder")
f:SetWidth(100)
f:SetHeight(22)
f:SetPoint("RIGHT", sdm_usageButton, "LEFT", -304,0)
f:SetScript("OnClick", function()
	sdm_newFolderFrame:Show()
	sdm_newFolderNameInput:SetFocus()
end)
sdm_AddToExclusiveGroup(f, "centerwindows", true)

sdm_SetTooltip(sdm_mainFrame_iconSizeSlider, "Change the display size of the macros in the list above.")
sdm_SetTooltip(sdm_mainFrame_collapseAllButton, "Expand/collapse all folders")
sdm_SetTooltip(sdm_mainFrame_typeFilterDropdown, "Show/hide certain macros in the list")
sdm_SetTooltip(sdm_mainFrame_charFilterDropdown, "Show/hide certain macros in the list")

-- other stuff (to be copied from frames.xml)

--------------------------------------------
--[[ Creation of the "New Macro" window ]]--
--------------------------------------------

-- Radio buttons:

function sdm_FancifyNewRadioButton(button, colorCode, text)
	local fs = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fs:SetPoint("LEFT", button, "RIGHT")
	fs:SetText(text)
	if colorCode then
		local _,outline,_,fill,text = button:GetRegions()
		local r,g,b = sdm_GetColor(colorCode)
		outline:SetVertexColor(r,g,b)
		fill:SetVertexColor(r,g,b)
		text:SetTextColor(r,g,b)
	end
end

f = CreateFrame("CheckButton", "sdm_buttonRadio", sdm_newFrame, "SendMailRadioButtonTemplate")
f:SetPoint("TOPLEFT", 15,-15)
f:SetScript("OnClick", function()
	sdm_buttonRadio:SetChecked(1)
	sdm_floatingRadio:SetChecked(nil)
	sdm_scriptRadio:SetChecked(nil)
end)
f:SetChecked(1)
sdm_FancifyNewRadioButton(f, "b", "Button Macro")
sdm_SetTooltip(f, "Button macros can be placed on your action bars. However, you can only have a limited number of these. They can also be called with a slash command.")

f = CreateFrame("CheckButton", "sdm_floatingRadio", sdm_newFrame, "SendMailRadioButtonTemplate")
f:SetPoint("TOPLEFT", sdm_buttonRadio, "BOTTOMLEFT")
f:SetScript("OnClick", function()
	sdm_buttonRadio:SetChecked(nil)
	sdm_floatingRadio:SetChecked(1)
	sdm_scriptRadio:SetChecked(nil)
end)
sdm_FancifyNewRadioButton(f, "f", "Floating Macro")
sdm_SetTooltip(f, "You can make as many floating macros as you like, but they cannot be placed on your action bars. They can called in other macros via a slash command.")

f = CreateFrame("CheckButton", "sdm_scriptRadio", sdm_newFrame, "SendMailRadioButtonTemplate")
f:SetPoint("TOPLEFT", sdm_floatingRadio, "BOTTOMLEFT")
f:SetScript("OnClick", function()
	sdm_buttonRadio:SetChecked(nil)
	sdm_floatingRadio:SetChecked(nil)
	sdm_scriptRadio:SetChecked(1)
end)
sdm_FancifyNewRadioButton(f, "s", "Script")
sdm_SetTooltip(f, "Scripts are blocks of lua code. You can call these with a slash command or a function call.")

f = CreateFrame("CheckButton", "sdm_globalRadio", sdm_newFrame, "SendMailRadioButtonTemplate")
f:SetPoint("LEFT", sdm_buttonRadio, "RIGHT", 103,0)
f:SetScript("OnClick", function()
	sdm_globalRadio:SetChecked(1)
	sdm_charspecRadio:SetChecked(nil)
end)
f:SetChecked(1)
sdm_FancifyNewRadioButton(f, nil, "Global")
sdm_SetTooltip(f, "Selecting 'Global' will make this available to all characters.")

f = CreateFrame("CheckButton", "sdm_charspecRadio", sdm_newFrame, "SendMailRadioButtonTemplate")
f:SetPoint("TOPLEFT", sdm_globalRadio, "BOTTOMLEFT")
f:SetScript("OnClick", function()
	sdm_globalRadio:SetChecked(nil)
	sdm_charspecRadio:SetChecked(1)
end)
sdm_FancifyNewRadioButton(f, nil, "Character-specific")
sdm_SetTooltip(f, "Selecting 'Character-specific' will make this available only to select characters. Use the 'Claim' and 'Disown' buttons to enable or disable it for individual characters.")

-- Text input box:

f = CreateFrame("EditBox", "sdm_newMacroNameInput", sdm_newFrame, "InputBoxTemplate")
f:SetAutoFocus(false)
f:SetWidth(200)
f:SetHeight(26)
f:SetPoint("TOPLEFT", sdm_scriptRadio, "BOTTOMLEFT", 50,0)
f:SetScript("OnEscapePressed", function() sdm_newMacroNameInput:ClearFocus() end)
f:SetScript("OnEnterPressed", function() sdm_createMacroButton:Click() end)
local fs = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
fs:SetPoint("RIGHT", f, "LEFT", -5,0)
fs:SetText("Name: ")

-- Red buttons:

f = CreateFrame("Button", "sdm_createMacroButton", sdm_newFrame, "UIPanelButtonTemplate")
f:SetText("Create")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("TOPLEFT", sdm_newMacroNameInput, "BOTTOMLEFT")
f:SetScript("OnClick", sdm_CreateMacroButtonClicked)
local flash = f:CreateTexture("sdm_createMacroButton_flash", "OVERLAY")
flash:SetTexture("Interface\\Buttons\\UI-Panel-Button-Glow")
flash:SetBlendMode("ADD")
flash:SetTexCoord(0, .75, 0, .609375)
flash:SetPoint("BOTTOMLEFT", -7,-7)
flash:SetPoint("TOPRIGHT", 7,7)
flash:Hide()

f = CreateFrame("Button", "sdm_cancelNewMacroButton", sdm_newFrame, "UIPanelButtonTemplate")
f:SetText("Cancel")
f:SetWidth(80)
f:SetHeight(22)
f:SetPoint("LEFT", sdm_createMacroButton, "RIGHT")
f:SetScript("OnClick", sdm_CancelNewMacroButtonPressed)

-----------------------------------------------
--[[ Creation of the "Send/Receive" window ]]--
-----------------------------------------------

sdm_SetTooltip(sdm_sendReceiveFrame_sendButton, "Make sure that your recipient clicks 'Receive' before you click 'Send'.")
sdm_SetTooltip(sdm_sendReceiveFrame_receiveButton, "Once you have received the macro, click the glowing 'Create' button to save it.")

---------------------------------------------------------
--[[ Buttons that we add to the default macro window ]]--
---------------------------------------------------------

function sdm_CreateDefaultMacroFrameButtons()
	local f

	--Create the button that links from the default macro frame to the SDM frame
	f = CreateFrame("Button", "$parent_linkToSDM", MacroFrame, "UIPanelButtonTemplate")
	f:SetWidth(150)
	f:SetHeight(19)
	f:SetPoint("TOPLEFT", 68, -14)
	f:SetText("Super Duper Macro")
	f:SetScript("OnClick", function() 
		HideUIPanel(MacroFrame)
		sdm_mainFrame:Show() 
	end)
	sdm_SetTooltip(f, "Open Super Duper Macro, an advanced macro interface that lets you create longer macros")

	--Create the button that turns a regular macro into a Super Duper macro
	f = CreateFrame("Button", "$parent_convertToSuper", MacroFrame, "UIPanelButtonTemplate")
	f:SetPoint("TOPLEFT", MacroDeleteButton, "TOPRIGHT")
	f:SetPoint("BOTTOMRIGHT", MacroNewButton, "BOTTOMLEFT")
	f:SetText("Upgrade!  ")
	local t = f:CreateTexture()
	margin = 0.25 * f:GetHeight()
	t:SetPoint("TOPRIGHT", f, "TOPRIGHT", -margin, -margin)
	t:SetPoint("BOTTOM", f, "BOTTOM", 0, margin)
	t:SetWidth(t:GetHeight())
	t:SetTexture("Interface\\AddOns\\SuperDuperMacro\\SDM-Icon.tga")
	local t2 = f:CreateTexture(nil, "OVERLAY")
	t2:SetTexture(t:GetTexture())
	t2:SetAllPoints(t)
	local t3 = f:CreateTexture(nil, "HIGHLIGHT")
	t3:SetTexture(t:GetTexture())
	t3:SetAllPoints(t)
	f:SetScript("OnClick", sdm_UpgradeButtonClicked)
	sdm_SetTooltip(f, "Turn the current macro into a Super Duper Macro, allowing you to make it longer")

	-- The following three frames are only showed when SDM's "Change Name/Icon" button is clicked.  Clicking this button hijack's the default MacroPopupFrame and modifies it to our needs.

	-- Create the "Different name on button" checkbox
	f = CreateFrame("CheckButton", "$parent_buttonTextCheckBox", MacroPopupFrame, "UICheckButtonTemplate")
	f:SetWidth(20)
	f:SetHeight(20)
	f:SetPoint("TOPLEFT", 25, -18)
	f:SetScript("OnClick", function() 
		sdm_buttonTextCheckBoxClicked(MacroPopupFrame_buttonTextCheckBox:GetChecked()==1) 
	end)
	f:Hide()

	-- Create the "Cancel" button
	f = CreateFrame("Button", "$parent_sdmCancelButton", MacroPopupFrame, "UIPanelButtonTemplate")
	f:SetWidth(78)
	f:SetHeight(22)
	f:SetPoint("BOTTOMRIGHT", -11, 13)
	f:SetText(CANCEL)
	f:SetScript("OnClick", function() 
		sdm_changeIconFrame:Hide()
	end)

	-- Create the "Okay" button
	f = CreateFrame("Button", "$parent_sdmOkayButton", MacroPopupFrame, "UIPanelButtonTemplate")
	f:SetWidth(78)
	f:SetHeight(22)
	f:SetPoint("RIGHT", MacroPopupCancelButton, "LEFT", -2, 0)
	f:SetText(OKAY)
	f:SetScript("OnClick", sdm_ChangeIconOkayed)
end