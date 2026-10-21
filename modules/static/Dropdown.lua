local _, LIB = ...

local Errors = LIB.Internal.Errors

local DropdownConfig = LIB.UIConfig.Control.dropdown

---@class ArcaneWizardLibraryDropdownOption
---@field label? string Displayed option or group label.
---@field value? string|number|boolean Selectable option value.
---@field icon? string|number Optional texture path or file ID.
---@field atlas? string Optional texture atlas name.
---@field textColor? number[] Optional RGB or RGBA label color.
---@field children? ArcaneWizardLibraryDropdownOption[] Nested options.
---@field divider? boolean Whether the entry is a divider.
---@field disabled? boolean Whether the entry is disabled.

---@class ArcaneWizardLibraryDropdownConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the dropdown.
---@field width number Dropdown width in pixels.
---@field options ArcaneWizardLibraryDropdownOption[]|fun(): ArcaneWizardLibraryDropdownOption[] Static options or a dynamic options provider.
---@field selectedValue? string|number|boolean Initially selected option value.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibraryDropdownOption, dropdown: ArcaneWizardLibraryDropdown) Called after a user changes the selection.

---@class ArcaneWizardLibraryDropdown: DropdownButton
---@field value? string|number|boolean Currently selected value.
---@field optionsSource ArcaneWizardLibraryDropdownOption[]|fun(): ArcaneWizardLibraryDropdownOption[] Static options or a dynamic options provider.
---@field onValueChanged? fun(value: string|number|boolean, option: ArcaneWizardLibraryDropdownOption, dropdown: ArcaneWizardLibraryDropdown)
---@field defaultText string Text displayed without a selection.
---@field emptyText string Text displayed when the menu has no entries.
---@field SetDefaultText fun(self: ArcaneWizardLibraryDropdown, text: string)
---@field SetupMenu fun(self: ArcaneWizardLibraryDropdown, generator: fun(owner: ArcaneWizardLibraryDropdown, root: table))
---@field GetValue fun(self: ArcaneWizardLibraryDropdown): string|number|boolean|nil
---@field SetValue fun(self: ArcaneWizardLibraryDropdown, value: string|number|boolean|nil)
---@field SetEmptyText fun(self: ArcaneWizardLibraryDropdown, text: string)

-----------------------
--- Local Functions ---
-----------------------

local function IsDropdownValue(value)
	local valueType = type(value)

	return valueType == "string" or valueType == "number" or valueType == "boolean"
end

local function ValidateDropdownOptions(options, values, context)
	assert(type(options) == "table", Errors:Format(context.owner, "CreateDropdown", context.path .. " must return or contain a table."))

	for index, option in ipairs(options) do
		local optionPath = context.path .. " option " .. index
		assert(type(option) == "table", Errors:Format(context.owner, "CreateDropdown", optionPath .. " must be a table."))

		if option.divider then
			assert(
				option.disabled == nil or type(option.disabled) == "boolean",
				Errors:Format(context.owner, "CreateDropdown", "The 'disabled' value of " .. optionPath .. " must be a boolean or nil.")
			)
		else
			assert(
				type(option.label) == "string" and option.label ~= "",
				Errors:Format(context.owner, "CreateDropdown", "The 'label' value of " .. optionPath .. " must be a non-empty string.")
			)
			assert(
				option.disabled == nil or type(option.disabled) == "boolean",
				Errors:Format(context.owner, "CreateDropdown", "The 'disabled' value of " .. optionPath .. " must be a boolean or nil.")
			)
			assert(
				option.icon == nil or type(option.icon) == "string" or type(option.icon) == "number",
				Errors:Format(context.owner, "CreateDropdown", "The 'icon' value of " .. optionPath .. " must be a texture path, file ID, or nil.")
			)
			assert(
				option.atlas == nil or type(option.atlas) == "string",
				Errors:Format(context.owner, "CreateDropdown", "The 'atlas' value of " .. optionPath .. " must be a string or nil.")
			)
			assert(not (option.icon and option.atlas), Errors:Format(context.owner, "CreateDropdown", optionPath .. " cannot define both 'icon' and 'atlas'."))

			if option.textColor then
				assert(
					type(option.textColor) == "table" and #option.textColor >= 3,
					Errors:Format(context.owner, "CreateDropdown", "The 'textColor' of " .. optionPath .. " must contain at least red, green, and blue values.")
				)

				for colorIndex = 1, math.min(#option.textColor, 4) do
					local colorValue = option.textColor[colorIndex]
					assert(
						type(colorValue) == "number" and colorValue >= 0 and colorValue <= 1,
						Errors:Format(context.owner, "CreateDropdown", "The 'textColor' values of " .. optionPath .. " must be numbers between 0 and 1.")
					)
				end
			end

			if option.children then
				assert(option.value == nil, Errors:Format(context.owner, "CreateDropdown", optionPath .. " cannot define both 'value' and 'children'."))
				ValidateDropdownOptions(option.children, values, { path = optionPath .. " children", owner = context.owner })
			else
				assert(
					IsDropdownValue(option.value),
					Errors:Format(context.owner, "CreateDropdown", "The 'value' of " .. optionPath .. " must be a string, number, or boolean.")
				)
				assert(not values[option.value], Errors:Format(context.owner, "CreateDropdown", "Option values must be unique."))
				values[option.value] = true
			end
		end
	end
end

local function FindDropdownOption(options, value)
	for _, option in ipairs(options) do
		if option.children then
			local childOption = FindDropdownOption(option.children, value)
			if childOption then
				return childOption
			end
		elseif not option.divider and option.value == value then
			return option
		end
	end
end

local function ResolveOptions(dropdown)
	local options = dropdown.optionsSource

	if type(options) == "function" then
		options = options()
	end

	ValidateDropdownOptions(options, {}, { path = "Options", owner = dropdown })

	return options
end

local function PopulateMenu(dropdown, root, options)
	root:SetScrollMode(DropdownConfig.menuMaximumHeight)

	for _, option in ipairs(options) do
		if option.divider then
			root:CreateDivider()
		else
			local entry

			if option.children then
				entry = root:CreateButton(option.label)
				PopulateMenu(dropdown, entry, option.children)
			else
				entry = root:CreateRadio(option.label, function() return dropdown.value == option.value end, function()
					dropdown.value = option.value

					if dropdown.onValueChanged then
						dropdown.onValueChanged(option.value, option, dropdown)
					end
				end)
			end

			entry:SetEnabled(not option.disabled)

			if option.icon or option.atlas or option.textColor then
				entry:AddInitializer(function(button)
					if option.textColor then
						button.fontString:SetTextColor(unpack(option.textColor))
					end

					if option.icon or option.atlas then
						local icon = button:AttachTexture()

						if option.atlas then
							icon:SetAtlas(option.atlas)
						else
							icon:SetTexture(option.icon)
						end

						icon:SetSize(DropdownConfig.menuIconSize, DropdownConfig.menuIconSize)
						icon:SetPoint("LEFT", button.fontString, "RIGHT", DropdownConfig.menuIconSpacing, 0)

						return button.fontString:GetUnboundedStringWidth() + DropdownConfig.menuIconWidth, DropdownConfig.menuRowHeight
					end
				end)
			end
		end
	end
end

------------------------
--- Public Functions ---
------------------------

--- Creates a Blizzard dropdown with icons and nested option groups.
---
--- @param config ArcaneWizardLibraryDropdownConfig Dropdown configuration.
---
--- @return ArcaneWizardLibraryDropdown dropdown The created dropdown.
function ArcaneWizardLibrary.Controls:CreateDropdown(config)
	assert(type(config) == "table", Errors:Format(config, "CreateDropdown", "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, "CreateDropdown", "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= DropdownConfig.minimumWidth,
		Errors:Format(config, "CreateDropdown", "The 'width' value must be at least " .. DropdownConfig.minimumWidth .. ".")
	)
	assert(
		type(config.options) == "table" or type(config.options) == "function",
		Errors:Format(config, "CreateDropdown", "The 'options' value must be a table or function.")
	)
	assert(
		config.selectedValue == nil or IsDropdownValue(config.selectedValue),
		Errors:Format(config, "CreateDropdown", "The 'selectedValue' must be a string, number, boolean, or nil.")
	)
	assert(
		config.onValueChanged == nil or type(config.onValueChanged) == "function",
		Errors:Format(config, "CreateDropdown", "The 'onValueChanged' callback must be a function or nil.")
	)

	local dropdown = CreateFrame("DropdownButton", nil, config.parent, "WowStyle1DropdownTemplate")
	Errors:SetOwner(dropdown, config)
	dropdown:SetWidth(config.width)
	dropdown.optionsSource = config.options
	dropdown.onValueChanged = config.onValueChanged
	dropdown.emptyText = "No options"
	dropdown:SetDefaultText("Select...")

	--- Returns the selected value.
	---
	--- @return string|number|boolean|nil value The selected value.
	function dropdown:GetValue()
		return self.value
	end

	--- Selects an option without invoking onValueChanged.
	---
	--- @param value string|number|boolean|nil An option value, or nil to clear it.
	function dropdown:SetValue(value)
		assert(value == nil or IsDropdownValue(value), Errors:Format(self, "Dropdown:SetValue", "The selected value is invalid."))
		assert(
			value == nil or FindDropdownOption(ResolveOptions(self), value),
			Errors:Format(self, "Dropdown:SetValue", "The selected value must match an option.")
		)
		self.value = value
		self:GenerateMenu()
	end

	--- Replaces the options and refreshes the menu.
	---
	--- @param options table|function Static options or a provider.
	function dropdown:SetOptions(options)
		assert(
			type(options) == "table" or type(options) == "function",
			Errors:Format(self, "Dropdown:SetOptions", "The options source must be a table or function.")
		)
		self.optionsSource = options
		self:GenerateMenu()
	end

	--- Sets the text shown in an empty menu.
	---
	--- @param text string The empty-menu text.
	function dropdown:SetEmptyText(text)
		assert(type(text) == "string", Errors:Format(self, "Dropdown:SetEmptyText", "The empty-menu text must be a string."))
		self.emptyText = text
		self:GenerateMenu()
	end

	--- Opens or closes the native menu.
	function dropdown:ToggleMenu()
		self:SetMenuOpen(not self:IsMenuOpen())
	end

	dropdown:SetupMenu(function(owner, root)
		local options = ResolveOptions(owner)

		if owner.value ~= nil and not FindDropdownOption(options, owner.value) then
			owner.value = nil
		end

		if #options == 0 then
			root:CreateButton(owner.emptyText):SetEnabled(false)
		else
			PopulateMenu(owner, root, options)
		end
	end)

	dropdown:HookScript("OnHide", function(self)
		self:CloseMenu()
	end)

	dropdown:HookScript("OnDisable", function(self)
		self:CloseMenu()
	end)

	dropdown:SetValue(config.selectedValue)

	return dropdown
end
