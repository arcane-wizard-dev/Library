local _, LIB = ...

local Errors = LIB.Internal.Errors

local InputConfig = LIB.UIConfig.Control.input

---@class ArcaneWizardLibraryInputConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the input field.
---@field width number Input width in pixels.
---@field text string Initial input text.
---@field placeholder string Text displayed while the unfocused input is empty.
---@field maxLetters? number Maximum number of characters. Nil or zero allows the game default.
---@field onTextChanged? fun(text: string, userInput: boolean, input: ArcaneWizardLibraryInput) Called after the text changes.
---@field onEnterPressed? fun(text: string, input: ArcaneWizardLibraryInput) Called before Enter clears focus.

---@class ArcaneWizardLibraryInput: EditBox
---@field Placeholder FontString
---@field ClearButton Button
---@field placeholderText string
---@field isClearButtonChange boolean
---@field onTextChanged? fun(text: string, userInput: boolean, input: ArcaneWizardLibraryInput)
---@field onEnterPressed? fun(text: string, input: ArcaneWizardLibraryInput)

-----------------------
--- Local Functions ---
-----------------------

local function UpdateInput(input)
	input.Placeholder:SetShown(not input:HasFocus() and input:GetText() == "" and input.placeholderText ~= "")
	input.ClearButton:SetShown(input:IsEnabled() and input:GetText() ~= "")
end

------------------------
--- Public Functions ---
------------------------

--- Creates a native Blizzard input with a placeholder and clear button.
---
--- @param config ArcaneWizardLibraryInputConfig Input configuration.
---
--- @return ArcaneWizardLibraryInput input The created input field.
function ArcaneWizardLibrary.Controls:CreateInput(config)
	assert(type(config) == "table", Errors:Format(config, "CreateInput", "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, "CreateInput", "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= InputConfig.minimumWidth,
		Errors:Format(config, "CreateInput", "The 'width' value must be at least " .. InputConfig.minimumWidth .. ".")
	)
	assert(type(config.text) == "string", Errors:Format(config, "CreateInput", "The 'text' value must be a string."))
	assert(type(config.placeholder) == "string", Errors:Format(config, "CreateInput", "The 'placeholder' value must be a string."))
	assert(
		config.maxLetters == nil
		or type(config.maxLetters) == "number"
		and config.maxLetters >= 0
		and config.maxLetters == math.floor(config.maxLetters),
		Errors:Format(config, "CreateInput", "The 'maxLetters' value must be a non-negative integer or nil.")
	)
	assert(
		config.onTextChanged == nil or type(config.onTextChanged) == "function",
		Errors:Format(config, "CreateInput", "The 'onTextChanged' callback must be a function or nil.")
	)
	assert(
		config.onEnterPressed == nil or type(config.onEnterPressed) == "function",
		Errors:Format(config, "CreateInput", "The 'onEnterPressed' callback must be a function or nil.")
	)

	local input = CreateFrame("EditBox", nil, config.parent, "SearchBoxTemplate")
	Errors:SetOwner(input, config)
	input:SetSize(config.width, InputConfig.height)
	input:SetAutoFocus(false)

	input.Placeholder = input.Instructions
	input.ClearButton = input.clearButton
	input.searchIcon:Hide()

	input:SetTextInsets(InputConfig.textLeftInset, InputConfig.textRightInset, 0, 0)
	input.Placeholder:ClearAllPoints()
	input.Placeholder:SetPoint("LEFT", InputConfig.textLeftInset, 0)
	input.Placeholder:SetPoint("RIGHT", -InputConfig.textRightInset, 0)

	--- Sets the text displayed while the unfocused input is empty.
	---
	--- @param text string The placeholder text.
	function input:SetPlaceholder(text)
		assert(type(text) == "string", Errors:Format(self, "Input:SetPlaceholder", "The placeholder text must be a string."))

		self.placeholderText = text
		self.Placeholder:SetText(text)
		UpdateInput(self)
	end

	--- Returns the configured placeholder text.
	---
	--- @return string text The placeholder text.
	function input:GetPlaceholder()
		return self.placeholderText
	end

	input:SetPlaceholder(config.placeholder)

	if config.maxLetters then
		input:SetMaxLetters(config.maxLetters)
	end

	input:SetText(config.text)
	input.onTextChanged = config.onTextChanged
	input.onEnterPressed = config.onEnterPressed

	input:HookScript("OnTextChanged", function(self, userInput)
		UpdateInput(self)

		if self.onTextChanged then
			self.onTextChanged(self:GetText(), not not (userInput or self.isClearButtonChange), self)
		end
	end)

	input:SetScript("OnEnterPressed", function(self)
		if self.onEnterPressed then
			self.onEnterPressed(self:GetText(), self)
		end

		self:ClearFocus()
	end)

	input.ClearButton:SetScript("OnClick", function()
		input.isClearButtonChange = true
		input:SetText("")
		input.isClearButtonChange = false
		input:SetFocus()
	end)

	input:HookScript("OnEditFocusGained", UpdateInput)
	input:HookScript("OnEditFocusLost", UpdateInput)
	input:HookScript("OnEnable", UpdateInput)

	input:HookScript("OnDisable", function(self)
		self:ClearFocus()
		UpdateInput(self)
	end)

	UpdateInput(input)

	return input
end
