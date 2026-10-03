local AWL = ArcaneWizardLibrary

local portraitPath = "Interface\\AddOns\\ArcaneWizardLibrary\\assets\\icon.tga"
local exampleArea = CreateFrame("Frame", nil, UIParent)
exampleArea:SetSize(1260, 640)
exampleArea:SetPoint("CENTER", UIParent, "CENTER", 0, 100)

local function AddExampleLabel(content, text)
	local label = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetPoint("CENTER")
	label:SetText(text)
end

local function PositionWindow(frame, left, top)
	frame:ClearAllPoints()
	frame:SetPoint("TOPLEFT", exampleArea, "TOPLEFT", left, -top)
	frame:Show()
end

local examples = {
	{
		title = "Library / Solid Dark",
		borderStyle = "library",
		backgroundStyle = "solid-dark",
		backgroundAlpha = 1,
		titleTransitionStyle = "line",
		left = 0
	},
	{
		title = "Silver / Solid Library",
		borderStyle = "silver",
		backgroundStyle = "solid-library",
		backgroundAlpha = 1,
		titleTransitionStyle = "strong-shadow",
		left = 320
	},
	{
		title = "Gold / Panel",
		borderStyle = "gold",
		backgroundStyle = "panel",
		backgroundAlpha = 1,
		titleTransitionStyle = "shadow",
		left = 640
	},
	{
		title = "Library / Solid Black (45%)",
		borderStyle = "library",
		backgroundStyle = "solid-black",
		backgroundAlpha = 0.45,
		titleTransitionStyle = "line",
		left = 960
	}
}

for _, example in ipairs(examples) do
	local frame = AWL.Frames:CreateWindow({
		title = example.title,
		width = 300,
		height = 200,
		backgroundStyle = example.backgroundStyle,
		backgroundAlpha = example.backgroundAlpha,
		titleTransitionStyle = example.titleTransitionStyle,
		borderStyle = example.borderStyle,
		showPortrait = false,
		showCloseButton = true,
		movable = true
	})
	AddExampleLabel(
		frame.content,
		"Border: " .. example.borderStyle .. "\nBackground: " .. example.backgroundStyle .. "\nTransition: " .. example.titleTransitionStyle
	)
	PositionWindow(frame, example.left, 0)
end

local largeWindow = AWL.Frames:CreateWindow({
	title = "Silver / Panel - Large with Portrait and Tabs",
	width = 620,
	height = 420,
	backgroundStyle = "panel",
	backgroundAlpha = 1,
	titleTransitionStyle = "strong-shadow",
	borderStyle = "silver",
	showPortrait = true,
	showCloseButton = true,
	movable = true
})
largeWindow.portrait:SetTexture(portraitPath)
PositionWindow(largeWindow, 320, 220)

local tabs = AWL.Frames:CreateTabGroup(largeWindow)
local characterPage = tabs:AddTab("character", "Character")
local accountPage = tabs:AddTab("account", "Account")
local warbandPage = tabs:AddTab("warband", "Warband")
AddExampleLabel(characterPage, "Character")
AddExampleLabel(accountPage, "Account")
AddExampleLabel(warbandPage, "Warband")
