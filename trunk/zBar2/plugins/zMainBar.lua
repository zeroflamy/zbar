﻿if zBar2.lite then return end
local _G = getfenv(0)

CreateFrame("Frame", "zMainBar", UIParent, "SecureStateHeaderTemplate")
zBar2:RegisterPlugin(zMainBar)
zBar2:RegisterBar(zMainBar)

--[[
	functional
--]]
function zMainBar:Init()
	self:SetID(10)
	self:SetFrameStrata("HIGH")
	self:SetClampedToScreen(true)
	self:SetWidth(36) self:SetHeight(36)

--~ 	self:SetAttribute("unit2","player")
	self:SetAttribute("statemap-actionpage", "$input")
	self:SetAttribute("statebutton", "1:p1;2:p2;3:p3;4:p4;5:p5;6:p6;7:p7;8:p8;9:p9;10:p10;11:p11")
--~ 	self:SetAttribute("statebutton2", "RightButton")
	self:UpdateStateHeader()

	SetModifiedClick("SELFCAST", "ALT")

	for id=1,12 do
		self:RegisterButton(_G["ActionButton"..id], id)
		zBar2.buttons["zMainBar"..id] = "ActionButton"..id
		_G["ActionButton"..id.."NormalTexture"]:SetWidth(60)
		_G["ActionButton"..id.."NormalTexture"]:SetHeight(60)
	end
	ActionButton1:ClearAllPoints()
	ActionButton1:SetPoint("CENTER")

	BonusActionBarFrame:Hide()
	BonusActionBarFrame:UnregisterAllEvents()
	BonusActionBarFrame.Show = BonusActionBarFrame.Hide

	if ( ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1) then
		self:UpdateGrid(1)
	end

	MainMenuBar:Hide()

	self:InitStanceMap()

	self:Hook()
end

--[[
	Privates
--]]

function zMainBar:RegisterButton(button, id)
	self:SetAttribute("addchild", button)

	button:SetID(-id)
	button:SetAttribute("stateheader", self)
	button:SetAttribute("useparent-statebutton", true)

	for p=1,11 do
		button:SetAttribute("*action-p"..p, id + (p-1)*12 )
	end
	button:Show()
	button.Hide = function(self) self:SetAlpha(0) end
	button.Show = function(self) self:SetAlpha(1) end
end

--[[ Hooks ]]
function zMainBar:Hook()
	hooksecurefunc("ActionButton_UpdateHotkeys", zMainBar.UpdateHotkey)

	hooksecurefunc("MultiActionBar_ShowAllGrids",function() zMainBar:UpdateGrid(1) end)
	hooksecurefunc("MultiActionBar_HideAllGrids",function() zMainBar:UpdateGrid() end)
end

function zMainBar:UpdateHotkey()
	if this:GetParent() == zMainBar then
		local hotkey = _G[this:GetName().."HotKey"]
		local text = GetBindingText(GetBindingKey(this:GetName()), "KEY_", 1)
		if ( text == "" ) then
			hotkey:SetText(RANGE_INDICATOR)
			hotkey:SetPoint("TOPLEFT", this, "TOPLEFT", -12, -2);
			hotkey:Hide()
		else
			hotkey:SetText(text)
			hotkey:SetPoint("TOPLEFT", this, "TOPLEFT", -2, -2)
			hotkey:Show()
		end
	end
end

function zMainBar:UpdateGrid(show)
	-- in combat we can't let it be shown or hidden
--~ 	if InCombatLockdown() then return end
	for i=1, 12 do
		if ( show ) then
			ActionButton_ShowGrid(_G["ActionButton"..i])
		else
			ActionButton_HideGrid(_G["ActionButton"..i])
		end
	end
end

--[[ Page Mapping. partly reference to PM2 ]]
local triggers = {
	[1] = "[modifier:alt]2",
	[2] = "[help]2",
}
local stances = {
	["ROGUE"] = { [1] = 7 },
	["DRUID"] = { [1] = 9, [3] = 7, [5] = 8 },	-- moonkin/tree-of-life
	["WARRIOR"] = { [1] = 7, [2] = 8, [3] = 9 },
}

function zMainBar:GetStateCommand()
	local header, state = "", ""

	if zBar2Saves["pageTrigger"] then
		for k,v in pairs(triggers) do
			state = v .. ";"
			header = header .. state
		end
	end

	if stances[zBar2.class] then
		for k,v in pairs(stances[zBar2.class]) do
			state = format("[actionbar:1,stance:%d]%d;", k, v)
			header = header .. state
		end
	end

	for i=1,6 do
		state = format("[actionbar:%d]%d;", i, i)
		header = header .. state
	end

	return header .. "0"
end

function zMainBar:UpdateStateHeader()
	UnregisterStateDriver(zMainBar, "actionpage")
	RegisterStateDriver(zMainBar, "actionpage", zMainBar:GetStateCommand())
end

--[[ Stance Map Update- for Priest ]]

--local StanceTexturePriest = "Interface\\Icons\\Spell_Shadow_Shadowform"

local function searchTalent(pattern)
	-- search when initial
	local numTabs = GetNumTalentTabs()
	for t=1, numTabs do
		local numTalents = GetNumTalents(t)
		for i=1, numTalents do
			local nameTalent, icon, tier, column, currRank, maxRank= GetTalentInfo(t,i)
			if string.find( string.lower(icon), pattern ) then
				zBar2:print("zBar2 : "..UnitClass("player").." - "..nameTalent.." - Rank:"..currRank.."/"..maxRank,1,1,0)
				zMainBar.TabIndex, zMainBar.TalentIndex = t, i
				zMainBar.TalentName = nameTalent
				zMainBar.ShadowFormRank = currRank
				if currRank > 0 then -- if has shadow form
					stances["PRIEST"] = {[1]=7}
					zMainBar:UpdateStateHeader()
				end
				return
			end
		end
	end
end

function zMainBar:InitStanceMap()
	if zBar2.class == "PRIEST" then
		searchTalent("shadowform")
		self:RegisterEvent("PLAYER_ALIVE")
		self:RegisterEvent("CHARACTER_POINTS_CHANGED")
		self:SetScript("OnEvent", zMainBar.OnEvent)
	end
end

function zMainBar:OnEvent()
	if event == "PLAYER_ALIVE" then
		searchTalent("shadowform")
		zMainBar:UnregisterEvent("PLAYER_ALIVE")
	elseif event == "CHARACTER_POINTS_CHANGED" then
		local currRank = select(5, GetTalentInfo(zMainBar.TabIndex,zMainBar.TalentIndex))
		--zBar2:print("zBar2: "..zMainBar.TalentName.." Rank:"..currRank,1,1,0)
		if zMainBar.ShadowFormRank ~= currRank then
			zBar2:print("zBar2: "..zMainBar.TalentName.." Change Rank:"..currRank,1,1,0)
			zMainBar.ShadowFormRank = currRank

			if currRank > 0 then -- if has shadow form
				stances["PRIEST"] = {[1]=7}
			else
				stances["PRIEST"] = nil
			end
			if InCombatLockdown() then
				zMainBar:RegisterEvent("PLAYER_REGEN_ENABLED")
			else
				zMainBar:UpdateStateHeader()
			end
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		zMainBar:UpdateStateHeader()
		zMainBar:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end