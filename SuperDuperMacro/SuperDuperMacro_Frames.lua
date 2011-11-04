local f

f = CreateFrame("Button", "$parent_saveAsButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_mainFrame_saveButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_mainFrame_saveButton)
f:SetHeight(sdm_mainFrame_saveButton:GetHeight())
f:SetText("Save As...")
f:SetScript("OnClick", sdm_SaveAsButtonClicked)
sdm_SetTooltip(f, "Saves a copy of the current item. You may change the type, or make it global or character-specific.")

f = CreateFrame("Button", "$parent_downgradeButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_mainFrame_deleteButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_mainFrame_deleteButton)
f:SetHeight(sdm_mainFrame_deleteButton:GetHeight())
f:SetText("Downgrade")
f:SetScript("OnClick", sdm_DowngradeButtonClicked)
sdm_SetTooltip(f, "Turns this macro into a default macro. Anything over 255 characters will be lost.")

f = CreateFrame("Button", "$parent_claimButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetPoint("TOPLEFT", sdm_mainFrame_getLinkButton, "BOTTOMLEFT")
f:SetPoint("RIGHT", sdm_mainFrame_getLinkButton)
f:SetHeight(sdm_mainFrame_getLinkButton:GetHeight())
f:SetText("Claim")
f:SetScript("OnClick", sdm_ClaimButtonClicked)
sdm_SetTooltip(f, "Did you know that character-specific items can belong to multiple characters? Click this button to claim this item for your current character.")

f = CreateFrame("Button", "$parent_disownButton", sdm_mainFrame, "UIPanelButtonTemplate")
f:SetAllPoints(sdm_mainFrame_claimButton)
f:SetText("Disown")
f:SetScript("OnClick", sdm_DisownButtonClicked)
sdm_SetTooltip(f, "Removes this item from your current character's list. Other characters will still be able to use it.")

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