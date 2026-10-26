local _, LIB = ...

local Errors = LIB.Internal.Errors

local ScrollFrameConfig = LIB.UIConfig.ScrollFrame

---@class ArcaneWizardLibraryScrollFrame: Frame
---@field background Texture
---@field scrollFrame ScrollFrame
---@field content Frame
---@field scrollBar Frame
---@field scrollUpButton Button
---@field scrollDownButton Button
---@field scrollStep number
---@field requestedContentHeight number
---@field SetContentHeight fun(self: ArcaneWizardLibraryScrollFrame, height: number)
---@field SetScrollStep fun(self: ArcaneWizardLibraryScrollFrame, step: number)
---@field ScrollToTop fun(self: ArcaneWizardLibraryScrollFrame)

---@class ArcaneWizardLibraryScrollFrameConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent frame for the scroll area.
---@field width number Scroll area width in pixels.
---@field height number Scroll area height in pixels.
---@field backgroundAlpha number Background opacity from 0 to 1.
---@field showBorder boolean Whether to create the outer border.
---@field contentInsets? {left: number, right: number, top: number, bottom: number} Non-negative viewport margins; defaults to the Library margins.

-----------------------
--- Local Functions ---
-----------------------

local function UpdateScrollRange(frame)
	local scroll = frame.scrollFrame
	local range = scroll:GetVerticalScrollRange()
	scroll:SetVerticalScroll(math.min(scroll:GetVerticalScroll(), range))
	scroll:GetScript("OnScrollRangeChanged")(scroll, 0, range)
end

local function UpdateContentSize(frame)
	local scroll = frame.scrollFrame
	frame.content:SetWidth(math.max(scroll:GetWidth(), 1))
	frame.content:SetHeight(math.max(frame.requestedContentHeight, scroll:GetHeight(), 1))
	scroll:UpdateScrollChildRect()
	UpdateScrollRange(frame)
end

------------------------
--- Public Functions ---
------------------------

--- Creates a scroll area using Blizzard's scrollbar and scroll handling.
---
--- @param config ArcaneWizardLibraryScrollFrameConfig Scroll frame configuration.
---
--- @return ArcaneWizardLibraryScrollFrame frame The created scroll area.
function ArcaneWizardLibrary.ScrollFrames:CreateScrollFrame(config)
	assert(type(config) == "table", Errors:Format(config, "CreateScrollFrame", "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, "CreateScrollFrame", "A parent frame is required."))
	assert(
		type(config.width) == "number" and config.width >= ScrollFrameConfig.minimumWidth,
		Errors:Format(config, "CreateScrollFrame", "The 'width' value is too small.")
	)
	assert(
		type(config.height) == "number" and config.height >= ScrollFrameConfig.minimumHeight,
		Errors:Format(config, "CreateScrollFrame", "The 'height' value is too small.")
	)
	assert(type(config.showBorder) == "boolean", Errors:Format(config, "CreateScrollFrame", "The 'showBorder' value must be a boolean."))
	assert(
		type(config.backgroundAlpha) == "number" and config.backgroundAlpha >= 0 and config.backgroundAlpha <= 1,
		Errors:Format(config, "CreateScrollFrame", "The 'backgroundAlpha' value must be between 0 and 1.")
	)
	local insets = config.contentInsets or ScrollFrameConfig.contentInsets
	assert(type(insets) == "table", Errors:Format(config, "CreateScrollFrame", "The 'contentInsets' value must be a table."))

	for _, side in ipairs({"left", "right", "top", "bottom"}) do
		assert(
			type(insets[side]) == "number" and insets[side] >= 0,
			Errors:Format(config, "CreateScrollFrame", "The 'contentInsets." .. side .. "' value must be non-negative.")
		)
	end

	assert(
		insets.left + insets.right < config.width and insets.top + insets.bottom < config.height,
		Errors:Format(config, "CreateScrollFrame", "The content insets leave no content area.")
	)

	local frame = CreateFrame("Frame", nil, config.parent, "BackdropTemplate")
	Errors:SetOwner(frame, config)
	frame:SetSize(config.width, config.height)

	local backdrop = CopyTable(BACKDROP_TOAST_12_12)

	if not config.showBorder then
		backdrop.edgeFile = nil
		backdrop.insets = nil
	end

	frame:SetBackdrop(backdrop)
	frame.background = frame.Center
	frame.background:SetAlpha(config.backgroundAlpha)

	frame.scrollStep = ScrollFrameConfig.wheelStep
	frame.requestedContentHeight = 1

	local scroll = CreateFrame("ScrollFrame", nil, frame)
	scroll:SetPoint("TOPLEFT", insets.left, -insets.top)
	scroll:SetPoint("BOTTOMRIGHT", -insets.right, insets.bottom)
	scroll:EnableMouseWheel(true)
	frame.scrollFrame = scroll

	frame.content = CreateFrame("Frame", nil, scroll)
	frame.content:SetSize(1, 1)
	scroll:SetScrollChild(frame.content)

	local bar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")
	bar:SetPoint("TOPRIGHT", -ScrollFrameConfig.barInsets.right, -ScrollFrameConfig.barInsets.top)
	bar:SetPoint("BOTTOMRIGHT", -ScrollFrameConfig.barInsets.right, ScrollFrameConfig.barInsets.bottom)
	frame.scrollBar = bar
	frame.scrollUpButton = bar.Back
	frame.scrollDownButton = bar.Forward
	ScrollUtil.InitScrollFrameWithScrollBar(scroll, bar)
	scroll:SetPanExtent(frame.scrollStep)

	--- Updates the content height, keeping at least the viewport height.
	---
	--- @param height number Non-negative content height in pixels.
	function frame:SetContentHeight(height)
		assert(
			type(height) == "number" and height >= 0,
			Errors:Format(self, "ScrollFrame:SetContentHeight", "The content height must be a non-negative number.")
		)
		self.requestedContentHeight = height
		UpdateContentSize(self)
	end

	--- Sets the wheel and arrow scroll distance.
	---
	--- @param step number Positive distance in pixels.
	function frame:SetScrollStep(step)
		assert(type(step) == "number" and step > 0, Errors:Format(self, "ScrollFrame:SetScrollStep", "The scroll step must be a positive number."))
		self.scrollStep = step
		self.scrollFrame:SetPanExtent(step)
		UpdateScrollRange(self)
	end

	--- Sets the scroll offset within the current range.
	---
	--- @param value number Offset in pixels.
	function frame:SetVerticalScroll(value)
		assert(type(value) == "number", Errors:Format(self, "ScrollFrame:SetVerticalScroll", "The scroll position must be a number."))
		self.scrollFrame:SetVerticalScroll(math.max(0, math.min(value, self.scrollFrame:GetVerticalScrollRange())))
	end

	--- Returns the scroll offset in pixels.
	---
	--- @return number value The vertical offset.
	function frame:GetVerticalScroll()
		return self.scrollFrame:GetVerticalScroll()
	end

	--- Scrolls to the top of the content.
	function frame:ScrollToTop()
		self:SetVerticalScroll(0)
	end

	--- Scrolls to the bottom of the content.
	function frame:ScrollToBottom()
		self:SetVerticalScroll(self.scrollFrame:GetVerticalScrollRange())
	end

	scroll:HookScript("OnSizeChanged", function()
		UpdateContentSize(frame)
	end)

	frame:HookScript("OnShow", function()
		UpdateContentSize(frame)
	end)

	UpdateContentSize(frame)

	return frame
end
