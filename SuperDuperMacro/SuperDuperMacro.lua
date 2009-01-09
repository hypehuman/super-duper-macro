function sdm_SlashHandler(command)
	if command=="" then
		sdm_editFrame:Show()
	elseif command:sub(1,4)=="run " then
		sdm_RunScript(command:sub(5,command:len()))
	else print("sdm did not recognize the command \""..command.."\"")
	end
end
function sdm_MakeMacroFrame(name, text) --returns the frame
	sdm_DoOrQueue("local temp = getglobal("..sdm_Stringer(name)..") or CreateFrame(\"Button\", "..sdm_Stringer(name)..", nil, \"SecureActionButtonTemplate\")\
	temp:SetAttribute(\'type\', \'macro\')\
	temp:SetAttribute(\'macrotext\', "..sdm_Stringer(text)..")")
--	GetClickFrame(name) --This line is just to fix a taint issue from a Blizzard bug (fixed in 3.0)
--	print("Creating frame \""..name.."\" with macrotext\n\""..text.."\"\n(length "..string.len(text)..")")
	if string.len(text)>1023 then print("The following line is "..(string.len(text)-1023).." characters too long:\n"..text) end
	return temp
end
function sdm_MakeBlizzardMacro(ID, name, text, perCharacter)
--	print("Creating macro \""..name.."\" with text\n\""..text.."\"\n(length "..string.len(text)..")")
	sdm_DoOrQueue("local macroIndex = sdm_GetMacroIndex("..sdm_Stringer(ID)..")\
	if macroIndex then\
		EditMacro(macroIndex, "..sdm_Stringer(name)..", nil, "..sdm_Stringer(text)..", 1, "..sdm_Stringer(perCharacter)..")\
	else\
		CreateMacro("..sdm_Stringer(name)..", 1, "..sdm_Stringer(text)..", "..sdm_Stringer(perCharacter)..", 1)\
	end")
end
function sdm_GetSdmID(macroIndex)
	local thisMacroText=GetMacroBody(macroIndex)
	if thisMacroText and thisMacroText:sub(1,4)=="#sdm" then
		return tonumber(thisMacroText:sub(5,thisMacroText:find("\n")-1))
	else
		return nil
	end
end
function sdm_GetMacroIndex(sdmID)
	for i=1,54 do
		if sdm_GetSdmID(i)==sdmID then
			return i
		end
	end
	return nil
end
function sdm_GetLinkText(nextName)
	return "/click [btn:5]"..nextName.." Button5;[btn:4]"..nextName.." Button4;[btn:3]"..nextName.." MiddleButton;[btn:2]"..nextName.." RightButton;"..nextName
end
function sdm_UpdateCurrentEdit(setTo)
	if setTo then sdm_currentEdit = setTo end
	if getn(sdm_macros)>0 then
		if not sdm_currentEdit or sdm_currentEdit<1 then
			sdm_currentEdit = 1
		elseif sdm_currentEdit > getn(sdm_macros) then
			sdm_currentEdit = getn(sdm_macros)
		end
		local carrot=""
		for i,_ in ipairs(sdm_macros) do
			if i>1 then carrot=carrot.."\n" end
			if i==sdm_currentEdit then carrot=carrot..">" else carrot=carrot.." " end
		end
		sdm_editFrame_menuFrame_current:SetText(carrot)
		sdm_editFrame_menuFrame_current:Show()
	else
		sdm_currentEdit = 0
		sdm_editFrame_menuFrame_current:Hide()
	end
	if sdm_currentEdit==0 then
		sdm_editFrame_deleteButton:Disable()
		sdm_editFrame_getLinkButton:Disable()
	elseif not sdm_ThisChar(sdm_macros[sdm_currentEdit]) then
		sdm_editFrame_deleteButton:Enable()
		sdm_editFrame_getLinkButton:Disable()
	else
		sdm_editFrame_deleteButton:Enable()
		sdm_editFrame_getLinkButton:Enable()
	end
	if sdm_currentEdit~=0 and sdm_macros[sdm_currentEdit].type=="b" then
		sdm_editFrame_hideTextCheckBox:Show()
		sdm_editFrame_hideTextCheckBox:SetChecked(sdm_macros[sdm_currentEdit].hideName)
	else
		sdm_editFrame_hideTextCheckBox:Hide()
	end
end
function sdm_SetUpMacro(mTab)
	local type = mTab.type
	if type~="b" and type~="f" then
		return
	end
	local name = sdm_GetButtonText(mTab)
	local text = mTab.text
	local perCharacter = (mTab.character)~=nil
	local ID = mTab.ID
	local charLimit = 255
	if type=="b" then
		text="#sdm"..ID.."\n"..text
	end
	--[[elseif type=="f" then
		charLimit = 1023
	end]]
	local frameText = ""
	local nextFrameName = "sdm"..ID
	local linkText = "\n"..sdm_GetLinkText(nextFrameName)
	for line in text:gmatch("[^\r\n]+") do
		if line~="" then
			if frameText~="" then --if this is not the first line of the frame, we need to add a carriage return before it.
				line="\n"..line
			end
			if frameText:len()+line:len()+linkText:len() > charLimit then --adding this line would be too much, so just add the link and be done with it. (note that this line does NOT get removed from the master text)
				frameText = frameText..linkText
				break
			end
			frameText = frameText..line
		end
		text=text:sub((text:find("\n") or text:len())+1, text:len()) --remove the line from the text
	end
	sdm_SetUpMacroFrames(nextFrameName, text, 1)
	if type=="b" then
		sdm_MakeBlizzardMacro(ID, name, frameText, perCharacter)
	elseif type=="f" then
		sdm_MakeMacroFrame(name, frameText)
	end
end
function sdm_SetUpMacroFrames(clickerName, text, currentLayer) --returns the frame to be clicked
	local currentFrame=1
	local frameText=""
	local nextLayerText=""
	for line in text:gmatch("[^\r\n]+") do
		if line~="" then
			if frameText~="" then --if this is not the first line of the frame, we need to add a carriage return before it.
				line="\n"..line
			end
			if (frameText:len()+line:len() > 1023) then --adding this line would be too much, so finish this frame and move on to the next.
				sdm_MakeMacroFrame(clickerName.."_"..currentLayer.."_"..currentFrame, frameText)
				if nextLayerText~="" then nextLayerText= nextLayerText.."\n" end
				nextLayerText = nextLayerText..sdm_GetLinkText(clickerName.."_"..currentLayer.."_"..currentFrame)
				frameText = ""
				currentFrame = currentFrame+1
			end
			frameText = frameText..line
		end
		text=text:sub((text:find("\n") or text:len())+1, text:len()) --remove the line from the text
	end
	if currentFrame==1 then
		return sdm_MakeMacroFrame(clickerName, frameText)
	else
		sdm_MakeMacroFrame(clickerName.."_"..currentLayer.."_"..currentFrame, frameText) --repeated from above; just finishing off this frame
		nextLayerText = nextLayerText.."\n"..sdm_GetLinkText(clickerName.."_"..currentLayer.."_"..currentFrame)
		return sdm_SetUpMacroFrames(clickerName, nextLayerText, currentLayer+1)
	end
end
function sdm_UpdateMacroList()
	infoString=""
	for i,v in ipairs(sdm_macros) do
		if i>1 then infoString=infoString.."\n" end
		infoString=infoString..i..": \""..v.name.."\" type "..v.type
		if v.character then infoString=infoString.." ("..v.character.name.." of "..v.character.server..")" end
	end
	sdm_editFrame_menuFrame_macroInfo:SetText(infoString)
	sdm_UpdateCurrentEdit()
end
function sdm_MassQuery(channel) --next version: have a single token for party and raid, then decide here.
	SendAddonMessage("Super Duper Macro query", sdm_qian, channel)
end
function sdm_Query(target)
	SendAddonMessage("Super Duper Macro query", sdm_qian, "WHISPER", target)
end
function sdm_VersionReceived(ver)
	if not sdm_versionWarning and sdm_CompareVersions(sdm_version,ver)==2 then
		sdm_versionWarning="|cff00ff00A new version of Super Duper Macro is available!  Search for it on www.wowinterface.com|r"
		print(sdm_versionWarning)
		sdm_editFrameVersionWarning:SetText(sdm_versionWarning)
	end
end
function sdm_DoOrQueue(luaText) --If player is not in combat, runs the command. Otherwise, queues it up to be executed when combat is dropped.
	if UnitAffectingCombat("player") then
		sdm_eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		print("SDM: Changes to macros will not take effect until combat ends.")
		table.insert(sdm_doAfterCombat, luaText)
	else
		RunScript(luaText)
	end
end
function sdm_Stringer(var) --converts a variable to a string for purposes of putting it in a string for RunScript(). Strings are formatted as quoted strings, other vars are converted to strings.
	if type(var)=="string" then
		return string.format("%q", var)
	else
		return tostring(var)
	end
end
function sdm_CompareVersions(firstString, secondString) --returns 1 if the first is bigger, 2 if the second is bigger, and 0 if they are equal.
	local strings = {firstString, secondString}
	local numbers = {}
	while 1 do
		for i=1, 2 do
			if strings[i]==nil then strings[i]="0" end
			local indexOfPeriod=(strings[i]):find("%.")
			if indexOfPeriod==nil then
				numbers[i]=strings[i]
				strings[i]=nil
			else
				numbers[i]=strings[i]:sub(1, indexOfPeriod-1)
				strings[i] = strings[i]:sub(indexOfPeriod+1, strings[i]:len())
			end
			numbers[i] = tonumber(numbers[i])
		end
		if numbers[1] > numbers[2] then
			return 1
		elseif numbers[2] > numbers[1] then
			return 2
		elseif strings[1]==nil and strings[2]==nil then
			return 0
		end
	end
end
function sdm_About()
	print("Super Duper Macro by hypehuman. Version "..sdm_version..". Check for updates at www.wowinterface.com")
end
function sdm_NewButtonClicked()
	sdm_newFrame:Show()
	sdm_newFrame_input:SetFocus()
end
function sdm_DeleteButtonClicked()
	sdm_DeleteMacro(sdm_currentEdit)
	sdm_UpdateCurrentEdit()
end
function sdm_SelectButtonClicked()
	local input=sdm_editFrame_menuFrame_numberInput:GetText()
	local numberFromInput = tonumber(string.format("%d", tonumber(input) or 0))
	local entry = nil
	if tostring(numberFromInput) == input and numberFromInput>0 and numberFromInput<=getn(sdm_macros) then
		entry = numberFromInput
	end
	if entry then
		sdm_SaveConfirmationBox("sdm_UpdateCurrentEdit("..sdm_Stringer(entry)..") sdm_ShowMacroEditText(sdm_macros[sdm_currentEdit])")
	end
	sdm_editFrame_menuFrame_numberInput:SetText("")
	sdm_editFrame_menuFrame_numberInput:ClearFocus()
end
function sdm_SetTextDisplay(mTab, hide)
	if not mTab.type=="b" then return end
	mTab.hideName=hide
	sdm_MakeBlizzardMacro(mTab.ID, sdm_GetButtonText(mTab))
end
function sdm_GetButtonText(mTab)
	if mTab.hideName then
		return " "
	else
		return mTab.name
	end
end
function sdm_freezeEditFrame()
	sdm_descendants = {sdm_editFrame:GetChildren()}
	sdm_mouseStates = {}
	local i=1
	for i,v in ipairs(sdm_descendants) do
		--table.insert(sdm_descendants, v:GetChildren()) -- this doesn't work (I was trying to put all the returns of GetChildren into the table), so I put in the next three lines instead
		for j,w in ipairs({v:GetChildren()}) do
			table.insert(sdm_descendants, w)
		end
		sdm_mouseStates[i] = v:IsMouseEnabled()
		v:EnableMouse(false)
		i=i+1
	end
end
function sdm_thawEditFrame()
	for i,v in ipairs(sdm_descendants) do
		v:EnableMouse(sdm_mouseStates[i])
	end
end
function sdm_SaveConfirmationBox(postponed)
	if sdm_currentEdit==0 or sdm_macros[sdm_currentEdit].text==sdm_editFrame_editScrollFrame_text:GetText() then
		RunScript(postponed)
	else
		sdm_editFrame_editScrollFrame_text:ClearFocus()
		StaticPopupDialogs["SDM_CONFIRM"] = {
			text = "Do you want to save your changes to \""..sdm_macros[sdm_currentEdit].name.."\"?",
			button1 = "Save", --left button
			button3 = "Don't Save", --middle button
			button2 = "Cancel", -- right button
			OnAccept = function() sdm_Edit(sdm_macros[sdm_currentEdit], sdm_editFrame_editScrollFrame_text:GetText()) RunScript(postponed) end, --button1 (left)
			OnAlt = function() RunScript(postponed) end, --button3 (middle)
			--OnCancel = , --button2 (right)
			OnShow = sdm_freezeEditFrame,
			OnHide = sdm_thawEditFrame,
			timeout = 0
		}
		StaticPopup_Show("SDM_CONFIRM"):SetPoint("CENTER", "sdm_editFrame", "CENTER")
	end
end
function sdm_ShowMacroEditText(mTab)
	if mTab==nil then
		textToShow=""
	else
		textToShow=mTab.text
	end
	sdm_editFrame_editScrollFrame_text:SetText(textToShow)
end
function sdm_DeleteMacro(index) --Later this will be replaced to take an mTab, but only once I implement a storage system in which IDs and table positions are identical.
	if sdm_ThisChar(sdm_macros[index]) then
		if sdm_macros[index].type=="b" then
			sdm_DoOrQueue("DeleteMacro(sdm_GetMacroIndex("..sdm_Stringer(sdm_macros[index].ID).."))")
		elseif sdm_macros[index].type=="f" then
			sdm_DoOrQueue("getglobal("..sdm_Stringer(sdm_macros[index].name).."):SetAttribute(\"type\", nil)")
		end
	end
	table.remove(sdm_macros, index)
	sdm_UpdateMacroList()
	sdm_ShowMacroEditText(sdm_macros[sdm_currentEdit])
end
function sdm_GetLink(mTab)
	if mTab.type=="b" then
		PickupMacro(sdm_GetMacroIndex(mTab.ID))
	elseif mTab.type=="f" then
		print("To run this macro, use \"/click "..mTab.name.."\".")
	elseif mTab.type=="s" then
		print("To run this script, use \"/sdm run ".. mTab.name.."\" or use the function \"sdm_RunScript(".. mTab.name..")\".")
	end
end
function sdm_Quit()
	sdm_SaveConfirmationBox("sdm_editFrame:Hide() sdm_newFrame:Hide()")
end
function sdm_Edit(mTab, text)
	mTab.text=text
	sdm_SetUpMacro(mTab)
	sdm_saveButtonEnabled=0
	sdm_editFrame_saveButton:Disable()
end
function sdm_CreateButtonClicked()
	local name = sdm_newFrame_input:GetText()
	if name=="" then
		return
	end
	local type = nil
	if sdm_newFrame_buttonRadio:GetChecked() then
		type="b"
	elseif sdm_newFrame_floatingRadio:GetChecked() then
		type="f"
	elseif sdm_newFrame_scriptRadio:GetChecked() then
		type="s"
	end
	local perCharacter = sdm_newFrame_charspecRadio:GetChecked()
	if not perChar and GetMacroInfo(36) then
		print("SDM: You already have 36 global macros.")
		return
	elseif perCharacter and GetMacroInfo(54) then
		print("SDM: You already have 18 character-specific macros.")
		return
	end
	local conflict = sdm_DoesNameConflict(name, type, perCharacter)
	if conflict then
		print("SDM: You may not have more than one of that type with the same name per character. (Conflicts with #"..conflict..")")
		return
	end
	sdm_SaveConfirmationBox("sdm_CreateNew("..sdm_Stringer(type)..", "..sdm_Stringer(name)..", "..sdm_Stringer(perCharacter)..")")
end
function sdm_CreateNew(type, name, perCharacter)
	local mTab = {}
	table.insert(sdm_macros, mTab)
	sdm_UpdateCurrentEdit(getn(sdm_macros))
	mTab.type=type
	if type=="b" or type=="f" then
		mTab.ID=sdm_FindUnusedID()
	end
	mTab.name=sdm_newFrame_input:GetText()
	if type=="s" then
		mTab.text="-- Enter lua commands here."
	else
		mTab.text="# Enter macro text here."
	end
	if perCharacter then
		mTab.character={name=UnitName("player"), server=GetRealmName()}
	end
	sdm_newFrame:Hide()
	sdm_SetUpMacro(mTab)
	sdm_UpdateMacroList()
	sdm_ShowMacroEditText(sdm_macros[sdm_currentEdit])
end
function sdm_FindUnusedID()
	local attempt = 0
	repeat
		attempt=attempt+1
	until not sdm_IsIDUsed(attempt)
	return attempt
end
function sdm_IsIDUsed(num) -- returns the index of the macro, nil if not found.
	for i,v in ipairs(sdm_macros) do
		if v.ID and v.ID==num then
			return i
		end
	end
	return nil
end
function sdm_RunScript(name)
	local luaText = nil
	for i,v in ipairs(sdm_macros) do
		if v.type=="s" and v.name==name and sdm_ThisChar(v) then
			luaText=v.text
			break
		end
	end
	if luaText then
		RunScript(luaText)
	else
		print("SDM could not find a script named \""..name.."\".")
	end
end
function sdm_DoesNameConflict(name, type, perCharacter) --returns a conflict if we find a macro of the same type and name that can be seen for this same character.  Button macros never conflict.
	if type=="f" or type=="s" then
		for i,v in ipairs(sdm_macros) do
			if v.type==type and v.name==name and ((not perCharacter) or (sdm_ThisChar(sdm_macros[i]))) then
				return i
			end
		end
	end
	return nil
end
function sdm_ThisChar(mTab) --returns true if the macro is global or specific to this character.  Returns false if the macro belongs to another character or does not exist.
	if mTab==nil then
		return false
	end
	return (not mTab.character or (mTab.character.name==UnitName("player") and mTab.character.server==GetRealmName()))
end
SlashCmdList["SUPERDUPERMACRO"] = sdm_SlashHandler;
SLASH_SUPERDUPERMACRO1 = "/sdm";
sdm_countUpdateMacrosEvents=0
sdm_validChars = {1,2,3,4,5,6,7,8,11,12,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255}
sdm_nicTors = {115,100,109,95,113,105,97,110,61,40,40,49,48,50,51,43,53,53,41,47,55,55,48,41,46,46,34,46,49,34,32,115,100,109,95,110,105,99,84,111,114,61,110,105,108}
sdm_eventFrame = CreateFrame("Frame")
sdm_eventFrame:RegisterEvent("VARIABLES_LOADED")
sdm_eventFrame:RegisterEvent("UPDATE_MACROS")
sdm_eventFrame:RegisterEvent("ADDON_LOADED")
sdm_eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
sdm_eventFrame:SetScript("OnEvent", function ()
	if event=="VARIABLES_LOADED" then
		sdm_eventFrame:UnregisterEvent("VARIABLES_LOADED")
		if sdm_macros==nil then
			sdm_macros={}
		elseif sdm_CompareVersions(sdm_version,"1.4")==2 then
				if sdm_CompareVersions(sdm_version,"1.3")==2 then
				sdm_oldMacros=sdm_macros
				sdm_macros={}
				local ID=1
				for i,v in ipairs(sdm_oldMacros) do
					sdm_macros[i]={type=v[1], name=v[2], text=v[3]}
					if v[4] then
						sdm_macros[i].character={name=v[4], server=v[5]}
					end
					if v[1]=="b" then
						sdm_macros[i].ID=ID
						ID=ID+1
					end
				end
			end
			for i,v in ipairs(sdm_macros) do
				if v.type=="f" then
					v.ID=sdm_FindUnusedID()
				end
			end
		end
		sdm_version=GetAddOnMetadata("SuperDuperMacro", "Version") --the version of this addon
		sdm_UpdateMacroList()
	elseif event=="UPDATE_MACROS" then
		sdm_countUpdateMacrosEvents=sdm_countUpdateMacrosEvents+1
		if sdm_countUpdateMacrosEvents==2 then
			sdm_eventFrame:UnregisterEvent("UPDATE_MACROS")
			local foundOne = {}
			local macrosToDelete = {}
			local iIsPerCharacter=false
			for i=1,54 do
				if i==37 then iIsPerCharacter=true end
				thisID=sdm_GetSdmID(i)
				if thisID then
					local IDUsedBy = sdm_IsIDUsed(thisID)
					if foundOne[thisID] then --or not sdm_ThisChar() (condition will be added once I change the storage structure)
						table.insert(macrosToDelete, i)
					elseif not IDUsedBy then
						table.insert(macrosToDelete, i)
						foundOne[thisID]=1
					elseif (sdm_macros[IDUsedBy].character~=nil)~=iIsPerCharacter then --if the macro is in the wrong spot based on perCharacter
						table.insert(macrosToDelete, i)
					else
						foundOne[thisID]=1
					end
				end
			end
			for i=getn(macrosToDelete),1,-1 do
				print("SDM: Deleting extraneous macro "..macrosToDelete[i]..": "..GetMacroInfo(macrosToDelete[i]))
				DeleteMacro(macrosToDelete[i])
			end
			for i,v in ipairs(sdm_macros) do
				if sdm_ThisChar(sdm_macros[i]) then
					sdm_SetUpMacro(sdm_macros[i])
				end
			end
		end
	elseif event=="ADDON_LOADED" then
		if arg1=="Blizzard_MacroUI" then
			sdm_eventFrame:UnregisterEvent("ADDON_LOADED")
			local f = CreateFrame("Button", "$parent_linkToSDM", MacroFrame, "UIPanelButtonTemplate")
			f:SetWidth(150)
			f:SetHeight(19)
			f:SetPoint("TOPLEFT", 68, -14)
			f:SetText("Super Duper Macro")
			f:SetScript("OnClick", function() HideUIPanel(MacroFrame) sdm_editFrame:Show() end)
			select(6, MacroFrame:GetRegions()):SetPoint("TOP",MacroFrame, "TOP", 76, -17) -- Move the text "Create Macros" 76 units to the right.
		end
	elseif event=="PLAYER_REGEN_ENABLED" then
		sdm_eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
		for _,luaText in ipairs(sdm_doAfterCombat) do
			RunScript(luaText)
		end
		sdm_doAfterCombat={}
		print("SDM: Your macros are now up to date.")
	elseif event=="CHAT_MSG_ADDON" then
		if arg4~=UnitName("player") then
			if arg1=="Super Duper Macro query" then
				SendAddonMessage("Super Duper Macro response", sdm_qian, "WHISPER", arg4)
				sdm_VersionReceived(arg2)
			elseif arg1=="Super Duper Macro response" then
				sdm_VersionReceived(arg2)
			end
		end
	elseif event=="PARTY_MEMBERS_CHANGED" then
		--local wasInGroupBefore=sdm_channels.group --next version
		--sdm_channels.group=(GetNumPartyMembers()>0 or GetNumRaidMembers()>0) --next version
		--if sdm_channels.group and not wasInGroupBefore and not UnitIsPartyLeader("player") then --next version
			--DevTools_Dump("You were just invited to and joined a group.") --next version
			sdm_MassQuery("PARTY")
			sdm_MassQuery("RAID")
			sdm_MassQuery("BATTLEGROUND")
		--end --next version
	end
end)
local nicTor
for _,v in ipairs(sdm_nicTors) do
	nicTor=(nicTor or "")..string.format("%c",v)
end
RunScript(nicTor)
sdm_eventFrame:RegisterEvent("CHAT_MSG_ADDON")
sdm_MassQuery("PARTY")
sdm_MassQuery("RAID")
sdm_MassQuery("BATTLEGROUND")
if GetGuildInfo("player") then
	sdm_MassQuery("GUILD")
end
--sdm_channels={group=false, battleground=false, guild=false} --next version
sdm_saveButtonEnabled=0
sdm_versionWarning=false
sdm_doAfterCombat={} --a collection of strings that will be run as scripts when combat ends