local AWL = ArcaneWizardLibrary
local started = false

local function ShowPreview()
	local styles = { "toast", "tooltip" }
	local width, height, gap = 300, 150, 24
	local yOffset = 30
	local totalWidth = width * 2 + gap
	local totalHeight = height * 2 + gap
	local scale = math.min(1, (UIParent:GetWidth() - 72) / totalWidth, (UIParent:GetHeight() - 72) / totalHeight)

	for row = 0, 1 do
		for index, style in ipairs(styles) do
			local border = row == 0
			local popup = AWL.Frames:CreatePopup({
				width = width,
				height = height,
				style = style,
				backgroundAlpha = 0.9,
				showBorder = border,
				showCloseButton = true,
				closeButton = { size = 18, point = "TOPRIGHT", x = -3, y = -3 },
				movable = true,
				closeOnEscape = true
			})
			popup:SetFrameStrata("DIALOG")
			popup:SetScale(scale)
			popup:ClearAllPoints()
			popup:SetPoint("TOPLEFT", UIParent, "CENTER",
				-totalWidth / 2 + (index - 1) * (width + gap),
				totalHeight / 2 + yOffset - row * (height + gap))

			local heading = popup.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			heading:SetPoint("TOPLEFT", popup.content, "TOPLEFT", 4, -4)
			heading:SetText("Popup: " .. style)

			local text = popup.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			text:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -12)
			text:SetWidth(width - 28)
			text:SetJustifyH("LEFT")
			text:SetText((border and "With border" or "Without border") .. "\n\nNative background color, 90% opacity.")
			popup:Show()
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
