local _, LIB = ...

local InputData = LIB.ControlData.input

---@class ArcaneWizardLibraryInputConfig
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
	assert(type(config) == "table", LIB.CommonData.debugPrefix .. "CreateInput config must be a table.")
	assert(config.parent ~= nil, LIB.CommonData.debugPrefix .. "CreateInput parent is required.")
	assert(type(config.width) == "number" and config.width >= InputData.minimumWidth, LIB.CommonData.debugPrefix .. "CreateInput width must be at least " .. InputData.minimumWidth .. ".")
	assert(type(config.text) == "string", LIB.CommonData.debugPrefix .. "CreateInput text must be a string.")
	assert(type(config.placeholder) == "string", LIB.CommonData.debugPrefix .. "CreateInput placeholder must be a string.")
	assert(config.maxLetters == nil or type(config.maxLetters) == "number" and config.maxLetters >= 0 and config.maxLetters == math.floor(config.maxLetters), LIB.CommonData.debugPrefix .. "CreateInput maxLetters must be a non-negative integer or nil.")
	assert(config.onTextChanged == nil or type(config.onTextChanged) == "function", LIB.CommonData.debugPrefix .. "CreateInput onTextChanged must be a function or nil.")
	assert(config.onEnterPressed == nil or type(config.onEnterPressed) == "function", LIB.CommonData.debugPrefix .. "CreateInput onEnterPressed must be a function or nil.")

	local input = CreateFrame("EditBox", nil, config.parent, "SearchBoxTemplate")
	input:SetSize(config.width, InputData.height)
	input:SetAutoFocus(false)

	input.Placeholder = input.Instructions
	input.ClearButton = input.clearButton
	input.searchIcon:Hide()

	input:SetTextInsets(InputData.textLeftInset, InputData.textRightInset, 0, 0)
	input.Placeholder:ClearAllPoints()
	input.Placeholder:SetPoint("LEFT", InputData.textLeftInset, 0)
	input.Placeholder:SetPoint("RIGHT", -InputData.textRightInset, 0)

	--- Sets the text displayed while the unfocused input is empty.
	---
	--- @param text string The placeholder text.
	function input:SetPlaceholder(text)
		assert(type(text) == "string", LIB.CommonData.debugPrefix .. "Input SetPlaceholder text must be a string.")

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
