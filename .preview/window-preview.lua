local AWL = ArcaneWizardLibrary
local started = false

local function ShowPreview()
	local styles = { "standard", "flat", "solid" }
	local width, height, gap = 330, 220, 28
	local totalWidth = width * 3 + gap * 2
	local totalHeight = height * 2 + gap
	local scale = math.min(1, (UIParent:GetWidth() - 72) / totalWidth, (UIParent:GetHeight() - 72) / totalHeight)

	for row = 0, 1 do
		for index, style in ipairs(styles) do
			local portrait = row == 1
			local window = AWL.Frames:CreateWindow({
				title = "Window: " .. style,
				width = width,
				height = height,
				style = style,
				backgroundAlpha = 1,
				showPortrait = portrait,
				showCloseButton = true,
				movable = true,
				closeOnEscape = true
			})
			window:SetFrameStrata("DIALOG")
			window:SetScale(scale)
			window:ClearAllPoints()
			window:SetPoint("TOPLEFT", UIParent, "CENTER",
				-totalWidth / 2 + (index - 1) * (width + gap),
				totalHeight / 2 - row * (height + gap))

			if portrait then
				window.portrait:SetTexture("Interface\\AddOns\\ArcaneWizardLibrary\\assets\\icon-round.tga")
			end

			local heading = window.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			heading:SetPoint("TOPLEFT", window.content, "TOPLEFT", 14, -20)
			heading:SetText(portrait and "With portrait" or "Without portrait")

			local text = window.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			text:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -12)
			text:SetWidth(width - 44)
			text:SetJustifyH("LEFT")
			text:SetText("Window style: " .. style .. "\n\nNo additional inset frame.")
			window:Show()
		end
	end
end

local startup = CreateFrame("Frame")
startup:RegisterEvent("PLAYER_ENTERING_WORLD")
startup:SetScript("OnEvent", function()
	if started then return end
	started = true

	C_Timer.After(1, ShowPreview)
end)
