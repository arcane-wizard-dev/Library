local AWL = ArcaneWizardLibrary
local started = false

local function ShowPreview()
	local styles = { "tiled", "tiled-dark", "textured", "shaded", "shaded-alt" }
	local width, height, gap = 380, 260, 20
	local totalWidth = width * 3 + gap * 2
	local totalHeight = height * 2 + gap
	local scale = math.min(1, (UIParent:GetWidth() - 72) / totalWidth, (UIParent:GetHeight() - 72) / totalHeight)

	for index, style in ipairs(styles) do
		local window = AWL.Frames:CreateWindow({
			title = "Inset: " .. style,
			width = width,
			height = height,
			style = "solid",
			backgroundAlpha = 1,
			showPortrait = false,
			showCloseButton = true,
			movable = true,
			closeOnEscape = true
		})
		window:SetFrameStrata("DIALOG")
		window:SetScale(scale)
		window:ClearAllPoints()
		window:SetPoint("TOPLEFT", UIParent, "CENTER",
			-totalWidth / 2 + (index - 1) % 3 * (width + gap),
			totalHeight / 2 - math.floor((index - 1) / 3) * (height + gap))

		local inset = AWL.Frames:CreateInset({
			parent = window,
			width = width - 24,
			height = height - 48,
			backgroundStyle = style,
			backgroundAlpha = 1
		})
		inset:SetPoint("TOPLEFT", window, "TOPLEFT", 12, -36)

		local heading = inset:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		heading:SetPoint("TOPLEFT", inset, "TOPLEFT", 14, -14)
		heading:SetText(style)

		local text = inset:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		text:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", 0, -12)
		text:SetWidth(width - 52)
		text:SetJustifyH("LEFT")
		text:SetText("Native inset with full background opacity.\n\nMissing atlases use the Library's fallback texture.")
		window:Show()
	end
end

local startup = CreateFrame("Frame")
startup:RegisterEvent("PLAYER_ENTERING_WORLD")
startup:SetScript("OnEvent", function()
	if started then return end
	started = true

	C_Timer.After(1, ShowPreview)
end)
