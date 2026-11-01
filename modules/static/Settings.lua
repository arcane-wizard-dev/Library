local _, LIB = ...

local Errors = LIB.Internal.Errors

local L = LIB.Localization

local SettingsConfig = LIB.UIConfig.Settings

-----------------------
--- Local Functions ---
-----------------------

local function GetInfoTextHeight(config)
	if type(config.height) == "number" then
		return config.height
	end

	if type(config.height) == "string" and SettingsConfig.infoTextHeights[config.height] then
		return SettingsConfig.infoTextHeights[config.height]
	end

	return SettingsConfig.infoTextHeights["default"]
end

local function FormatAboutValue(value, detail)
	if not value then
		return ""
	end

	if detail and detail ~= "" then
		return tostring(value) .. " (" .. tostring(detail) .. ")"
	end

	return tostring(value)
end

local function GetAddonMetadata(addonName, key)
	if not addonName then
		return nil
	end

	return C_AddOns.GetAddOnMetadata(addonName, key)
end

local function ApplyInitializerConfig(initializer, config)
	if config.parentInit and config.parentCondition then
		initializer:SetParentInitializer(config.parentInit, config.parentCondition)
	end

	if config.shownPredicate then
		initializer:AddShownPredicate(config.shownPredicate)
	end

	if config.isNew ~= nil then
		hooksecurefunc(initializer, "InitFrame", function(_, frame)
			if frame.NewFeature then
				frame.NewFeature:SetShown(config.isNew)
			end
		end)
	end
end

local function ApplySettingConfig(setting, config)
	if config.onClick then
		setting:SetValueChangedCallback(config.onClick)
	end
end

local function GetDropdownOptions(options, multiSelect)
	local container = Settings.CreateControlTextContainer()

	for _, option in ipairs(options or {}) do
		if multiSelect then
			assert(
				type(option.value) == "number" and option.value % 1 == 0 and option.value >= 1 and option.value <= 32,
				Errors:Format(nil, "Settings", "Multi-select option values must be bit positions from 1 to 32.")
			)
			container:AddCheckbox(option.value, option.label, option.tooltip)
		else
			container:Add(option.value, option.label, option.tooltip)
		end
	end

	return container:GetData()
end

local function GetDropdownDefault(value, multiSelect)
	if multiSelect then
		if value == nil then
			return 0
		end

		assert(type(value) == "number", Errors:Format(nil, "Settings", "A multi-select default must be a numeric bitmask."))
	end

	return value
end

local function GetMultiSelectText(selections)
	if not selections or #selections == 0 then return L["settings.dropdown.no-selection"] end
	return nil
end

local function ConfigureMultiSelectText(initializer)
	initializer.getSelectionTextFunc = GetMultiSelectText

	-- Blizzard verwendet die Zeile später auch für andere Dropdowns.
	local resetter = initializer.Resetter
	function initializer:Resetter(frame)
		frame.Control.Dropdown:SetSelectionText(nil)
		resetter(self, frame)
	end
end

local function GetAboutConfig(addonName)
	return {
		addonVersion = GetAddonMetadata(addonName, "Version"),
		addonBuildDate = GetAddonMetadata(addonName, "X-BuildDate"),
		addonAuthor = GetAddonMetadata(addonName, "Author"),
		curseforgeLink = GetAddonMetadata(addonName, "X-Curseforge"),
		wagoLink = GetAddonMetadata(addonName, "X-Wago"),
		githubLink = GetAddonMetadata(addonName, "X-Github")
	}
end

------------------------
--- Public Functions ---
------------------------

--- Binds a multi-select bitmask to existing boolean options without changing their saved format.
--- Other keys, such as a controlling checkbox, read and write the original table directly.
---
--- @param variableTable table The existing settings table.
--- @param selectionKey string The virtual key used by the dropdown.
--- @param optionKeys table Boolean option keys in bit-position order (1-32).
--- @return table proxy The variable table for a multi-select dropdown or checkbox-dropdown combination.
function ArcaneWizardLibrary.Settings:CreateMultiSelectProxy(variableTable, selectionKey, optionKeys)
	assert(#optionKeys >= 1 and #optionKeys <= 32, Errors:Format(nil, "Settings", "A multi-select binding requires 1 to 32 option keys."))

	return setmetatable({}, {
		__index = function(_, key)
			if key ~= selectionKey then
				return variableTable[key]
			end

			local selection = 0
			for position, optionKey in ipairs(optionKeys) do
				if variableTable[optionKey] then
					selection = bit.bor(selection, bit.lshift(1, position - 1))
				end
			end
			return selection
		end,
		__newindex = function(_, key, value)
			if key ~= selectionKey then
				variableTable[key] = value
				return
			end

			for position, optionKey in ipairs(optionKeys) do
				variableTable[optionKey] = bit.band(value, bit.lshift(1, position - 1)) ~= 0
			end
		end
	})
end

--- Adds a button to the settings layout.
---
--- @param layout table The settings layout.
--- @param config table Button text, callback, tooltip, optional visibility settings and isNew badge.
---
--- @return table initializer The button initializer.
function ArcaneWizardLibrary.Settings:AddButton(layout, config)
	local initializer = CreateSettingsButtonInitializer(
		config.name,
		config.buttonText,
		config.onClick,
		config.tooltip,
		true
	)

	ApplyInitializerConfig(initializer, config)

	layout:AddInitializer(initializer)

	return initializer
end

--- Registers a checkbox followed by an action button. Unchecking disables the button.
--- Uses checkboxSettingKey, checkboxVariableName, variableTable, checkboxName, checkboxTooltip and checkboxDefault.
--- buttonText and onClick configure the action; optional checkboxOnClick receives setting value changes.
---
--- @param category table The settings category.
--- @param layout table The settings layout.
--- @param config table Checkbox binding, button text and callback, optional visibility settings and isNew badge.
---
--- @return table initializer The combined initializer.
--- @return table settingCheckbox The checkbox setting.
function ArcaneWizardLibrary.Settings:AddCheckboxButtonCombo(category, layout, config)
	local settingCheckbox = Settings.RegisterAddOnSetting(
		category,
		config.checkboxSettingKey,
		config.checkboxVariableName,
		config.variableTable,
		Settings.VarType.Boolean,
		config.checkboxName,
		config.checkboxDefault or false
	)
	local initializer = CreateSettingsCheckboxWithButtonInitializer(
		settingCheckbox,
		config.buttonText,
		config.onClick,
		nil,
		true,
		config.checkboxTooltip
	)

	ApplyInitializerConfig(initializer, config)
	if config.checkboxOnClick then
		settingCheckbox:SetValueChangedCallback(config.checkboxOnClick)
	end

	layout:AddInitializer(initializer)

	return initializer, settingCheckbox
end

--- Adds a static text row to the settings layout.
---
--- @param layout table The settings layout.
--- @param config table Left/right text and optional height and visibility settings.
---
--- @return table initializer The text row initializer.
function ArcaneWizardLibrary.Settings:AddInfoText(layout, config)
	local initializer = Settings.CreateElementInitializer("ArcaneWizardLibrary_SettingsPanelText", {
		leftText = config.leftText or "",
		rightText = config.rightText or "",
	})

	ApplyInitializerConfig(initializer, config)

	local line = layout:AddInitializer(initializer)

	function line:GetExtent()
		return GetInfoTextHeight(config)
	end

	return initializer
end

--- Adds a freely placed horizontal separator to the settings layout.
---
--- @param layout table The settings layout.
---
--- @return table initializer The separator initializer.
function ArcaneWizardLibrary.Settings:AddSeparator(layout)
	local initializer = Settings.CreateElementInitializer("ArcaneWizardLibrary_SettingsSeparatorTemplate", SettingsConfig.separator)
	local line = layout:AddInitializer(initializer)

	function line:GetExtent()
		return SettingsConfig.separator.height
	end

	return initializer
end

--- Registers a checkbox in the settings category.
---
--- @param category table The settings category.
--- @param config table Variable binding, label, tooltip, default, optional behavior settings and isNew badge.
---
--- @return table initializer The checkbox initializer.
--- @return table setting The registered setting.
function ArcaneWizardLibrary.Settings:AddCheckbox(category, config)
	local setting = Settings.RegisterAddOnSetting(
		category,
		config.settingKey,
		config.variableName,
		config.variableTable,
		Settings.VarType.Boolean,
		config.name,
		config.default or false
	)
	local initializer = Settings.CreateCheckbox(category, setting, config.tooltip)

	ApplyInitializerConfig(initializer, config)
	ApplySettingConfig(setting, config)

	return initializer, setting
end

--- Registers a slider in the settings category.
---
--- @param category table The settings category.
--- @param config table Variable binding, label, range, step, default, optional behavior settings and isNew badge.
---
--- @return table initializer The slider initializer.
--- @return table setting The registered setting.
function ArcaneWizardLibrary.Settings:AddSlider(category, config)
	local setting = Settings.RegisterAddOnSetting(
		category,
		config.settingKey,
		config.variableName,
		config.variableTable,
		Settings.VarType.Number,
		config.name,
		config.default or 1
	)
	local options = Settings.CreateSliderOptions(config.minValue or 1, config.maxValue or 10, config.step or 1)

	if config.formatter then
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, config.formatter)
	end

	local initializer = Settings.CreateSlider(category, setting, options, config.tooltip)

	ApplyInitializerConfig(initializer, config)
	ApplySettingConfig(setting, config)

	return initializer, setting
end

--- Registers a combined checkbox and slider.
---
--- @param category table The settings category.
--- @param layout table The settings layout.
--- @param config table Checkbox and slider bindings, labels, defaults, range, optional visibility settings and isNew badge.
---
--- @return table initializer The combined initializer.
--- @return table settingCheckbox The checkbox setting.
--- @return table settingSlider The slider setting.
function ArcaneWizardLibrary.Settings:AddCheckboxSliderCombo(category, layout, config)
	local settingCheckbox = Settings.RegisterAddOnSetting(
		category,
		config.checkboxSettingKey,
		config.checkboxVariableName,
		config.variableTable,
		Settings.VarType.Boolean,
		config.checkboxName,
		config.checkboxDefault or false
	)
	local settingSlider = Settings.RegisterAddOnSetting(
		category,
		config.sliderSettingKey,
		config.sliderVariableName,
		config.variableTable,
		Settings.VarType.Number,
		config.sliderName,
		config.sliderDefault or 1
	)
	local optionsSlider = Settings.CreateSliderOptions(config.sliderMin or 1, config.sliderMax or 10, config.sliderStep or 1)

	if config.sliderFormatter then
		optionsSlider:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, config.sliderFormatter)
	end

	local initializer = CreateSettingsCheckboxSliderInitializer(
		settingCheckbox,
		config.checkboxName,
		config.checkboxTooltip,
		settingSlider,
		optionsSlider,
		config.sliderName,
		config.sliderTooltip
	)
	initializer.GetSetting = function() return settingCheckbox end

	ApplyInitializerConfig(initializer, config)

	layout:AddInitializer(initializer)

	return initializer, settingCheckbox, settingSlider
end

--- Registers a dropdown in the settings category, optionally with multiple selections.
--- With multiSelect = true, option.value is a stable bit position (1-32) and the saved value is a bitmask.
--- The multi-select default is 0 (no selection); for example, 3 selects positions 1 and 2.
---
--- @param category table The settings category.
--- @param config table Variable binding, label, options (value, label, tooltip), default, optional multiSelect, behavior settings and isNew badge.
---
--- @return table initializer The dropdown initializer.
--- @return table setting The registered setting.
function ArcaneWizardLibrary.Settings:AddDropdown(category, config)
	local default = GetDropdownDefault(config.default, config.multiSelect)
	local varType = type(default) == "string" and Settings.VarType.String or Settings.VarType.Number
	local setting = Settings.RegisterAddOnSetting(category, config.settingKey, config.variableName, config.variableTable, varType, config.name, default)

	local function GetOptions()
		return GetDropdownOptions(config.options, config.multiSelect)
	end

	local initializer = Settings.CreateDropdown(category, setting, GetOptions, config.tooltip)
	if config.multiSelect then
		ConfigureMultiSelectText(initializer)
	end

	ApplyInitializerConfig(initializer, config)
	ApplySettingConfig(setting, config)

	return initializer, setting
end

--- Registers a checkbox followed by a dropdown. Unchecking disables the dropdown without clearing its value.
--- Uses checkboxSettingKey, checkboxVariableName, checkboxName, checkboxTooltip and checkboxDefault;
--- dropdownSettingKey, dropdownVariableName, dropdownName, dropdownTooltip, dropdownDefault and dropdownOptions.
--- Both settings use variableTable. Optional checkboxOnClick and dropdownOnClick receive setting value changes.
--- Without multiSelect (or with false), dropdownOptions provide an exclusive single selection.
--- With multiSelect = true, dropdownOptions use the same bit positions and bitmask default as AddDropdown.
---
--- @param category table The settings category.
--- @param layout table The settings layout.
--- @param config table Checkbox and dropdown configuration, optional multiSelect, visibility settings and isNew badge.
---
--- @return table initializer The combined initializer.
--- @return table settingCheckbox The checkbox setting.
--- @return table settingDropdown The dropdown setting.
function ArcaneWizardLibrary.Settings:AddCheckboxDropdownCombo(category, layout, config)
	local default = GetDropdownDefault(config.dropdownDefault, config.multiSelect)
	local varType = type(default) == "string" and Settings.VarType.String or Settings.VarType.Number
	local settingCheckbox = Settings.RegisterAddOnSetting(
		category,
		config.checkboxSettingKey,
		config.checkboxVariableName,
		config.variableTable,
		Settings.VarType.Boolean,
		config.checkboxName,
		config.checkboxDefault or false
	)
	local settingDropdown = Settings.RegisterAddOnSetting(
		category,
		config.dropdownSettingKey,
		config.dropdownVariableName,
		config.variableTable,
		varType,
		config.dropdownName,
		default
	)

	local function GetOptions()
		return GetDropdownOptions(config.dropdownOptions, config.multiSelect)
	end

	local initializer = CreateSettingsCheckboxDropdownInitializer(
		settingCheckbox,
		config.checkboxName,
		config.checkboxTooltip,
		settingDropdown,
		GetOptions,
		config.dropdownName,
		config.dropdownTooltip
	)
	initializer.GetSetting = function() return settingCheckbox end

	if config.multiSelect then
		ConfigureMultiSelectText(initializer)
	end
	ApplyInitializerConfig(initializer, config)

	if config.checkboxOnClick then
		settingCheckbox:SetValueChangedCallback(config.checkboxOnClick)
	end

	if config.dropdownOnClick then
		settingDropdown:SetValueChangedCallback(config.dropdownOnClick)
	end

	layout:AddInitializer(initializer)

	return initializer, settingCheckbox, settingDropdown
end

--- Adds an expandable header section to the settings layout.
---
--- @param layout table The layout object to append the initializer to.
--- @param name string The display name of the header.
--- @param getStatusText? function Returns optional status text appended to the name when the header is displayed.
--- Call initializer:RefreshStatusText() after status changes to update an already visible header.
---
--- @return table initializer The layout initializer object for the header.
--- @return function isExpandedPredicate A function that returns the current expanded state (boolean).
function ArcaneWizardLibrary.Settings:AddExpandableHeader(layout, name, getStatusText)
	local initializer = CreateFromMixins(SettingsExpandableSectionInitializer)
	local data = { name = name, expanded = false }

	initializer:Init("ArcaneWizardLibrary_SettingsExpandTemplate")
	initializer.data = data
	initializer.GetExtent = ScrollBoxFactoryInitializerMixin.GetExtent

	if getStatusText then
		function initializer:GetName()
			local statusText = getStatusText()

			if statusText and statusText ~= "" then
				return self.data.name .. " - " .. statusText
			end

			return self.data.name
		end

		function initializer:RefreshStatusText()
			local frame = self.frame
			if frame and frame:GetElementData() == self then
				frame.Button.Text:SetText(self:GetName())
			end
		end
	end

	layout:AddInitializer(initializer)

	return initializer, function() return data.expanded end
end

--- Adds a standard Profiles section to the settings layout.
---
--- @param layout table The layout object to append the initializers to.
--- @param config table Configuration table. Expected keys: useAccountProfile, onSwitchProfile, onDeleteCharacterProfiles.
function ArcaneWizardLibrary.Settings:AddProfilesSection(layout, config)
	local profileModeText = L["settings.profiles.mode.character"]
	local switchButtonText = L["settings.profiles.switch.button.character-to-account"]

	if config.useAccountProfile then
		profileModeText = L["settings.profiles.mode.account"]
		switchButtonText = L["settings.profiles.switch.button.account-to-character"]
	else
		local characterName = UnitName("player")

		if characterName and characterName ~= "" then
			profileModeText = profileModeText .. " (" .. characterName .. ")"
		end
	end

	layout:AddInitializer(Settings.CreateElementInitializer("ArcaneWizardLibrary_SettingsProfilesHeader", {
		name = L["settings.profiles.section-header"]
	}))

	self:AddInfoText(layout, {
		leftText  = L["settings.profiles.profile-mode"],
		rightText = profileModeText
	})

	self:AddButton(layout, {
		name       = L["settings.profiles.switch.name"],
		buttonText = switchButtonText,
		tooltip    = L["settings.profiles.switch.tooltip"],
		onClick    = function()
			local confirmText = L["settings.profiles.switch.confirm.character-to-account"]

			if config.useAccountProfile then
				confirmText = L["settings.profiles.switch.confirm.account-to-character"]
			end

			ArcaneWizardLibrary.Dialogs:ShowConfirmDialog(confirmText, config.onSwitchProfile)
		end
	})

	self:AddButton(layout, {
		name       = L["settings.profiles.delete-character-profiles.name"],
		buttonText = L["settings.profiles.delete-character-profiles.button"],
		tooltip    = L["settings.profiles.delete-character-profiles.tooltip"],
		onClick    = function()
			ArcaneWizardLibrary.Dialogs:ShowConfirmDialog(
				L["settings.profiles.delete-character-profiles.confirm"],
				config.onDeleteCharacterProfiles
			)
		end
	})
end

--- Adds a standard About section to the settings layout.
---
--- @param layout table The layout object to append the initializers to.
--- @param addonName string Addon name used to read metadata.
--- @param changelog? ArcaneWizardLibraryChangelog Optional changelog versions and notices displayed through an additional button.
function ArcaneWizardLibrary.Settings:AddAboutSection(layout, addonName, changelog)
	assert(layout ~= nil, Errors:Format(addonName, "AddAboutSection", "A settings layout is required."))
	assert(
		type(addonName) == "string" and addonName ~= "",
		Errors:Format(addonName, "AddAboutSection", "The 'addonName' value must be a non-empty string.")
	)

	local config = GetAboutConfig(addonName)

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L["settings.about"]))

	self:AddInfoText(layout, {
		leftText  = L["settings.about.game-version"],
		rightText = FormatAboutValue(ArcaneWizardLibrary.GAME_VERSION, ArcaneWizardLibrary.GAME_FLAVOR),
		height    = "compact"
	})

	self:AddInfoText(layout, {
		leftText  = L["settings.about.addon-version"],
		rightText = FormatAboutValue(config.addonVersion, config.addonBuildDate),
		height    = "compact"
	})

	self:AddInfoText(layout, {
		leftText  = L["settings.about.lib-version"],
		rightText = FormatAboutValue(ArcaneWizardLibrary.ADDON_VERSION, ArcaneWizardLibrary.ADDON_BUILD_DATE),
		height    = "compact"
	})

	self:AddInfoText(layout, {
		leftText  = L["settings.about.author"],
		rightText = config.addonAuthor or ""
	})

	if config.curseforgeLink and config.curseforgeLink ~= "" then
		self:AddButton(layout, {
			name       = L["settings.about.button-curseforge.name"],
			buttonText = L["settings.about.button-curseforge.button"],
			tooltip    = L["settings.about.button-curseforge.tooltip"],
			onClick    = function()
				ArcaneWizardLibrary.Dialogs:ShowLinkDialog(config.curseforgeLink)
			end
		})
	end

	if config.wagoLink and config.wagoLink ~= "" then
		self:AddButton(layout, {
			name       = L["settings.about.button-wago.name"],
			buttonText = L["settings.about.button-wago.button"],
			tooltip    = L["settings.about.button-wago.tooltip"],
			onClick    = function()
				ArcaneWizardLibrary.Dialogs:ShowLinkDialog(config.wagoLink)
			end
		})
	end

	if config.githubLink and config.githubLink ~= "" then
		self:AddButton(layout, {
			name       = L["settings.about.button-github.name"],
			buttonText = L["settings.about.button-github.button"],
			tooltip    = L["settings.about.button-github.tooltip"],
			onClick    = function()
				ArcaneWizardLibrary.Dialogs:ShowLinkDialog(config.githubLink)
			end
		})
	end

	if changelog then
		self:AddButton(layout, {
			name = L["settings.changelog.name"],
			buttonText = L["settings.changelog.button"],
			onClick = function()
				ArcaneWizardLibrary.Frames:OpenChangelog(addonName, changelog)
			end,
			tooltip = L["settings.changelog.tooltip"]
		})
	end
end
