local _, LIB = ...

local Errors = LIB.Internal.Errors

local InputConfig = LIB.UIConfig.Control.input

-----------------------
--- Local Functions ---
-----------------------

local function UpdateInput(input)
	input.Placeholder:SetShown(not input:HasFocus() and input:GetText() == "" and input.placeholderText ~= "")
	input.ClearButton:SetShown(input:IsEnabled() and input:GetText() ~= "")
end

local function CreateClearButton(input)
	local config = InputConfig.clearButton
	local button = CreateFrame("Button", nil, input)
	button:SetSize(config.size, config.size)
	button:SetPoint("RIGHT", -config.rightInset, 0)
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAtlas(config.atlas)
	button.Icon:SetSize(config.iconSize, config.iconSize)
	button.Icon:SetPoint("TOPLEFT", config.iconInset, -config.iconInset)
	button.Icon:SetAlpha(config.iconAlpha)
	button:SetScript("OnEnter", ClearButtonMixin.OnEnter)
	button:SetScript("OnLeave", ClearButtonMixin.OnLeave)
	button:SetScript("OnMouseDown", ClearButtonMixin.OnMouseDown)
	button:SetScript("OnMouseUp", ClearButtonMixin.OnMouseUp)

	return button
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

	local input = CreateFrame("EditBox", nil, config.parent, "InputBoxInstructionsTemplate")
	Errors:SetOwner(input, config)
	input:SetSize(config.width, InputConfig.height)
	input:SetAutoFocus(false)

	input.Placeholder = input.Instructions
	input.ClearButton = CreateClearButton(input)

	input:SetTextInsets(InputConfig.textLeftInset, InputConfig.textRightInset, 0, 0)
	input.Placeholder:ClearAllPoints()
	input.Placeholder:SetPoint("LEFT", InputConfig.textLeftInset, 0)
	input.Placeholder:SetPoint("RIGHT", -InputConfig.textRightInset, 0)

	--- Sets the text displayed while the unfocused input is empty.
	---
	--- @param text string The placeholder text.
	function input:SetPlaceholder(text)
		Errors:Assert(type(text) == "string", self, "Input:SetPlaceholder", "The placeholder text must be a string.")

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
	input:SetScript("OnEscapePressed", function(self)
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
