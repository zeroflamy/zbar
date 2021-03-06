local _G = getfenv(0)
local XPHeight = 20

CreateFrame("Frame","zXPBar",UIParent,"SecureFrameTemplate")
zBar3:AddPlugin(zXPBar, zMainBar)
zBar3:AddBar(zXPBar)

function zXPBar:Load()
	zXPBar:SetMovable(true)

	--[[ XP Bar ]]
	MainMenuExpBar:SetParent(zXPBar)
	MainMenuExpBar:ClearAllPoints()
	MainMenuExpBar:SetPoint("BOTTOM")
	MainMenuExpBar_SetWidth(512)
	MainMenuExpBar:SetHeight(XPHeight)
	
	zBar3.buttons['zXPBar1'] = "MainMenuExpBar"
		
	-- text
	MainMenuBarExpText:SetPoint("CENTER",MainMenuExpBar,0,0)
	MainMenuBarExpText:SetFontObject(NumberFontNormalHuge)
	-- ExhaustionTick
	ExhaustionTick:SetParent(MainMenuExpBar)
	ExhaustionTickNormal:SetPoint("BOTTOM",0,-4)
	ExhaustionTickNormal:SetPoint("TOP",0,-4)
	ExhaustionTickHighlight:SetPoint("BOTTOM",0,-4)
	ExhaustionTickHighlight:SetPoint("TOP",0,-4)

	--[[ Textures ]]
	for i, region in ipairs({MainMenuExpBar:GetRegions()}) do
		local name = region:GetName()
		if name then
			if name:match('^MainMenuXPBarTexture(%w+)') then
				region:SetHeight(XPHeight + 3)
				local ULx, ULy, LLx, LLy, URx, URy, LRx, LRy = region:GetTexCoord()
				if name == "MainMenuXPBarTextureLeftCap" then
				  ULx = ULx + 0.03
				elseif name == "MainMenuXPBarTextureRightCap" then
				  URx = URx - 0.03
				end
				region:SetTexCoord(ULx, URx, ULy, ULy + (LLy-ULy) * 0.83)
			elseif name:match('^MainMenuXPBarDiv(%w+)') then
				region:SetHeight(XPHeight - 8)
			end
		end
	end
	
	MainMenuXPBarTextureLeftCap:SetPoint("LEFT", -2, 2)
	MainMenuXPBarTextureRightCap:SetPoint("RIGHT", 2, 2)

	--[[ Reputation Bar ]]
	ReputationWatchBar:SetParent(zXPBar)
	ReputationWatchBar:ClearAllPoints()
	ReputationWatchBar:SetPoint("BOTTOM",MainMenuExpBar,"TOP",-2,0)
	ReputationWatchBar:SetWidth(512)
	ReputationWatchBar:SetHeight(XPHeight)

	ReputationWatchBar.OverlayFrame:SetWidth(512)
	ReputationWatchBar.OverlayFrame:ClearAllPoints()
	ReputationWatchBar.OverlayFrame:SetPoint("BOTTOM",MainMEnuExpBar,"TOP",0,0)

	-- text
	RaiseFrameLevel(ReputationWatchBar.OverlayFrame)
	ReputationWatchBar.OverlayFrame.Text:SetFontObject(NumberFontNormalHuge)
	
	--[[ Textures ]]
	ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0.01, 1.0, 0, 0.171875)
  ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 1.0, 0.171875, 0.34375)
  ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 1.0, 0.34375, 0.515625)
  ReputationWatchBar.StatusBar.WatchBarTexture0:SetTexCoord(0, 1.0, 0.515625, 0.6875)

  ReputationWatchBar.StatusBar.XPBarTexture0:SetTexCoord(0.01, 1.0, 0.79296875, 0.83503125)
  ReputationWatchBar.StatusBar.XPBarTexture1:SetTexCoord(0, 1.0, 0.54296875, 0.58503125)
  ReputationWatchBar.StatusBar.XPBarTexture2:SetTexCoord(0, 1.0, 0.29296875, 0.33503125)
  ReputationWatchBar.StatusBar.XPBarTexture3:SetTexCoord(0, 0.99, 0.04296875, 0.08503125)

  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('TOPLEFT', -2, 0)
  ReputationWatchBar.StatusBar.XPBarTexture0:SetPoint('BOTTOMLEFT', -2, 0)
	
  for i = 1, 3 do
    local texture = ReputationWatchBar.StatusBar["XPBarTexture"..i]
		local prev = ReputationWatchBar.StatusBar["XPBarTexture"..i-1]
    texture:ClearAllPoints()
    texture:SetPoint('TOPLEFT', prev, 'TOPRIGHT')
    texture:SetPoint('BOTTOMLEFT', prev, 'BOTTOMRIGHT')
  end
  ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint('TOPRIGHT', 2, 0)
  ReputationWatchBar.StatusBar.XPBarTexture3:SetPoint('BOTTOMRIGHT', 2, 0)

	
	self:Hook()
end

function zXPBar:Hook()
  local tab = self:GetTab()
  tab:SetScale(1)
	tab.SetScale = function(self, scale)
	  if scale < 1 then
	    zBar3.SetScale(self, 1)
	  else
	    zBar3.SetScale(self, scale)
	  end
	end

	--[[ Hook for VehicleMenuBar ]]
  --[[
	hooksecurefunc("VehicleMenuBar_MoveMicroButtons", function(skinName)
		zBar3:SafeCallFunc(zXPBar.ResetChildren, zXPBar)
		zBar3:SafeCallFunc(zXPBar.UpdateLayouts, zXPBar)
		zBar3:SafeCallFunc(zXPBar.UpdateButtons, zXPBar)
	end)
	]]
	hooksecurefunc("MainMenuBar_UpdateExperienceBars", function(newLevel)
		local name, reaction = GetWatchedFactionInfo()
		if name then
			if ( not newLevel ) then
				newLevel = UnitLevel("player");
			end
			if newLevel < MAX_PLAYER_LEVEL then
				local r,g,b = 0,0,0
				if reaction < 5 then r = 1 end
				if reaction == 3 then g = 0.5 end
				if reaction > 3 then g = 1 end
				ReputationWatchBar.OverlayFrame:SetStatusBarColor(r, g, b);
				ReputationWatchBar.OverlayFrame:SetPoint("BOTTOM", MainMenuExpBar, "TOP", 0, 8)
			else
				ReputationWatchBar.OverlayFrame:SetPoint("BOTTOM", MainMenuExpBar, "BOTTOM", 0, 0)
				ReputationWatchBar.OverlayFrame:SetHeight(XPHeight)
			end
      ReputationWatchBar.OverlayFrame.Text:SetPoint("CENTER", ReputationWatchBar.OverlayFrame, "CENTER", 0, -1);
		end
	end)

end

function zXPBar:UpdateButtons()
	local value = zBar3Data[self:GetName()]
	if not value.num or value.num < 1 then value.num = 1 end
	local width = 512 + 256*(value.num-1)
	MainMenuExpBar_SetWidth(width)
	
	ReputationWatchBar:SetWidth(width)
	ReputationWatchBar.OverlayFrame:SetWidth(width)
	
	for i = 1, 3 do
		local alpha = 0
		if i < value.num+1 then alpha = 1 end
		ReputationWatchBar.StatusBar["WatchBarTexture"..i]:SetAlpha(alpha)
		ReputationWatchBar.StatusBar["XPBarTexture"..i]:SetAlpha(alpha)
	end
end

function zXPBar:ResetChildren()
	MainMenuExpBar:SetParent(zXPBar)
	MainMenuExpBar:ClearAllPoints()
	MainMenuExpBar:SetPoint("BOTTOM")
end

function zXPBar:UpdateLayouts()
end

function zXPBar:Test()
	if not self.sig then
		ReputationWatchBar_Update(MAX_PLAYER_LEVEL)
		self.sig = 1
	else
		ReputationWatchBar_Update()
		self.sig = nil
	end
end