local _, LIB = ...

local ScrollFrameData = LIB.ScrollFrameData

---@class ArcaneWizardLibraryScrollFrame: Frame
---@field background Texture
---@field scrollFrame ScrollFrame
---@field content Frame
---@field scrollBar Frame
---@field scrollUpButton Button
---@field scrollDownButton Button
---@field scrollStep number
---@field requestedContentHeight number

---@class ArcaneWizardLibraryScrollFrameConfig
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
	assert(type(config) == "table", LIB.CommonData.debugPrefix .. "CreateScrollFrame config must be a table.")
	assert(config.parent ~= nil, LIB.CommonData.debugPrefix .. "CreateScrollFrame parent is required.")
	assert(type(config.width) == "number" and config.width >= ScrollFrameData.minimumWidth, LIB.CommonData.debugPrefix .. "CreateScrollFrame width is too small.")
	assert(type(config.height) == "number" and config.height >= ScrollFrameData.minimumHeight, LIB.CommonData.debugPrefix .. "CreateScrollFrame height is too small.")
	assert(type(config.showBorder) == "boolean", LIB.CommonData.debugPrefix .. "CreateScrollFrame showBorder must be a boolean.")
	assert(
		type(config.backgroundAlpha) == "number" and config.backgroundAlpha >= 0 and config.backgroundAlpha <= 1,
		LIB.CommonData.debugPrefix .. "CreateScrollFrame backgroundAlpha must be between 0 and 1."
	)
	local insets = config.contentInsets or ScrollFrameData.contentInsets
	assert(type(insets) == "table", LIB.CommonData.debugPrefix .. "CreateScrollFrame contentInsets must be a table.")

	for _, side in ipairs({"left", "right", "top", "bottom"}) do
		assert(type(insets[side]) == "number" and insets[side] >= 0, LIB.CommonData.debugPrefix .. "CreateScrollFrame contentInsets." .. side .. " must be non-negative.")
	end

	assert(
		insets.left + insets.right < config.width and insets.top + insets.bottom < config.height,
		LIB.CommonData.debugPrefix .. "CreateScrollFrame contentInsets leave no content area."
	)

	local frame = CreateFrame("Frame", nil, config.parent, "BackdropTemplate")
	frame:SetSize(config.width, config.height)

	local backdrop = CopyTable(BACKDROP_TOAST_12_12)

	if not config.showBorder then
		backdrop.edgeFile = nil
		backdrop.insets = nil
	end

	frame:SetBackdrop(backdrop)
	frame.background = frame.Center
	frame.background:SetAlpha(config.backgroundAlpha)

	frame.scrollStep = ScrollFrameData.wheelStep
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
	bar:SetPoint("TOPRIGHT", -ScrollFrameData.barInset, -insets.top)
	bar:SetPoint("BOTTOMRIGHT", -ScrollFrameData.barInset, insets.bottom)
	frame.scrollBar = bar
	frame.scrollUpButton = bar.Back
	frame.scrollDownButton = bar.Forward
	ScrollUtil.InitScrollFrameWithScrollBar(scroll, bar)
	scroll:SetPanExtent(frame.scrollStep)

	--- Updates the content height, keeping at least the viewport height.
	---
	--- @param height number Non-negative content height in pixels.
	function frame:SetContentHeight(height)
		assert(type(height) == "number" and height >= 0, LIB.CommonData.debugPrefix .. "ScrollFrame SetContentHeight requires a non-negative number.")
		self.requestedContentHeight = height
		UpdateContentSize(self)
	end

	--- Sets the wheel and arrow scroll distance.
	---
	--- @param step number Positive distance in pixels.
	function frame:SetScrollStep(step)
		assert(type(step) == "number" and step > 0, LIB.CommonData.debugPrefix .. "ScrollFrame SetScrollStep requires a positive number.")
		self.scrollStep = step
		self.scrollFrame:SetPanExtent(step)
		UpdateScrollRange(self)
	end

	--- Sets the scroll offset within the current range.
	---
	--- @param value number Offset in pixels.
	function frame:SetVerticalScroll(value)
		assert(type(value) == "number", LIB.CommonData.debugPrefix .. "ScrollFrame SetVerticalScroll requires a number.")
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
