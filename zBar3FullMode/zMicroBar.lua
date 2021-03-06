local _G = getfenv(0)

CreateFrame("Frame", "zMicroBar", UIParent, "SecureHandlerStateTemplate")
zBar3:AddPlugin(zMicroBar, zMainBar)
zBar3:AddBar(zMicroBar)

local function shouldAddButton(name)
	local accept
	if name == 'HelpMicroButton' then
		accept = not isStoreEnabled
	elseif name == 'StoreMicroButton' then
		accept = isStoreEnabled
	else
		accept = true
	end
	return accept
end 

function zMicroBar:Load()
	local isStoreEnabled = C_StorePublic.IsEnabled()
	local numBtns = 0
	for _, btn in ipairs({MainMenuBarArtFrame:GetChildren()}) do
		local name = btn:GetName()

		if name 
				and name:match('(%w+)MicroButton$')
				and shouldAddButton(name)
		then
			numBtns = numBtns + 1
			zBar3.buttons['zMicroBar'..numBtns] = name
			
			btn:SetParent(self)
			btn:ClearAllPoints()
			btn:SetPoint("BOTTOM")
		end
	end

	zBar3.defaults["zMicroBar"].saves.num = numBtns
	zBar3.defaults["zMicroBar"].saves.max = numBtns
	zBar3.defaults["zMicroBar"].saves.linenum = numBtns

	self:GetTab():GetNormalTexture():SetWidth(42)
	self:GetTab():GetHighlightTexture():SetWidth(42)

	self:Hook()
end

function zMicroBar:GetChildSizeAdjust(attachPoint)
	if attachPoint == "BOTTOMLEFT" then
		return 2*self:GetScale(), 0
	elseif attachPoint == "TOPRIGHT" then
		return 0, -22*self:GetScale()
	end
end

function zMicroBar:Hook()
	hooksecurefunc("UpdateMicroButtonsParent", 
		function(parent)
			zBar3:SafeCallFunc(zMicroBar.ResetChildren, zMicroBar)
		end)

	hooksecurefunc("UpdateMicroButtons", 
		function()
			zBar3:SafeCallFunc(zMicroBar.UpdateLayouts, zMicroBar)
			zBar3:SafeCallFunc(zMicroBar.UpdateButtons, zMicroBar)
		end)
end

function zMicroBar:UpdateButtons()
	zBarT.UpdateButtons(self)

	for i = 1, zBar3.defaults["zMicroBar"].saves.max do
		local button = self:GetButton(i)
		if button:GetAttribute("statehidden") then
			button:SetParent(zBar3.hiddenFrame)
		else
			button:SetParent(self)
			button:Show()
		end
	end
	zMicroBar:GetButton(1):ClearAllPoints()
	zMicroBar:GetButton(1):SetPoint("BOTTOM")
end

function zMicroBar:ResetChildren()
	for i = 1, self:GetNumButtons() do
		self:GetButton(i):SetParent(self)
		self:GetButton(i):ClearAllPoints()
		self:GetButton(i):SetPoint("BOTTOM")
	end
end