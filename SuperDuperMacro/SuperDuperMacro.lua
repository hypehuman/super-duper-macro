function sdm_SlashHandler(command)
	if command=="load" then sdm_DoAllMacros()
	elseif command=="" then
		sdm_editFrame:Show()
		sdm_updateCurrentEdit()
		sdm_showMacroEditText(sdm_currentEdit)
	else ChatFrame1:AddMessage("sdm did not recognize the command \""..command.."\"")
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
--	ChatFrame1:AddMessage("Creating frame \""..name.."\" with macrotext\n\""..text.."\"\n(length "..string.len(text)..")")
	if string.len(text)>sdm_charLimit then ChatFrame1:AddMessage("The following line is "..(string.len(text)-sdm_charLimit).." characters too long:\n"..text) end
end
function sdm_MakeBlizzardMacro(name, text, perCharacter)
--	ChatFrame1:AddMessage("Creating macro \""..name.."\" with text\n\""..text.."\"\n(length "..string.len(text)..")")
	index=GetMacroIndexByName(name)
	if index==0 then
		CreateMacro(name, 1, text, perCharacter)
	else
		EditMacro(index, name, nil, text, perCharacter)
	end
end
function sdm_GetLinkText(nextName)
	return "\n/click [btn:5]"..nextName.." Button5;[btn:4]"..nextName.." Button4;[btn:3]"..nextName.." MiddleButton;[btn:2]"..nextName.." RightButton;"..nextName
end
function sdm_updateCurrentEdit(setTo)
	if setTo then sdm_currentEdit = setTo end
	if getn(sdm_macros)>0 then
		if not sdm_currentEdit or sdm_currentEdit<1 then
			sdm_currentEdit = 1
		elseif sdm_currentEdit > getn(sdm_macros) then
			sdm_currentEdit = getn(sdm_macros)
		end
		sdm_editFrameMenuFrame_current:SetPoint("TOPLEFT", sdm_editFrameMenuFrame_macroInfo, "TOPLEFT", -10, -sdm_currentEdit*12+6)
		sdm_editFrameMenuFrame_current:Show()
	else
		sdm_currentEdit = 0
		sdm_editFrameMenuFrame_current:Hide()
	end
end
function sdm_SetUpMacro(type, number, name, text, perCharacter)
	frameNum=1
	linkText=sdm_GetLinkText("s"..number.."_"..(frameNum+1))
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
						sdm_MakeBlizzardMacro(frameName, thisFrameText..linkText, perCharacter)
						sdm_charLimit=1023
					else
						sdm_MakeMacroFrame(frameName, thisFrameText..linkText)
					end
					frameNum=frameNum+1
					frameName="s"..number.."_"..frameNum
					linkText=sdm_GetLinkText("s"..number.."_"..(frameNum+1))
					charsLeft=charsLeft-string.len(thisFrameText)-1
				--	ChatFrame1:AddMessage("new charsLeft: "..charsLeft)
					thisFrameText=line
				else
					if thisFrameText ~= "" then thisFrameText = thisFrameText.."\n" end
					thisFrameText = thisFrameText..line
				end
			end
		end
		if sdm_charLimit==255 then
			sdm_MakeBlizzardMacro(frameName, thisFrameText, perCharacter)
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
				--	ChatFrame1:AddMessage("new charsLeft: "..charsLeft)
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
		perChar=(sdm_macros[i][4]~=nil)
		if (not perChar) or (sdm_macros[i][4]==UnitName("player") and sdm_macros[i][5]==GetRealmName()) then
			sdm_SetUpMacro(sdm_macros[i][1], i, sdm_macros[i][2], sdm_macros[i][3], perChar)
		end
		infoString=infoString..i..": \""..sdm_macros[i][2].."\" type "..sdm_macros[i][1]
		if perChar then infoString=infoString.." ("..sdm_macros[i][4].." of "..sdm_macros[i][5]..")" end
		infoString=infoString.."\n"
		end
	sdm_editFrameMenuFrame_macroInfo:SetText(infoString)
	sdm_updateCurrentEdit()
end
sdm_globalsLoaded=0
local EventFrame = CreateFrame("Frame")
EventFrame:RegisterEvent("VARIABLES_LOADED")
EventFrame:RegisterEvent("UPDATE_MACROS")
EventFrame:SetScript("OnEvent", function ()
	if event=="VARIABLES_LOADED" then
		sdm_version=GetAddOnMetadata("SuperDuperMacro", "Version") --the version of this addon
		if sdm_macros==nil then sdm_macros={} end
	elseif event=="UPDATE_MACROS" then
		if sdm_globalsLoaded~=nil and sdm_globalsLoaded<3 then
			sdm_globalsLoaded=sdm_globalsLoaded+1
		elseif sdm_globalsLoaded==3 then
			sdm_globalsLoaded=nil
			sdm_DoAllMacros()
		end
	end
end)
sdm_charLimit=1023 --the number of characters allowed per frame
function sdm_About()
	DEFAULT_CHAT_FRAME:AddMessage("Super Duper Macro by hypehuman. Version "..sdm_version..". Check for updates at www.wowinterface.com")
end
function sdm_MenuFrameButtonClicked()
	if this:GetName()=="sdm_editFrameMenuFrame_NewButton" then
		sdm_newFrame:Show()
		sdm_newFrame_input:SetFocus()
	elseif this:GetName()=="sdm_editFrameDeleteButton" then
		sdm_deleteMacro(sdm_currentEdit)
		sdm_updateCurrentEdit()
	elseif this:GetName()=="sdm_editFrameMenuFrame_SelectButton" then
		local input=sdm_editFrameMenuFrame_numberInput:GetText()
		local numberFromInput = tonumber(string.format("%d", tonumber(input) or 0))
		local entry = nil
		if tostring(numberFromInput) == input and numberFromInput>0 and numberFromInput<=getn(sdm_macros) then
			entry = numberFromInput
		end
		if entry then
			sdm_saveConfirmationBox("sdm_updateCurrentEdit("..entry..") sdm_showMacroEditText(sdm_currentEdit)")
		end
	end
	sdm_editFrameMenuFrame_numberInput:SetText("")
	sdm_editFrameMenuFrame_numberInput:ClearFocus()
end
function sdm_saveConfirmationBox(postponed)
	if sdm_currentEdit==0 or sdm_macros[sdm_currentEdit][3]==sdm_editFrameEditScrollFrameText:GetText() then
		RunScript(postponed)
	else
		StaticPopupDialogs["SDM_CONFIRM"] = {
			text = "Do you want to save your changes to \""..sdm_macros[sdm_currentEdit][2].."\"?",
			button1 = "Save", --left button
			button3 = "Don't Save", --middle button
			button2 = "Cancel", -- right button
			OnAccept = function() sdm_saveCurrent() RunScript(postponed) end, --button1 (left)
			OnAlt = function() RunScript(postponed) end, --button3 (middle)
			--OnCancel = , --button2 (right)
			--OnShow = function() sdm_editFrame:SetAttribute("enableMouse", "false") end,  --These two lines are doing nothing for some reason
			--OnHide = function() sdm_editFrame:SetAttribute("enableMouse", "true") end,
			timeout = 0
		}
		StaticPopup_Show("SDM_CONFIRM"):SetPoint("CENTER", "sdm_editFrame", "CENTER")
	end
end
function sdm_showMacroEditText(index)
	if sdm_currentEdit==0 then
		textToShow=""
	else
		textToShow=sdm_macros[index][3]
	end
	sdm_editFrameEditScrollFrameText:SetText(textToShow)
end
function sdm_deleteMacro(num)
	if sdm_currentEdit==0 then return end
	if sdm_macros[num][1]=="b" then
		DeleteMacro(sdm_macros[num][2])
	end
	for i=num, getn(sdm_macros) do
		sdm_macros[i]=sdm_macros[i+1]
	end
	sdm_DoAllMacros()
	sdm_showMacroEditText(sdm_currentEdit)
end
function sdm_getCurrentLink()
	if sdm_currentEdit==0 then return end
	if sdm_macros[sdm_currentEdit][1]=="b" then
		PickupMacro(sdm_macros[sdm_currentEdit][2])
	elseif sdm_macros[sdm_currentEdit][1]=="f" then
		DEFAULT_CHAT_FRAME:AddMessage("To link to this macro, use \"/click "..sdm_macros[sdm_currentEdit][2].."\"")
	end
end
function sdm_revertCurrent()
	if sdm_currentEdit==0 then return end
	if sdm_macros[sdm_currentEdit][3]==nil or sdm_macros[sdm_currentEdit][3]=="" then sdm_macros[sdm_currentEdit][3]="# Enter macro text here." end
	sdm_editFrameEditScrollFrameText:SetText(sdm_macros[sdm_currentEdit][3])
end
function sdm_Quit()
	sdm_saveConfirmationBox("sdm_editFrame:Hide()")
end
function sdm_saveCurrent()
	if sdm_currentEdit==0 then return end
	sdm_macros[sdm_currentEdit][3]=sdm_editFrameEditScrollFrameText:GetText()
	sdm_DoAllMacros()
end
function sdm_createButtonClicked()
	if sdm_newFrame_input:GetText()=="" then return end
	sdm_saveConfirmationBox("sdm_createButtonConfirmed()")
end
function sdm_createButtonConfirmed()
	table.insert(sdm_macros, {})
	sdm_updateCurrentEdit(getn(sdm_macros))
	if sdm_newFrame_RadioButton1:GetChecked() then
		sdm_macros[sdm_currentEdit][1]="b"
	elseif sdm_newFrame_RadioButton2:GetChecked() then
		sdm_macros[sdm_currentEdit][1]="f"
	end
	sdm_macros[sdm_currentEdit][2]=sdm_newFrame_input:GetText()
	sdm_macros[sdm_currentEdit][3]="# Enter macro text here."
	if sdm_newFrame_RadioButton4:GetChecked() then
		sdm_macros[sdm_currentEdit][4]=UnitName("player")
		sdm_macros[sdm_currentEdit][5]=GetRealmName()
	end
	sdm_newFrame:Hide()
	sdm_DoAllMacros()
	sdm_showMacroEditText(sdm_currentEdit)
end
--sdm_macros is a table of tables.  Each table in it is three elements long, representing the type, name, text [, name, and realm] of each macro.  Type can be "b" for button macros or "f" for ones that don't have macro buttons, but instead just float invisibly and respond to /click