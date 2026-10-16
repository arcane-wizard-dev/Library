local _, LIB = ...

local Errors = LIB.Internal.Errors

local ControlConfig = LIB.UIConfig.Control
local ButtonConfig = ControlConfig.button
local SelectionConfig = ControlConfig.selection

---@class ArcaneWizardLibraryButtonConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the button.
---@field width number Button width in pixels.
---@field label string Displayed button label.
---@field onClick? fun(button: ArcaneWizardLibraryActionButton, mouseButton: string, down: boolean) Called when the button is clicked.

---@class ArcaneWizardLibraryCheckboxConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the checkbox.
---@field width number Checkbox width in pixels.
---@field label string Displayed checkbox label.
---@field checked boolean Initial checked state.
---@field onValueChanged? fun(checked: boolean, checkbox: ArcaneWizardLibrarySelectionControl) Called after a user changes the value.

---@class ArcaneWizardLibraryOptionGroupConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the option group.
---@field width number Width of every option in pixels.
---@field options ArcaneWizardLibraryOptionConfig[] Options in display order.
---@field selectedValue string|number|boolean Initially selected option value.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibrarySelectionControl, group: ArcaneWizardLibraryOptionGroup) Called after a user changes the value.

---@class ArcaneWizardLibraryActionButton: Button

---@class ArcaneWizardLibrarySelectionControl: CheckButton
---@field Text FontString Control label.

---@class ArcaneWizardLibraryOptionConfig
---@field label string Displayed option label.
---@field value string|number|boolean Value represented by the option.

---@class ArcaneWizardLibraryOptionGroup: Frame
---@field buttons ArcaneWizardLibrarySelectionControl[] Option buttons in display order.
---@field buttonsByValue table<string|number|boolean, ArcaneWizardLibrarySelectionControl> Option buttons indexed by value.
---@field value string|number|boolean Currently selected value.
---@field enabled boolean Whether the option group is enabled.

-----------------------
--- Local Functions ---
-----------------------

local function AssertSelectionControlConfig(config, methodName)
	assert(type(config) == "table", Errors:Format(config, methodName, "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, methodName, "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= SelectionConfig.minimumWidth,
		Errors:Format(config, methodName, "The 'width' value must be at least " .. SelectionConfig.minimumWidth .. ".")
	)
	assert(type(config.label) == "string" and config.label ~= "", Errors:Format(config, methodName, "The 'label' value must be a non-empty string."))
	assert(
		config.onValueChanged == nil or type(config.onValueChanged) == "function",
		Errors:Format(config, methodName, "The 'onValueChanged' callback must be a function or nil.")
	)
end

local function ValidateOptions(options, selectedValue, owner)
	assert(type(options) == "table" and #options > 0, Errors:Format(owner, "CreateOptionGroup", "The option list must be a non-empty table."))

	local values = {}
	local selectedValueExists = false

	for index, option in ipairs(options) do
		assert(type(option) == "table", Errors:Format(owner, "CreateOptionGroup", "Option " .. index .. " must be a table."))
		assert(
			type(option.label) == "string" and option.label ~= "",
			Errors:Format(owner, "CreateOptionGroup", "The 'label' value of option " .. index .. " must be a non-empty string.")
		)

		local valueType = type(option.value)
		assert(
			valueType == "string" or valueType == "number" or valueType == "boolean",
			Errors:Format(owner, "CreateOptionGroup", "The 'value' of option " .. index .. " must be a string, number, or boolean.")
		)
		assert(not values[option.value], Errors:Format(owner, "CreateOptionGroup", "Option values must be unique."))

		values[option.value] = true

		if option.value == selectedValue then
			selectedValueExists = true
		end
	end

	assert(selectedValueExists, Errors:Format(owner, "CreateOptionGroup", "The 'selectedValue' must match an option value."))
end

local function CreateSelectionControl(config, template)
	local button = CreateFrame("CheckButton", nil, config.parent, template)
	Errors:SetOwner(button, config)
	button:SetSize(config.width, SelectionConfig.height)

	button.Text = button.Text or button.text
	button.Text:ClearAllPoints()
	button.Text:SetPoint("LEFT", SelectionConfig.textOffset, 0)
	button.Text:SetPoint("RIGHT")
	button.Text:SetJustifyH("LEFT")

	button:SetFontString(button.Text)
	button:SetText(config.label)
	button:SetNormalFontObject(GameFontNormalSmall)
	button:SetHighlightFontObject(GameFontHighlightSmall)
	button:SetDisabledFontObject(GameFontDisableSmall)

	for _, getter in ipairs(SelectionConfig.textureGetters) do
		local texture = button[getter](button)

		if texture then
			texture:ClearAllPoints()
			texture:SetSize(SelectionConfig.iconSize, SelectionConfig.iconSize)
			texture:SetPoint("LEFT")
		end
	end

	return button
end

------------------------
--- Public Functions ---
------------------------

--- Creates a native Blizzard action button.
---
--- @param config ArcaneWizardLibraryButtonConfig Button configuration.
---
--- @return ArcaneWizardLibraryActionButton button The created button.
function ArcaneWizardLibrary.Controls:CreateButton(config)
	assert(type(config) == "table", Errors:Format(config, "CreateButton", "The 'config' value must be a table."))

	assert(config.parent ~= nil, Errors:Format(config, "CreateButton", "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= ButtonConfig.minimumWidth,
		Errors:Format(config, "CreateButton", "The 'width' value must be at least " .. ButtonConfig.minimumWidth .. ".")
	)
	assert(type(config.label) == "string" and config.label ~= "", Errors:Format(config, "CreateButton", "The 'label' value must be a non-empty string."))
	assert(
		config.onClick == nil or type(config.onClick) == "function",
		Errors:Format(config, "CreateButton", "The 'onClick' callback must be a function or nil.")
	)

	local button = CreateFrame("Button", nil, config.parent, "UIPanelButtonTemplate")
	Errors:SetOwner(button, config)
	button:SetSize(config.width, ButtonConfig.height)
	button:SetText(config.label)

	if config.onClick then
		button:HookScript("OnClick", config.onClick)
	end

	return button
end

--- Creates a native Blizzard checkbox.
---
--- @param config ArcaneWizardLibraryCheckboxConfig Checkbox configuration.
---
--- @return ArcaneWizardLibrarySelectionControl checkbox The created checkbox.
function ArcaneWizardLibrary.Controls:CreateCheckbox(config)
	AssertSelectionControlConfig(config, "CreateCheckbox")
	assert(type(config.checked) == "boolean", Errors:Format(config, "CreateCheckbox", "The 'checked' value must be a boolean."))

	local checkbox = CreateSelectionControl(config, "UICheckButtonTemplate")
	checkbox:SetChecked(config.checked)

	if config.onValueChanged then
		checkbox:HookScript("OnClick", function(button)
			config.onValueChanged(not not button:GetChecked(), button)
		end)
	end

	return checkbox
end

--- Creates a group of mutually exclusive options.
---
--- @param config ArcaneWizardLibraryOptionGroupConfig Option group configuration.
---
--- @return ArcaneWizardLibraryOptionGroup group The created option group.
function ArcaneWizardLibrary.Controls:CreateOptionGroup(config)
	assert(type(config) == "table", Errors:Format(config, "CreateOptionGroup", "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, "CreateOptionGroup", "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= SelectionConfig.minimumWidth,
		Errors:Format(config, "CreateOptionGroup", "The 'width' value must be at least " .. SelectionConfig.minimumWidth .. ".")
	)
	assert(
		config.onValueChanged == nil or type(config.onValueChanged) == "function",
		Errors:Format(config, "CreateOptionGroup", "The 'onValueChanged' callback must be a function or nil.")
	)
	ValidateOptions(config.options, config.selectedValue, config)

	local optionCount = #config.options
	local groupHeight = optionCount * SelectionConfig.height + (optionCount - 1) * SelectionConfig.optionSpacing
	local group = CreateFrame("Frame", nil, config.parent)
	Errors:SetOwner(group, config)
	group:SetSize(config.width, groupHeight)
	group.buttons = {}
	group.buttonsByValue = {}
	group.enabled = true

	--- Returns the selected option value.
	---
	--- @return string|number|boolean value The selected value.
	function group:GetValue()
		return self.value
	end

	--- Selects an option without invoking onValueChanged.
	---
	--- @param value string|number|boolean A value present in the option group.
	function group:SetValue(value)
		local selectedButton = self.buttonsByValue[value]
		assert(selectedButton ~= nil, Errors:Format(self, "OptionGroup:SetValue", "The selected value must match an option value."))

		self.value = value

		for _, button in ipairs(self.buttons) do
			button:SetChecked(button == selectedButton)
		end
	end

	--- Enables or disables every option in the group.
	---
	--- @param enabled boolean Whether the options can be selected.
	function group:SetEnabled(enabled)
		assert(type(enabled) == "boolean", Errors:Format(self, "OptionGroup:SetEnabled", "The 'enabled' value must be a boolean."))

		self.enabled = enabled

		for _, button in ipairs(self.buttons) do
			if enabled then
				button:Enable()
			else
				button:Disable()
			end
		end
	end

	for index, option in ipairs(config.options) do
		local button = CreateSelectionControl({ parent = group, width = config.width, label = option.label }, "UIRadioButtonTemplate")
		button:SetPoint("TOPLEFT", 0, -(index - 1) * (SelectionConfig.height + SelectionConfig.optionSpacing))
		button.value = option.value

		button:SetScript("OnClick", function(clickedButton)
			if group.value == clickedButton.value then
				clickedButton:SetChecked(true)

				return
			end

			group:SetValue(clickedButton.value)

			if config.onValueChanged then
				config.onValueChanged(clickedButton.value, clickedButton, group)
			end
		end)

		group.buttons[index] = button
		group.buttonsByValue[option.value] = button
	end

	group:SetValue(config.selectedValue)

	return group
end
