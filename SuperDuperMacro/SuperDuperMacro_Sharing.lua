function sdm_SendMacro(mTab, chan, tar)
	if sdm_sending then
		print(sdm_printPrefix.."You are already sending something.")
		return
	end
	local perCharacter=nil
	--make the string that will be split up and sent.  It consists of a bunch of values separated by commas.  They are, in order: the version the sender is running, the minimum version the receiver must have, the type of macro, the index of the icon, the perCharacter status ("<table value>" or "nil"), the length of the name, the length of the text, the name, and the text.  There is no comma between the name and the text.
	local textToSend = sdm_version..","..sdm_minVersion..","..mTab.type..","..tostring(mTab.icon)..","..tostring(mTab.characters)..","..mTab.name:len()..","..mTab.text:len()..","..mTab.name..mTab.text
	local pref = "SDM send1" -- if the prefix ends in "send1", it's the first line.  If it ends in "send2", it's any line after the first.
	local lineLen = 254 - pref:len()
	local linesToSend={}
	local pos = 1
	while pos <= textToSend:len() do
		table.insert(linesToSend, textToSend:sub(pos, pos+lineLen-1))
		pos = pos+lineLen
	end
	sdm_sending={
		i=1,
		lines = linesToSend,
		numLines = getn(linesToSend),
		channel = chan,
		target = tar,
		prefix = pref
	}
	sdm_sendReceiveFrame_sendBar_statusBar:SetMinMaxValues(0, sdm_sending.numLines)
	sdm_sendReceiveFrame_sendBar_statusBar:SetValue(0)
	sdm_sendReceiveFrame_sendBar_statusBar_text:SetText("|cffffccffSending to "..(sdm_sending.target or sdm_sending.channel).."|r")
	sdm_sendReceiveFrame_cancelSendButton:Enable()
	sdm_sendReceiveFrame_sendButton:Disable()
	sdm_sendReceiveFrame_sendPartyRadio:Disable()
	sdm_sendReceiveFrame_sendRaidRadio:Disable()
	sdm_sendReceiveFrame_sendBattlegroundRadio:Disable()
	sdm_sendReceiveFrame_sendGuildRadio:Disable()
	sdm_sendReceiveFrame_sendTargetRadio:Disable()
	sdm_sendReceiveFrame_sendArbitraryRadio:Disable()
	sdm_sendReceiveFrame_sendInput:EnableMouse(nil)
	sdm_updateFrame:Show()
end

function sdm_OnUpdate(self, elapsed) --used for sending macros
	self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed
	if self.TimeSinceLastUpdate > sdm_updateInterval then
		if sdm_sending.i == 2 then
			sdm_sending.prefix="SDM send2"
		end
		SendAddonMessage(sdm_sending.prefix, sdm_sending.lines[sdm_sending.i], sdm_sending.channel, sdm_sending.target)
		sdm_sendReceiveFrame_sendBar_statusBar:SetValue(sdm_sending.i)
		sdm_sending.i = sdm_sending.i+1
		if sdm_sending.i>sdm_sending.numLines then
			sdm_EndSending("|cff44ff00Sent to "..(sdm_sending.target or sdm_sending.channel).."|r")
		end
		self.TimeSinceLastUpdate = 0
	end
end

function sdm_EndSending(text)
	sdm_updateFrame:Hide()
	sdm_sendReceiveFrame_sendBar_statusBar_text:SetText(text)
	sdm_sending=nil
	sdm_sendReceiveFrame_cancelSendButton:Disable()
	if sdm_currentEdit then
		sdm_sendReceiveFrame_sendButton:Enable()
	end
	sdm_sendReceiveFrame_sendPartyRadio:Enable()
	sdm_sendReceiveFrame_sendRaidRadio:Enable()
	sdm_sendReceiveFrame_sendBattlegroundRadio:Enable()
	sdm_sendReceiveFrame_sendGuildRadio:Enable()
	sdm_sendReceiveFrame_sendTargetRadio:Enable()
	sdm_sendReceiveFrame_sendArbitraryRadio:Enable()
	sdm_sendReceiveFrame_sendInput:EnableMouse(1)
end

function sdm_WaitForMacro(name)
	if sdm_receiving then
		print(sdm_printPrefix.."You are already receiving or waiting.")
		return
	end
	sdm_receiving = {playerName=name, first=true}
	sdm_sendReceiveFrame_receiveBar_statusBar:SetValue(0)
	sdm_sendReceiveFrame_receiveBar_statusBar_text:SetText("|cffffccffWaiting for "..sdm_receiving.playerName.."|r")
	sdm_sendReceiveFrame_cancelReceiveButton:Enable()
	sdm_sendReceiveFrame_receiveButton:Disable()
	sdm_sendReceiveFrame_receiveTargetRadio:Disable()
	sdm_sendReceiveFrame_receiveArbitraryRadio:Disable()
	sdm_sendReceiveFrame_receiveInput:EnableMouse(nil)
	sdm_SelectItem(nil)
	sdm_newFrame:Show()
	sdm_newFrame_input:ClearFocus()
	sdm_newFrame_input:SetText("Receiving macro...")
	sdm_newFrame_input:EnableMouse(nil)
	sdm_newFrame_buttonRadio:Disable()
	sdm_newFrame_floatingRadio:Disable()
	sdm_newFrame_scriptRadio:Disable()
	sdm_newFrame_globalRadio:Disable()
	sdm_newFrame_charspecRadio:Disable()
	sdm_newFrame_createButton:Disable()
	sdm_saveAsText = nil
	sdm_saveAsIcon = nil
end

function sdm_InterpretAddonMessage(...)
	local arg1, arg2, arg3, arg4 = ...
	if arg4~=sdm_thisChar.name and arg1:sub(1,17)=="SDM" then
		local txt=arg1:sub(18)
		if sdm_receiving and arg4:upper()==sdm_receiving.playerName:upper() and (not sdm_receiving.text) then
			if txt==" send1" then
				sdm_ReceiveLine(arg2, true)
			elseif txt==" send2" then
				sdm_ReceiveLine(arg2, false)
			elseif txt==" sendFailed" then
				print(sdm_printPrefix..""..arg4.." failed to send the macro.  Reason: "..arg2)
				sdm_EndReceiving("|cffff0000Failed|r")
			end
		elseif txt==" receiving" then
			print(sdm_printPrefix.."Sending macro to "..arg4.."...")
		elseif txt==" recDone" then
			print(sdm_printPrefix..""..arg4.." has accepted your macro.")
		elseif txt==" recFailed" then --"SDM recFailed","reason,version"
			local version, reason = sdm_SplitString(arg2, ",", 1)
			print(sdm_printPrefix..""..arg4.." did not receive your macro.  Reason: "..reason)
		end
	end
end

function sdm_ReceiveLine(line, send1)
	if sdm_receiving.first and send1 then --this is the first line
		sdm_receiving.nameAndText, sdm_receiving.textLen, sdm_receiving.playerNameLen, sdm_receiving.perCharacter, sdm_receiving.icon, sdm_receiving.type, sdm_receiving.minVersion, sdm_receiving.sendersVersion = sdm_SplitString(line, ",", 7)
		sdm_receiving.perCharacter = (sdm_receiving.perCharacter~="nil")
		if sdm_receiving.icon=="nil" then
			sdm_receiving.icon = nil
		else
			sdm_receiving.icon = 0 + sdm_receiving.icon
		end
		sdm_receiving.textLen = 0 + sdm_receiving.textLen
		sdm_receiving.playerNameLen = 0 + sdm_receiving.playerNameLen
		sdm_receiving.first = false
		sdm_sendReceiveFrame_receiveBar_statusBar:SetMinMaxValues(0, sdm_receiving.playerNameLen + sdm_receiving.textLen)
		sdm_sendReceiveFrame_receiveBar_statusBar_text:SetText("|cffffccffReceiving|r")
		if sdm_CompareVersions(sdm_receiving.sendersVersion, sdm_minVersion)==2 or sdm_CompareVersions(sdm_version, sdm_receiving.minVersion)==2 then
			print(sdm_printPrefix.."You failed to recieve the macro due to a version incompatibility.")
			SendAddonMessage("SDM recFailed", "Incompatible Versions,"..sdm_version, "WHISPER", sdm_receiving.playerName)
			sdm_EndReceiving("|cffff0000Failed|r")
			return
		else
			SendAddonMessage("SDM receiving", sdm_version, "WHISPER", sdm_receiving.playerName)
		end
	elseif (not sdm_receiving.first) and (not send1) then
		sdm_receiving.nameAndText = sdm_receiving.nameAndText..line
	else
		return
	end
	local currLen = sdm_receiving.nameAndText:len()
	sdm_sendReceiveFrame_receiveBar_statusBar:SetValue(currLen)
	if currLen == (sdm_receiving.playerNameLen + sdm_receiving.textLen) then
		sdm_sendReceiveFrame_receiveBar_statusBar_text:SetText("|cffff9900Click \"Create\" to save|r")
		UIFrameFlash(sdm_newFrame_createButton_flash, 0.5, 0.5, 1e6, false)
		sdm_newFrame_input:EnableMouse(1)
		sdm_newFrame_buttonRadio:Enable()
		sdm_newFrame_floatingRadio:Enable()
		sdm_newFrame_scriptRadio:Enable()
		sdm_newFrame_globalRadio:Enable()
		sdm_newFrame_charspecRadio:Enable()
		sdm_newFrame_createButton:Enable()
		if sdm_receiving.type=="b" then
			sdm_newFrame_buttonRadio:Click()
		elseif sdm_receiving.type=="f" then
			sdm_newFrame_floatingRadio:Click()
		elseif sdm_receiving.type=="s" then
			sdm_newFrame_scriptRadio:Click()
		end
		if sdm_receiving.perCharacter then
			sdm_newFrame_charspecRadio:Click()
		else
			sdm_newFrame_globalRadio:Click()
		end
		sdm_receiving.name=sdm_receiving.nameAndText:sub(1,sdm_receiving.playerNameLen)
		sdm_newFrame_input:SetText(sdm_receiving.name)
		sdm_receiving.text=sdm_receiving.nameAndText:sub(sdm_receiving.playerNameLen+1,sdm_receiving.playerNameLen+sdm_receiving.textLen)
	end
end

function sdm_EndReceiving(text)
	sdm_sendReceiveFrame_receiveBar_statusBar_text:SetText(text)
	sdm_sendReceiveFrame_cancelReceiveButton:Disable()
	sdm_sendReceiveFrame_receiveButton:Enable()
	sdm_mainFrame_newButton:Enable()
	sdm_sendReceiveFrame_receiveTargetRadio:Enable()
	sdm_sendReceiveFrame_receiveArbitraryRadio:Enable()
	sdm_sendReceiveFrame_receiveInput:EnableMouse(1)
	sdm_newFrame_input:SetText("")
	sdm_newFrame_input:EnableMouse(1)
	sdm_newFrame_buttonRadio:Enable()
	sdm_newFrame_floatingRadio:Enable()
	sdm_newFrame_scriptRadio:Enable()
	sdm_newFrame_globalRadio:Enable()
	sdm_newFrame_charspecRadio:Enable()
	sdm_newFrame_createButton:Enable()
	sdm_receiving=nil
end

function sdm_CancelSend()
	SendAddonMessage("SDM sendFailed", "Cancelled", sdm_sending.channel, sdm_sending.target)
	sdm_EndSending("|cffff0000Cancelled|r")
end

function sdm_CancelReceive()
	SendAddonMessage("SDM recFailed", "Cancelled,"..sdm_version, "WHISPER", sdm_receiving.playerName)
	sdm_EndReceiving("|cffff0000Cancelled|r")
	sdm_newFrame:Hide()
end

function sdm_SplitString(s, pattern, limit, ...) --iterates through "s", splitting it between occurrences of "pattern", and returning the split portions IN BACKWARDS ORDER. Splits a maximum of <limit> times (optional)
	if limit==0 then
		return s, ...
	end
	local index = s:find(pattern)
	if (not index) then
		return s, ...
	end
	return sdm_SplitString(s:sub(index+pattern:len()), pattern, limit-1, s:sub(1, index-1), ...)
end

function sdm_SendButtonClicked()
	local channel
	local target
	if sdm_sendReceiveFrame_sendPartyRadio:GetChecked() then
		channel="PARTY"
	elseif sdm_sendReceiveFrame_sendRaidRadio:GetChecked() then
		channel="RAID"
	elseif sdm_sendReceiveFrame_sendBattlegroundRadio:GetChecked() then
		channel="BATTLEGROUND"
	elseif sdm_sendReceiveFrame_sendGuildRadio:GetChecked() then
		channel="GUILD"
	elseif sdm_sendReceiveFrame_sendTargetRadio:GetChecked() then
		channel="WHISPER"
		if UnitIsPlayer("target") then
			target, realm = UnitName("target")
			if realm then
				target = target.."-"..realm
			end
		end
	elseif sdm_sendReceiveFrame_sendArbitraryRadio:GetChecked() then
		channel="WHISPER"
		target=sdm_sendReceiveFrame_sendInput:GetText()
	end
	if channel=="WHISPER" and ((not target) or target=="" or target==sdm_thisChar.name) then
		return
	end
	sdm_sendReceiveFrame_sendInput:ClearFocus()
	sdm_SendMacro(sdm_macros[sdm_currentEdit], channel, target)
end

function sdm_ReceiveButtonClicked()
	local sender
	if sdm_sendReceiveFrame_receiveTargetRadio:GetChecked() then
		if UnitIsPlayer("target") then
			sender, realm = UnitName("target")
			if realm then
				sender = sender.."-"..realm
			end
		end
	elseif sdm_sendReceiveFrame_receiveArbitraryRadio:GetChecked() then
		sender=sdm_sendReceiveFrame_receiveInput:GetText()
	end
	if ((not sender) or sender=="" or sender==sdm_thisChar.name) then return end
	sdm_sendReceiveFrame_receiveInput:ClearFocus()
	sdm_SaveConfirmationBox("sdm_WaitForMacro("..sdm_Stringer(sender)..")")
end

sdm_sending=nil --info about the macro you're trying to send
sdm_receiving=nil --info about the macro you're receiving (or waiting to receive)
sdm_updateInterval=0.25 --can be as low as 0.01 and still work, but it might disconnect you if there are other addons sending out messages too.  0.25 is slower but safer.
sdm_minVersion="1.6" --the oldest version that is compatible with this one for exchanging macros