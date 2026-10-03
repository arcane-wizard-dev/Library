local addonName = ...
local AWL = ArcaneWizardLibrary

-- Test-only values: no SavedVariables or settings of other addons are changed.
local values = {
	notification = true,
	timestamp = false,
	healthWarning = true,
	healthThreshold = 35,
	manaWarning = false,
	warningStyle = "text",
	flash = true,
	opacity = 75,
	color = "gold"
}

local category, layout = Settings.RegisterVerticalLayoutCategory("Library - Settings Example")
local settingPrefix = "ArcaneWizardLibrary_Example_"

local function FormatPercent(value)
	return value .. "%"
end

layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("General Settings"))

AWL.Settings:AddInfoText(layout, {
	leftText = "Local example",
	rightText = "Values reset on /reload"
})

local notification = AWL.Settings:AddCheckbox(category, {
	variableTable = values,
	settingKey = settingPrefix .. "notification",
	variableName = "notification",
	name = "Chat notification",
	tooltip = "Enable the example's chat notification button.",
	default = true
})

local function IsNotificationEnabled()
	return values.notification
end

AWL.Settings:AddCheckbox(category, {
	variableTable = values,
	settingKey = settingPrefix .. "timestamp",
	variableName = "timestamp",
	name = "Include timestamp",
	tooltip = "Add the current time to the example notification.",
	default = false,
	parentInit = notification,
	parentCondition = IsNotificationEnabled
})

AWL.Settings:AddSeparator(layout)

AWL.Settings:AddButton(layout, {
	name = "Chat preview",
	buttonText = "Send test message",
	tooltip = "Print a test notification in chat.",
	parentInit = notification,
	parentCondition = IsNotificationEnabled,
	onClick = function()
		local timestamp = values.timestamp and (date("%H:%M:%S") .. " ") or ""
		print(timestamp .. "Library: Settings example notification.")
	end
})

layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Modules"))

local combatHeader, isCombatExpanded = AWL.Settings:AddExpandableHeader(layout, "Combat Alerts")
combatHeader.data.expanded = true

AWL.Settings:AddInfoText(layout, {
	leftText = "Preview only",
	rightText = "No combat events are monitored",
	shownPredicate = isCombatExpanded
})

local healthWarning = AWL.Settings:AddCheckboxSliderCombo(category, layout, {
	variableTable = values,
	checkboxSettingKey = settingPrefix .. "healthWarning",
	checkboxVariableName = "healthWarning",
	checkboxName = "Low health warning",
	checkboxTooltip = "Enable the example health warning and its threshold slider.",
	checkboxDefault = true,
	sliderSettingKey = settingPrefix .. "healthThreshold",
	sliderVariableName = "healthThreshold",
	sliderName = "Health threshold",
	sliderTooltip = "Choose the health percentage used by the preview button.",
	sliderDefault = 35,
	sliderMin = 5,
	sliderMax = 95,
	sliderStep = 5,
	sliderFormatter = FormatPercent,
	shownPredicate = isCombatExpanded,
	isNew = true
})

AWL.Settings:AddButton(layout, {
	name = "Warning preview",
	buttonText = "Test warning",
	tooltip = "Show a warning popup with Yes/No buttons. Confirm to print the selected health threshold and warning style in chat.",
	parentInit = healthWarning,
	parentCondition = function() return values.healthWarning end,
	shownPredicate = isCombatExpanded,
	onClick = function()
		local message = "Library: Low health below " .. FormatPercent(values.healthThreshold) .. " (" .. values.warningStyle .. ")."
		AWL.Dialogs:ShowConfirmDialog(
			message .. "\n\nRun this test action?",
			function()
				print(message)
			end,
			function()
				print("Library: Warning test cancelled.")
			end
		)
	end
})

AWL.Settings:AddSeparator(layout):AddShownPredicate(isCombatExpanded)

AWL.Settings:AddCheckbox(category, {
	variableTable = values,
	settingKey = settingPrefix .. "manaWarning",
	variableName = "manaWarning",
	name = "Low mana warning",
	tooltip = "A second example checkbox within the collapsible group.",
	default = false,
	shownPredicate = isCombatExpanded
})

AWL.Settings:AddDropdown(category, {
	variableTable = values,
	settingKey = settingPrefix .. "warningStyle",
	variableName = "warningStyle",
	name = "Warning style",
	tooltip = "Select a style for the warning preview message.",
	default = "text",
	options = {
		{ value = "text", label = "Text only" },
		{ value = "sound", label = "Sound" },
		{ value = "both", label = "Text and sound" }
	},
	shownPredicate = isCombatExpanded
})

local _, isAppearanceExpanded = AWL.Settings:AddExpandableHeader(layout, "Visuals & UI")

local flash = AWL.Settings:AddCheckbox(category, {
	variableTable = values,
	settingKey = settingPrefix .. "flash",
	variableName = "flash",
	name = "Screen flash",
	tooltip = "An example parent checkbox; this demo does not flash the screen.",
	default = true,
	shownPredicate = isAppearanceExpanded
})

AWL.Settings:AddSlider(category, {
	variableTable = values,
	settingKey = settingPrefix .. "opacity",
	variableName = "opacity",
	name = "Flash opacity",
	tooltip = "This slider is enabled while Screen flash is checked.",
	default = 75,
	minValue = 0,
	maxValue = 100,
	step = 5,
	formatter = FormatPercent,
	parentInit = flash,
	parentCondition = function() return values.flash end,
	shownPredicate = isAppearanceExpanded
})

AWL.Settings:AddSeparator(layout):AddShownPredicate(isAppearanceExpanded)

AWL.Settings:AddDropdown(category, {
	variableTable = values,
	settingKey = settingPrefix .. "color",
	variableName = "color",
	name = "Highlight color",
	tooltip = "A dropdown with a New badge; the selection is stored only for this session.",
	default = "gold",
	options = {
		{ value = "gold", label = "Gold" },
		{ value = "silver", label = "Silver" },
		{ value = "red", label = "Red" }
	},
	shownPredicate = isAppearanceExpanded,
	isNew = true
})

AWL.Settings:AddAboutSection(layout, addonName)
Settings.RegisterAddOnCategory(category)

local function OpenExample()
	Settings.OpenToCategory(category:GetID())
end

-- Reopen the example after closing the settings window.
SLASH_ARCANEWIZARDLIBRARYSETTINGSEXAMPLE1 = "/awlsettings"
SlashCmdList.ARCANEWIZARDLIBRARYSETTINGSEXAMPLE = OpenExample

-- Wait until login has finished before opening Blizzard's settings window.
local loginFrame = CreateFrame("Frame")
loginFrame:RegisterEvent("PLAYER_LOGIN")
loginFrame:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	C_Timer.After(0, OpenExample)
end)
