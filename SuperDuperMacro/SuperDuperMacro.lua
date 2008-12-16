function sdm_SlashHandler(command)
	if command=="" then
		sdm_editFrame:Show()
	elseif command=="load" then sdm_DoAllMacros()
	elseif command:sub(1,4)=="run " then
		sdm_RunScript(command:sub(5,command:len()))
	else DEFAULT_CHAT_FRAME:AddMessage("sdm did not recognize the command \""..command.."\"")
	end
end
SlashCmdList["SUPERDUPERMACRO"] = sdm_SlashHandler;
SLASH_SUPERDUPERMACRO1 = "/sdm";
function sdm_MakeMacroFrame(name, text)
	CreateFrame("Button", name, nil, "SecureActionButtonTemplate")
	temp=getglobal(name)
	temp:SetAttribute('type', 'macro')
	temp:SetAttribute('macrotext', text)
--	GetClickFrame(name) --This line is just to fix a taint issue from a Blizzard bug (fixed in 3.0)
--	DEFAULT_CHAT_FRAME:AddMessage("Creating frame \""..name.."\" with macrotext\n\""..text.."\"\n(length "..string.len(text)..")")
	if string.len(text)>sdm_charLimit then DEFAULT_CHAT_FRAME:AddMessage("The following line is "..(string.len(text)-sdm_charLimit).." characters too long:\n"..text) end
end
function sdm_MakeBlizzardMacro(ID, name, text, perCharacter)
--	DEFAULT_CHAT_FRAME:AddMessage("Creating macro \""..name.."\" with text\n\""..text.."\"\n(length "..string.len(text)..")")
	local index = nil
	local macrosToDelete = {}
	for i=1,54 do
		thisID=sdm_GetSdmID(i)
		if thisID==ID then
			index=i
			break
		end
	end
	if index then
		EditMacro(index, name, nil, text, 1, perCharacter)
	else
		CreateMacro(name, 1, text, perCharacter, 1)
	end
end
function sdm_GetSdmID(macroID)
	local thisMacroText=GetMacroBody(macroID)
	if thisMacroText and thisMacroText:sub(1,4)=="#sdm" then
		return tonumber(thisMacroText:sub(5,thisMacroText:find("\n")-1))
	else
		return nil
	end
end
function sdm_GetLinkText(nextName)
	return "\n/click [btn:5]"..nextName.." Button5;[btn:4]"..nextName.." Button4;[btn:3]"..nextName.." MiddleButton;[btn:2]"..nextName.." RightButton;"..nextName
end
function sdm_UpdateCurrentEdit(setTo)
	if setTo then sdm_currentEdit = setTo end
	if getn(sdm_macros)>0 then
		if not sdm_currentEdit or sdm_currentEdit<1 then
			sdm_currentEdit = 1
		elseif sdm_currentEdit > getn(sdm_macros) then
			sdm_currentEdit = getn(sdm_macros)
		end
		sdm_editFrame_menuFrame_current:SetPoint("TOPLEFT", sdm_editFrame_menuFrame_macroInfo, "TOPLEFT", -10, -sdm_currentEdit*12+6)
		sdm_editFrame_menuFrame_current:Show()
	else
		sdm_currentEdit = 0
		sdm_editFrame_menuFrame_current:Hide()
	end
	if sdm_currentEdit==0 then
		sdm_editFrame_deleteButton:Disable()
		sdm_editFrame_getLinkButton:Disable()
	else
		sdm_editFrame_deleteButton:Enable()
		sdm_editFrame_getLinkButton:Enable()
	end
end
function sdm_SetUpMacro(type, number, name, text, perCharacter, ID)
	frameNum=1
	linkText=sdm_GetLinkText("s"..number.."_"..(frameNum+1))
	if type=="b" then
		text="#sdm"..ID.."\n"..text
	end
	charsLeft=string.len(text)
	thisFrameText=""
	frameName=name
	if type=="b" then
		sdm_charLimit=255
		for line in text:gmatch("[^\r\n]+") do
			if charsLeft <= sdm_charLimit then --if this condition is met, this should be the last frame.
				if thisFrameText ~= "" then thisFrameText = thisFrameText.."\n" end
				thisFrameText = thisFrameText..line
			else
				if string.len(thisFrameText)+string.len(line)+string.len(linkText)+1>sdm_charLimit then
					if sdm_charLimit==255 then
						sdm_MakeBlizzardMacro(ID, frameName, thisFrameText..linkText, perCharacter)
						sdm_charLimit=1023
					else
						sdm_MakeMacroFrame(frameName, thisFrameText..linkText)
					end
					frameNum=frameNum+1
					frameName="s"..number.."_"..frameNum
					linkText=sdm_GetLinkText("s"..number.."_"..(frameNum+1))
					charsLeft=charsLeft-string.len(thisFrameText)-1
				--	DEFAULT_CHAT_FRAME:AddMessage("new charsLeft: "..charsLeft)
					thisFrameText=line
				else
					if thisFrameText ~= "" then thisFrameText = thisFrameText.."\n" end
					thisFrameText = thisFrameText..line
				end
			end
		end
		if sdm_charLimit==255 then
			sdm_MakeBlizzardMacro(ID, frameName, thisFrameText, perCharacter)
			sdm_charLimit=1023
		else
			sdm_MakeMacroFrame(frameName, thisFrameText)
		end
	elseif type=="f" then
		for line in text:gmatch("[^\r\n]+") do
			if charsLeft <= sdm_charLimit then --if this condition is met, this should be the last frame.
				if thisFrameText ~= "" then thisFrameText = thisFrameText.."\n" end
				thisFrameText = thisFrameText..line
			else
				if string.len(thisFrameText)+string.len(line)+string.len(linkText)+1>sdm_charLimit then
					sdm_MakeMacroFrame(frameName, thisFrameText..linkText)
					frameNum=frameNum+1
					frameName="s"..number.."_"..frameNum
					linkText=sdm_GetLinkText("s"..number.."_"..(frameNum+1))
					charsLeft=charsLeft-string.len(thisFrameText)-1
				--	DEFAULT_CHAT_FRAME:AddMessage("new charsLeft: "..charsLeft)
					thisFrameText=line
				else
					if thisFrameText ~= "" then thisFrameText = thisFrameText.."\n" end
					thisFrameText = thisFrameText..line
				end
			end
		end
		sdm_MakeMacroFrame(frameName, thisFrameText)
	end
end
function sdm_DoAllMacros()
	infoString=""
	for i=1,getn(sdm_macros) do
		perChar=(sdm_macros[i].character~=nil)
		if (not perChar) or (sdm_macros[i].character.name==UnitName("player") and sdm_macros[i].character.server==GetRealmName()) then
			sdm_SetUpMacro(sdm_macros[i].type, i, sdm_macros[i].name, sdm_macros[i].text, perChar, sdm_macros[i].ID)
		end
		infoString=infoString..i..": \""..sdm_macros[i].name.."\" type "..sdm_macros[i].type
		if perChar then infoString=infoString.." ("..sdm_macros[i].character.name.." of "..sdm_macros[i].character.server..")" end
		infoString=infoString.."\n"
	end
	sdm_editFrame_menuFrame_macroInfo:SetText(infoString)
	sdm_UpdateCurrentEdit()
end
sdm_globalsLoaded=0
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:RegisterEvent("UPDATE_MACROS")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:SetScript("OnEvent", function ()
	if event=="VARIABLES_LOADED" then
		EventFrame:UnregisterEvent("VARIABLES_LOADED")
		if sdm_macros==nil then
			sdm_macros={}
		elseif sdm_CompareVersions(sdm_version,"1.3")==2 then
			sdm_oldMacros=sdm_macros
			sdm_macros={}
			local ID=1
			for i=1,getn(sdm_oldMacros) do
				sdm_macros[i]={type=sdm_oldMacros[i][1], name=sdm_oldMacros[i][2], text=sdm_oldMacros[i][3]}
				if sdm_oldMacros[i][4] then
					sdm_macros[i].character={name=sdm_oldMacros[i][4], server=sdm_oldMacros[i][5]}
				end
				if sdm_oldMacros[i][1]=="b" then
					sdm_macros[i].ID=ID
					ID=ID+1
				end
			end
		end
		sdm_version=GetAddOnMetadata("SuperDuperMacro", "Version") --the version of this addon
	elseif event=="UPDATE_MACROS" then
		if sdm_globalsLoaded~=nil and sdm_globalsLoaded<3 then
			sdm_globalsLoaded=sdm_globalsLoaded+1
		elseif sdm_globalsLoaded==3 then
			sdm_globalsLoaded=nil
			EventFrame:UnregisterEvent("UPDATE_MACROS")
			local foundOne = {}
			local macrosToDelete = {}
			local iIsPerCharacter=false
			for i=1,54 do
				if i==37 then iIsPerCharacter=true end
				thisID=sdm_GetSdmID(i)
				if thisID then
					local IDUsedBy = sdm_IsIDUsed(thisID)
					if foundOne[thisID] then
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
				DEFAULT_CHAT_FRAME:AddMessage("SDM: Deleting extraneous macro "..macrosToDelete[i]..": "..GetMacroInfo(macrosToDelete[i]))
				DeleteMacro(macrosToDelete[i])
			end
			sdm_DoAllMacros()
		end
	elseif event=="ADDON_LOADED" then
		if arg1=="Blizzard_MacroUI" then
			EventFrame:UnregisterEvent("ADDON_LOADED")
			local f = CreateFrame("Button", "$parent_linkToSDM", MacroFrame, "UIPanelButtonTemplate")
			f:SetWidth(150)
			f:SetHeight(19)
			f:SetPoint("TOPLEFT", 68, -14)
			f:SetText("Super Duper Macro")
			f:SetScript("OnClick", function() HideUIPanel(MacroFrame) sdm_editFrame:Show() end)
			select(6, MacroFrame:GetRegions()):SetPoint("TOP",MacroFrame, "TOP", 76, -17) -- Move the text "Create Macros" 76 units to the right.
		end
	end
end)
sdm_charLimit=1023 --the number of characters allowed per frame
sdm_saveButtonEnabled=0
function sdm_CompareVersions(firstString, secondString) --returns 1 if the first is bigger, 2 if the second is bigger, and 0 if they are equal.
	local strings = {firstString, secondString}
	local numbers = {}
	while 1 do
		for i=1, 2 do
			local indexOfPeriod=strings[i]:find("%.")
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
	DEFAULT_CHAT_FRAME:AddMessage("Super Duper Macro by hypehuman. Version "..sdm_version..". Check for updates at www.wowinterface.com")
end
function sdm_MenuFrameButtonClicked()
	if this:GetName()=="sdm_editFrame_menuFrame_newButton" then
		sdm_newFrame:Show()
		sdm_newFrame_input:SetFocus()
	elseif this:GetName()=="sdm_editFrame_deleteButton" then
		sdm_DeleteMacro(sdm_currentEdit)
		sdm_UpdateCurrentEdit()
	elseif this:GetName()=="sdm_editFrame_menuFrame_selectButton" then
		local input=sdm_editFrame_menuFrame_numberInput:GetText()
		local numberFromInput = tonumber(string.format("%d", tonumber(input) or 0))
		local entry = nil
		if tostring(numberFromInput) == input and numberFromInput>0 and numberFromInput<=getn(sdm_macros) then
			entry = numberFromInput
		end
		if entry then
			sdm_SaveConfirmationBox("sdm_UpdateCurrentEdit("..entry..") sdm_ShowMacroEditText(sdm_currentEdit)")
		end
	end
	sdm_editFrame_menuFrame_numberInput:SetText("")
	sdm_editFrame_menuFrame_numberInput:ClearFocus()
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
			OnAccept = function() sdm_SaveCurrent() RunScript(postponed) end, --button1 (left)
			OnAlt = function() RunScript(postponed) end, --button3 (middle)
			--OnCancel = , --button2 (right)
			OnShow = sdm_freezeEditFrame,
			OnHide = sdm_thawEditFrame,
			timeout = 0
		}
		StaticPopup_Show("SDM_CONFIRM"):SetPoint("CENTER", "sdm_editFrame", "CENTER")
	end
end
function sdm_ShowMacroEditText(index)
	if sdm_currentEdit==0 then
		textToShow=""
	else
		textToShow=sdm_macros[index].text
	end
	sdm_editFrame_editScrollFrame_text:SetText(textToShow)
end
function sdm_DeleteMacro(num)
	if sdm_currentEdit==0 then return end
	if sdm_macros[num].type=="b" then
		DeleteMacro(sdm_macros[num].name)
	end
	for i=num, getn(sdm_macros) do
		sdm_macros[i]=sdm_macros[i+1]
	end
	sdm_DoAllMacros()
	sdm_ShowMacroEditText(sdm_currentEdit)
end
function sdm_GetCurrentLink()
	if sdm_currentEdit==0 then return end
	if sdm_macros[sdm_currentEdit].type=="b" then
		local MacroID = nil
		for i=1,54 do
			if sdm_GetSdmID(i)==sdm_macros[sdm_currentEdit].ID then
				MacroID=i
				break
			end
		end
		PickupMacro(MacroID)
	elseif sdm_macros[sdm_currentEdit].type=="f" then
		DEFAULT_CHAT_FRAME:AddMessage("To run this macro, use \"/click "..sdm_macros[sdm_currentEdit].name.."\".")
	elseif sdm_macros[sdm_currentEdit].type=="s" then
		DEFAULT_CHAT_FRAME:AddMessage("To run this script, use \"/sdm run "..sdm_macros[sdm_currentEdit].name.."\" or use the function \"sdm_RunScript("..sdm_macros[sdm_currentEdit].name..")\".")
	end
end
function sdm_RevertCurrent()
	if sdm_currentEdit==0 then return end
	sdm_editFrame_editScrollFrame_text:SetText(sdm_macros[sdm_currentEdit].text)
end
function sdm_Quit()
	sdm_SaveConfirmationBox("sdm_editFrame:Hide() sdm_newFrame:Hide()")
end
function sdm_SaveCurrent()
	if sdm_currentEdit==0 then return end
	sdm_macros[sdm_currentEdit].text=sdm_editFrame_editScrollFrame_text:GetText()
	sdm_DoAllMacros()
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
	perCharacter = sdm_newFrame_charspecRadio:GetChecked()
	local conflict = sdm_DoesNameConflict(name, type, perCharacter)
	if conflict then
		DEFAULT_CHAT_FRAME:AddMessage("SDM: You may not have more than one of that type with the same name per character. (Conflicts with #"..conflict..")")
		return
	end
	sdm_SaveConfirmationBox("sdm_CreateNew(\""..type.."\", \""..name.."\", "..(perCharacter or "nil")..")")
end
function sdm_CreateNew(type, name, perCharacter)
	table.insert(sdm_macros, {})
	sdm_UpdateCurrentEdit(getn(sdm_macros))
	sdm_macros[sdm_currentEdit].type=type
	if type=="b" then
		sdm_macros[sdm_currentEdit].ID=sdm_FindUnusedID()
	end
	sdm_macros[sdm_currentEdit].name=sdm_newFrame_input:GetText()
	if type=="s" then
		sdm_macros[sdm_currentEdit].text="-- Enter lua commands here."
	else
		sdm_macros[sdm_currentEdit].text="# Enter macro text here."
	end
	if perCharacter then
		sdm_macros[sdm_currentEdit].character={name=UnitName("player"), server=GetRealmName()}
	end
	sdm_newFrame:Hide()
	sdm_DoAllMacros()
	sdm_ShowMacroEditText(sdm_currentEdit)
end
function sdm_FindUnusedID()
	local attempt = 0
	repeat
		attempt=attempt+1
	until not sdm_IsIDUsed(attempt)
	return attempt
end
function sdm_IsIDUsed(num) -- returns the index of the macro
	for i=1,getn(sdm_macros) do
		if sdm_macros[i].type=="b" and sdm_macros[i].ID==num then
			return i
		end
	end
	return nil
end
function sdm_RunScript(name)
	local index = nil
	for i=1,getn(sdm_macros) do
		if sdm_macros[i].type=="s" and sdm_macros[i].name==name then
			index=i
			break
		end
	end
	if index then
		RunScript(sdm_macros[index].text)
	else
		DEFAULT_CHAT_FRAME:AddMessage("SDM could not find a script named \""..name.."\".")
	end
end
function sdm_DoesNameConflict(name, type, perCharacter) --returns a conflict if we find a macro of the same type and name that can be seen for this same character.  Button macros never conflict.
	if type=="f" or type=="s" then
		for i=1,getn(sdm_macros) do
			if sdm_macros[i].type==type and sdm_macros[i].name==name and ((not perCharacter) or (not sdm_macros[i].character) or (sdm_macros[i].character.name==UnitName("player") and sdm_macros[i].character.server==GetRealmName())) then
				return i
			end
		end
	end
	return nil
end