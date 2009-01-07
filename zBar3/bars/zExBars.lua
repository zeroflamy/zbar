local _G = getfenv(0)

NUM_ZEXBAR_BAR = 2
NUM_ZEXBAR_BUTTONS = 24

zExBars = {}
zBar3:AddPlugin(zExBars)

function zExBars:New(prefix,id,page)
	local bar = CreateFrame("Frame", prefix..id, UIParent, "SecureHandlerShowHideTemplate")
	zBar3:AddBar(bar)

	bar:SetFrameStrata("MEDIUM")
	bar:SetClampedToScreen(true)
	bar:SetWidth(36); bar:SetHeight(36);
	bar:SetAttribute("actionpage", page)

	bar.GetButton = self.GetButton

	if prefix == "zShadow" then
		bar:SetID(-id)
		bar.isShadow = true
		rawset(bar, "UpdateButtons", zExBars.UpdateShadowButtons)
	else
		bar:SetID(id)
		rawset(bar, "UpdateButtons", zExBars.UpdateExBarButtons)
		local button
		for i = 1, 12 do
			button =bar:GetButton(i)
			button:SetID(i)
			button:SetParent(bar)
		end
		bar:GetButton(1):ClearAllPoints()
		bar:GetButton(1):SetPoint("CENTER")
	end

	if not zBar3Data[prefix..id] then
		zBar3Data[prefix..id] = zBar3:GetDefault(bar,"saves")
		zBar3Data[prefix..id].pos = zBar3:GetDefault(bar,"pos")
	end

	return bar
end

function zExBars:Load()
	-- create buttons
	local button
	for id = 1, NUM_ZEXBAR_BUTTONS do
		button = CreateFrame("CheckButton", "zExButton"..id,UIParent,"ActionBarButtonTemplate")
		_G["zExButton"..id.."NormalTexture"]:SetWidth(60)
		_G["zExButton"..id.."NormalTexture"]:SetHeight(60)
		_G["zExButton"..id.."NormalTexture"]:SetVertexColor(1.0, 1.0, 1.0, 0.5)
		button.buttonType = "ZEXBUTTON"
	end

	-- create bars
	local bar, page
	for id = 1, NUM_ZEXBAR_BAR do
		page = 11 - id
		if id == 2 then
			if zBar3.class == "DRUID" then page = 8 end
			if zBar3.class == "WARRIOR" then page = 1 end
		end
		-- create normal bar
		self:New("zExBar", id, page)
		-- create shadow bar
		self:New("zShadow", id, page)

		zExBars:UpdateShadows(id)
	end

	-- grid stuff
	zBar3:RegisterGridUpdater(zExBars.UpdateGrid)

end

function zExBars:GetButton(i)
	if self.isShadow then return _G[zBar3.buttons[self:GetName()..i]] end
	return _G["zExButton"..i + (self:GetID()-1)*NUM_ACTIONBAR_BUTTONS]
end

--[[ override functions ]]
function zExBars:UpdateExBarButtons() -- for ex bars
	local bar = self
	zExBars:UpdateShadows(bar:GetID())
	zBarT.UpdateButtons(_G["zShadow"..bar:GetID()])
	zBarT.UpdateLayouts(_G["zShadow"..bar:GetID()])

	zBarT.UpdateButtons(bar)
	--zExBars:UpdateGrid(bar)
end
function zExBars:UpdateShadowButtons()
	local bar = self
	zExBars:UpdateShadows(bar:GetID())
	-- since we may changed buttons' parent, need update layouts
	zBarT.UpdateButtons(_G["zExBar"..-bar:GetID()])
	zBarT.UpdateLayouts(_G["zExBar"..-bar:GetID()])

	zBarT.UpdateButtons(bar)
	--zExBars:UpdateGrid(bar)
end

function zExBars:UpdateShadows(index)
	local id = math.abs(index)
	local num = zBar3Data["zExBar"..id].num
	local bar = _G["zExBar"..id]
	local shadow = _G["zShadow"..id]
	for i = 1, 12 do
		local button = _G["zExButton"..i + (id-1)*NUM_ACTIONBAR_BUTTONS]
		if i > 1 then button:ClearAllPoints() end
		if i <= num then
			button:SetParent(bar)
			zBar3.buttons["zExBar"..id..i] = button:GetName()
			zBar3.buttons["zShadow"..id..13-i] = nil
		else
			button:SetParent(shadow)
			zBar3.buttons["zExBar"..id..i] = nil
			zBar3.buttons["zShadow"..id..13-i] = button:GetName()
		end
		_G[button:GetName().."Cooldown"]:SetFrameLevel(button:GetFrameLevel())
	end
	zBar3Data["zShadow"..id].max = 12 - num
	if zBar3Data["zShadow"..id].num > 12 - num then
		zBar3Data["zShadow"..id].num = 12 - num
	elseif zBar3Data["zShadow"..id].num == 0 then
		zBar3Data["zShadow"..id].num = 12 - num
	end
	if zBar3Data["zShadow"..id].linenum > 12 - num then
		zBar3Data["zShadow"..id].linenum = 12 - num
	end
	if shadow:GetButton(1) then
		shadow:GetButton(1):ClearAllPoints()
		shadow:GetButton(1):SetPoint("CENTER")
	end
end

function zExBars:UpdateGrid(bar)
	-- in combat we can't let it be shown or hidden
	if InCombatLockdown() then return end

	if bar then -- update for bar
		for i=1, zBar3Data[bar:GetName()].num do
			bar:GetButton(i):SetAttribute("showgrid", zBar3.showgrid)
			if zBar3.showgrid > 0 then
				bar:GetButton(i):Show()
			end
		end
		return
	end
	-- update all buttons (if not given a bar)
	local button
	for i=1, NUM_ZEXBAR_BUTTONS do
		button = _G["zExButton"..i]
		button:SetAttribute("showgrid", zBar3.showgrid)

		if zBar3.showgrid > 0 then
			if not button:GetAttribute("statehidden") then
				button:Show()
			end
		elseif not HasAction(button.action) then
			button:Hide()
		end
	end
end

--[[ bindings ]]
function zExBars:OnBindingKey(id)
	local button = _G["zExButton"..id]
	if ( keystate == "down" ) then
		if ( button:GetButtonState() == "NORMAL" ) then
			button:SetButtonState("PUSHED");
		end
	else
		if ( button:GetButtonState() == "PUSHED" ) then
			button:SetButtonState("NORMAL");
			SecureActionButton_OnClick(button, "LeftButton");
			ActionButton_UpdateState(button);
		end
	end
end