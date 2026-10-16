local _, LIB = ...

local Errors = LIB.Internal.Errors

local FrameConfig = LIB.UIConfig.Frame
local classicTabs = ArcaneWizardLibrary.GAME_TYPE_CLASSIC or ArcaneWizardLibrary.GAME_TYPE_TBC or ArcaneWizardLibrary.GAME_TYPE_MISTS
local TabConfig = classicTabs and FrameConfig.tabs.classic or FrameConfig.tabs.standard
local tabSpacing = ArcaneWizardLibrary.GAME_TYPE_CLASSIC and TabConfig.eraSpacing or TabConfig.spacing
local windowFrames = setmetatable({}, { __mode = "k" })
local popupFrames = setmetatable({}, { __mode = "k" })
local specialFrameCounter = 0
local tabButtonCounter = 0

---@class ArcaneWizardLibraryWindowFrame: Frame
---@field background Texture|Frame Configurable window background.
---@field content Frame Content area inside the window frame.
---@field titleBar Frame Integrated title bar and drag handle.
---@field titleText FontString Title font string.
---@field portraitFrame? Frame Optional portrait frame.
---@field portrait? Texture Optional portrait image.
---@field closeButton? Button Optional close button.
---@field closeOnEscape boolean Whether pressing Escape hides the window.
---@field tabGroup? ArcaneWizardLibraryTabGroup Optional attached tab group.

---@class ArcaneWizardLibraryPopupFrame: Frame
---@field background Texture Configurable popup background.
---@field content Frame Content area inside the popup frame.
---@field closeButton? Button Optional close button.
---@field closeOnEscape boolean Whether pressing Escape hides the popup.
---@field SetBorderShown fun(self: ArcaneWizardLibraryPopupFrame, shown: boolean) Shows or hides the popup border.

---@class ArcaneWizardLibraryCloseButtonConfig
---@field size? number Button width and height in pixels; defaults to Blizzard's size.
---@field point? FramePoint Anchor on the button and its window; defaults to TOPRIGHT.
---@field x? number Horizontal offset; defaults to 0 when overriding the anchor.
---@field y? number Vertical offset; defaults to 0 when overriding the anchor.

---@class ArcaneWizardLibraryInsetFrame: Frame
---@field background Texture Configurable inset background.

---@class ArcaneWizardLibraryInsetConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field parent Frame Parent of the inset.
---@field width number Initial width in pixels.
---@field height number Initial height in pixels.
---@field backgroundStyle? "tiled"|"tiled-dark"|"textured"|"shaded"|"shaded-alt"|"character" Defaults to tiled; character is a legacy alias for textured.
---@field backgroundAlpha number Background opacity from 0 to 1.

---@class ArcaneWizardLibraryWindowConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field title string Text displayed in the title bar.
---@field width number Initial frame width.
---@field height number Initial frame height.
---@field style? "standard"|"flat"|"solid" Native window appearance; defaults to standard. Solid keeps the standard background without top streaks.
---@field backgroundAlpha number Initial background opacity from 0 to 1.
---@field showPortrait boolean Whether to create a portrait frame.
---@field showCloseButton boolean Whether to create a close button.
---@field closeButton? ArcaneWizardLibraryCloseButtonConfig Optional size and anchor overrides.
---@field movable boolean Whether the window can be dragged.
---@field closeOnEscape? boolean Whether Escape hides the window.

---@class ArcaneWizardLibraryPopupConfig
---@field addonName? string Owning addon for errors; inherited from the parent when omitted.
---@field width number Initial frame width.
---@field height number Initial frame height.
---@field style? "toast"|"tooltip" Native popup appearance; defaults to toast.
---@field backgroundAlpha number Initial background opacity from 0 to 1.
---@field showBorder boolean Whether to create a popup border.
---@field showCloseButton boolean Whether to create a close button.
---@field closeButton? ArcaneWizardLibraryCloseButtonConfig Optional size and anchor overrides.
---@field movable boolean Whether the popup can be dragged.
---@field closeOnEscape? boolean Whether Escape hides the popup.

---@class ArcaneWizardLibraryTabPage: Frame
---@field tabId string Unique tab identifier.
---@field tabButton ArcaneWizardLibraryTabButton Button that selects this page.

---@class ArcaneWizardLibraryTabButton: Button
---@field tabId string Unique tab identifier.
---@field tabGroup ArcaneWizardLibraryTabGroup Owning tab group.
---@field label FontString Displayed tab label.

---@class ArcaneWizardLibraryTabGroup: Frame
---@field window ArcaneWizardLibraryWindowFrame Window that owns the tab group.
---@field selectedTabId? string Currently selected tab identifier.
---@field AddTab fun(self: ArcaneWizardLibraryTabGroup, id: string, text: string): ArcaneWizardLibraryTabPage
---@field SelectTab fun(self: ArcaneWizardLibraryTabGroup, id: string): ArcaneWizardLibraryTabPage
---@field GetSelectedTab fun(self: ArcaneWizardLibraryTabGroup): string?, ArcaneWizardLibraryTabPage?
---@field SetTabEnabled fun(self: ArcaneWizardLibraryTabGroup, id: string, enabled: boolean)
---@field SetOnTabChanged fun(self: ArcaneWizardLibraryTabGroup, callback: fun(id: string?, page: ArcaneWizardLibraryTabPage?)?)

-----------------------
--- Local Functions ---
-----------------------

local function ValidateConfig(config, data, methodName)
	assert(type(config.width) == "number" and config.width >= data.minimumWidth, Errors:Format(config, methodName, "The 'width' value is too small."))
	assert(
		type(config.height) == "number" and config.height >= data.minimumHeight,
		Errors:Format(config, methodName, "The 'height' value is too small.")
	)
	assert(type(config.showCloseButton) == "boolean", Errors:Format(config, methodName, "The 'showCloseButton' value must be a boolean."))
	assert(
		type(config.backgroundAlpha) == "number" and config.backgroundAlpha >= 0 and config.backgroundAlpha <= 1,
		Errors:Format(config, methodName, "The 'backgroundAlpha' value must be between 0 and 1.")
	)
	assert(type(config.movable) == "boolean", Errors:Format(config, methodName, "The 'movable' value must be a boolean."))
	assert(
		config.closeOnEscape == nil or type(config.closeOnEscape) == "boolean",
		Errors:Format(config, methodName, "The 'closeOnEscape' value must be a boolean or nil.")
	)

	if config.closeButton ~= nil then
		local button = config.closeButton
		assert(type(button) == "table", Errors:Format(config, methodName, "The 'closeButton' configuration must be a table."))
		assert(
			button.size == nil or type(button.size) == "number" and button.size > 0,
			Errors:Format(config, methodName, "The 'closeButton.size' value must be positive.")
		)
		assert(
			button.point == nil or FrameConfig.anchorPoints[button.point],
			Errors:Format(config, methodName, "The 'closeButton.point' value is invalid.")
		)
		assert(button.x == nil or type(button.x) == "number", Errors:Format(config, methodName, "The 'closeButton.x' value must be a number."))
		assert(button.y == nil or type(button.y) == "number", Errors:Format(config, methodName, "The 'closeButton.y' value must be a number."))
	end
end

local function RegisterDragHandle(frame, handle)
	handle:EnableMouse(true)
	handle:RegisterForDrag("LeftButton")

	handle:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)

	handle:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
	end)
end

local function CreateBaseFrame(config, template)
	local frameName

	if config.closeOnEscape then
		specialFrameCounter = specialFrameCounter + 1
		frameName = "ArcaneWizardLibrarySpecialFrame" .. specialFrameCounter
	end

	local frame = CreateFrame("Frame", frameName, UIParent, template)
	Errors:SetOwner(frame, config)
	frame:SetSize(config.width, config.height)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("MEDIUM")
	frame:SetToplevel(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:SetMovable(config.movable)
	frame.closeOnEscape = config.closeOnEscape == true

	frame:HookScript("OnShow", function(self)
		self:Raise()
	end)

	if frameName then
		table.insert(UISpecialFrames, frameName)
	end

	return frame
end

local function CreateContentFrame(frame, insets)
	frame.content = CreateFrame("Frame", nil, frame)
	frame.content:SetPoint("TOPLEFT", insets.left, -insets.top)
	frame.content:SetPoint("BOTTOMRIGHT", -insets.right, insets.bottom)
end

local function ConfigureCloseButton(frame, config)
	if config.showCloseButton then
		frame.closeButton = frame.CloseButton or CreateFrame("Button", nil, frame, "UIPanelCloseButtonDefaultAnchors")
		local button = config.closeButton

		if button then
			if button.size then
				frame.closeButton:SetSize(button.size, button.size)
			end

			if button.point or button.x or button.y then
				frame.closeButton:ClearAllPoints()
				frame.closeButton:SetPoint(button.point or "TOPRIGHT", frame, button.point or "TOPRIGHT", button.x or 0, button.y or 0)
			end
		end
	elseif frame.CloseButton then
		frame.CloseButton:Hide()
	end
end

--- Shows or hides the popup border, preserving background opacity.
---
--- @param frame ArcaneWizardLibraryPopupFrame The popup frame.
--- @param shown boolean Whether to show the border.
local function SetPopupBorderShown(frame, shown)
	assert(type(shown) == "boolean", Errors:Format(frame, "Popup:SetBorderShown", "The 'shown' value must be a boolean."))
	local state = popupFrames[frame]
	if state.shown == shown then return end

	if frame.NineSlice then
		local color = state.borderColor
		frame:SetBackdropBorderColor(color[1], color[2], color[3], shown and color[4] or 0)
	else
		local alpha = frame.background and frame.background:GetAlpha() or 1
		local backdrop = CopyTable(BACKDROP_TOAST_12_12)

		if not shown then
			backdrop.edgeFile = nil
			backdrop.insets = nil
		end

		frame:SetBackdrop(backdrop)
		frame.background = frame.Center
		frame.background:SetAlpha(alpha)
	end

	state.shown = shown
end

local function RefreshTabButton(button)
	if button.isDisabled then
		PanelTemplates_SetDisabledTabState(button)
	elseif button.tabGroup.selectedTabId == button.tabId then
		PanelTemplates_SelectTab(button)
	else
		PanelTemplates_DeselectTab(button)
	end
end

local function LayoutTabGroup(tabGroup)
	local offset = 0

	for index, entry in ipairs(tabGroup.tabEntries) do
		if index > 1 then
			offset = offset + tabSpacing
		end

		entry.button:ClearAllPoints()
		entry.button:SetPoint("TOPLEFT", tabGroup, "TOPLEFT", offset, 0)
		offset = offset + entry.button:GetWidth()
	end

	tabGroup:SetSize(math.max(offset, 1), FrameConfig.tabs.height)
end

local function ResizeTabButton(button)
	if classicTabs then
		button.Text:SetWidth(0)
		local textWidth = math.ceil(button.Text:GetStringWidth())
		PanelTemplates_TabResize(button, TabConfig.padding, nil, TabConfig.minimumWidth + TabConfig.padding, nil, math.min(textWidth, TabConfig.maximumWidth))

		if textWidth > TabConfig.maximumWidth then
			button.Text:SetWidth(TabConfig.maximumWidth)
		end

		return
	end

	button.Text:SetWidth(0)
	local width = math.max(TabConfig.minimumWidth, button.Text:GetStringWidth() + TabConfig.padding)
	PanelTemplates_TabResize(button, 0, width)
	button.Text:SetWidth(0)
end

local function CreateTabButton(tabGroup, id, text)
	local name
	local groupShown = tabGroup:IsShown()

	if classicTabs then
		tabGroup:Hide()
		tabButtonCounter = tabButtonCounter + 1
		name = "ArcaneWizardLibraryTabButton" .. tabButtonCounter
	end

	local button = CreateFrame("Button", name, tabGroup, TabConfig.template)
	button.tabId = id
	button.tabGroup = tabGroup
	button.Text = button:GetFontString()
	button.label = button.Text
	button:SetText(text)
	ResizeTabButton(button)

	button:SetScript("OnClick", function()
		tabGroup:SelectTab(id)
	end)

	if classicTabs then
		button:SetScript("OnShow", ResizeTabButton)
	else
		button:HookScript("OnShow", ResizeTabButton)
	end

	button:HookScript("OnEvent", function(self)
		if self:IsVisible() then
			ResizeTabButton(self)
		end
	end)

	button:HookScript("OnSizeChanged", function()
		LayoutTabGroup(tabGroup)
	end)

	RefreshTabButton(button)

	if classicTabs and groupShown then
		tabGroup:Show()
	end

	return button, button:GetWidth()
end

--- Adds a tab and its content page; selects the first tab automatically.
---
--- @param tabGroup ArcaneWizardLibraryTabGroup The owning tab group.
--- @param id string The unique, non-empty tab identifier.
--- @param text string The non-empty tab label.
---
--- @return ArcaneWizardLibraryTabPage page The created content page.
local function AddTab(tabGroup, id, text)
	assert(type(id) == "string" and id ~= "", Errors:Format(tabGroup, "TabGroup:AddTab", "The tab ID must be a non-empty string."))
	assert(type(text) == "string" and text ~= "", Errors:Format(tabGroup, "TabGroup:AddTab", "The tab text must be a non-empty string."))
	assert(not tabGroup.tabsById[id], Errors:Format(tabGroup, "TabGroup:AddTab", "The tab ID is already registered."))
	local button, width = CreateTabButton(tabGroup, id, text)
	local page = CreateFrame("Frame", nil, tabGroup.window.content)
	page:SetAllPoints()
	page:Hide()
	page.tabId = id
	page.tabButton = button

	local entry = {
		id = id,
		button = button,
		page = page,
		width = width
	}
	tabGroup.tabEntries[#tabGroup.tabEntries + 1] = entry
	tabGroup.tabsById[id] = entry
	LayoutTabGroup(tabGroup)

	if not tabGroup.selectedTabId then
		tabGroup:SelectTab(id)
	end

	return page
end

--- Selects an enabled tab; calls onTabChanged only when the selection changes.
---
--- @param tabGroup ArcaneWizardLibraryTabGroup The owning tab group.
--- @param id string The registered tab identifier.
---
--- @return ArcaneWizardLibraryTabPage page The selected content page.
local function SelectTab(tabGroup, id)
	local entry = tabGroup.tabsById[id]
	assert(entry, Errors:Format(tabGroup, "TabGroup:SelectTab", "The tab ID is not registered."))
	assert(not entry.button.isDisabled, Errors:Format(tabGroup, "TabGroup:SelectTab", "A disabled tab cannot be selected."))

	if tabGroup.selectedTabId == id then
		return entry.page
	end

	local previousEntry = tabGroup.selectedTabId and tabGroup.tabsById[tabGroup.selectedTabId]

	if previousEntry then
		previousEntry.page:Hide()
	end

	tabGroup.selectedTabId = id
	entry.page:Show()

	if previousEntry then
		RefreshTabButton(previousEntry.button)
	end

	RefreshTabButton(entry.button)
	LayoutTabGroup(tabGroup)

	if tabGroup.onTabChanged then
		tabGroup.onTabChanged(id, entry.page)
	end

	return entry.page
end

--- Returns the selected tab and its content page.
---
--- @param tabGroup ArcaneWizardLibraryTabGroup The owning tab group.
---
--- @return string|nil id The selected tab identifier, or nil when no tab is selected.
--- @return ArcaneWizardLibraryTabPage|nil page The selected content page, or nil.
local function GetSelectedTab(tabGroup)
	local entry = tabGroup.selectedTabId and tabGroup.tabsById[tabGroup.selectedTabId]
	if not entry then
		return nil, nil
	end

	return entry.id, entry.page
end

--- Enables or disables a tab, selecting an enabled replacement when necessary.
---
--- @param tabGroup ArcaneWizardLibraryTabGroup The owning tab group.
--- @param id string The registered tab identifier.
--- @param enabled boolean Whether the tab can be selected.
local function SetTabEnabled(tabGroup, id, enabled)
	local entry = tabGroup.tabsById[id]
	assert(entry, Errors:Format(tabGroup, "TabGroup:SetTabEnabled", "The tab ID is not registered."))
	assert(type(enabled) == "boolean", Errors:Format(tabGroup, "TabGroup:SetTabEnabled", "The 'enabled' value must be a boolean."))

	if enabled then
		entry.button.isDisabled = false
		RefreshTabButton(entry.button)

		if not tabGroup.selectedTabId then
			tabGroup:SelectTab(id)
		end

		return
	end

	entry.button.isDisabled = true
	RefreshTabButton(entry.button)
	if tabGroup.selectedTabId ~= id then
		return
	end

	entry.page:Hide()
	tabGroup.selectedTabId = nil

	for _, replacement in ipairs(tabGroup.tabEntries) do
		if not replacement.button.isDisabled then
			tabGroup:SelectTab(replacement.id)

			return
		end
	end

	RefreshTabButton(entry.button)
	LayoutTabGroup(tabGroup)

	if tabGroup.onTabChanged then
		tabGroup.onTabChanged(nil, nil)
	end
end

--- Sets the callback invoked when the selected tab changes.
---
--- @param tabGroup ArcaneWizardLibraryTabGroup The owning tab group.
--- @param callback fun(id: string|nil, page: ArcaneWizardLibraryTabPage|nil)|nil The callback, or nil to remove it.
local function SetOnTabChanged(tabGroup, callback)
	assert(
		callback == nil or type(callback) == "function",
		Errors:Format(tabGroup, "TabGroup:SetOnTabChanged", "The callback must be a function or nil.")
	)
	tabGroup.onTabChanged = callback
end

------------------------
--- Public Functions ---
------------------------

--- Creates a Blizzard inset with a separately configurable background.
---
--- @param config ArcaneWizardLibraryInsetConfig Inset configuration.
---
--- @return ArcaneWizardLibraryInsetFrame frame The created inset.
function ArcaneWizardLibrary.Frames:CreateInset(config)
	assert(type(config) == "table", Errors:Format(config, "CreateInset", "The 'config' value must be a table."))
	assert(config.parent ~= nil, Errors:Format(config, "CreateInset", "A parent frame is required."))
	assert(type(config.width) == "number" and config.width > 0, Errors:Format(config, "CreateInset", "The 'width' value must be positive."))
	assert(type(config.height) == "number" and config.height > 0, Errors:Format(config, "CreateInset", "The 'height' value must be positive."))
	assert(
		type(config.backgroundAlpha) == "number" and config.backgroundAlpha >= 0 and config.backgroundAlpha <= 1,
		Errors:Format(config, "CreateInset", "The 'backgroundAlpha' value must be between 0 and 1.")
	)
	local data = FrameConfig.inset
	local style = config.backgroundStyle or "tiled"

	if style == "character" then
		style = "textured"
	end

	local atlas = data.backgroundAtlases[style]
	local texture = data.backgroundTextures[style]
	assert(
		texture ~= nil or atlas ~= nil,
		Errors:Format(config, "CreateInset", "The 'backgroundStyle' value must be 'tiled', 'tiled-dark', 'textured', 'shaded', 'shaded-alt', or 'character'.")
	)

	local frame = CreateFrame("Frame", nil, config.parent, data.template)
	Errors:SetOwner(frame, config)
	frame:SetFrameLevel(config.parent:GetFrameLevel())
	frame:SetSize(config.width, config.height)
	frame.background = frame:CreateTexture(nil, "BACKGROUND")
	frame.background:SetAllPoints(frame)

	if atlas and C_Texture.GetAtlasInfo(atlas) then
		frame.background:SetAtlas(atlas)
	else
		if style == "textured" then
			texture = data.fallbackTexture
		end

		frame.background:SetTexture(texture or data.backgroundTextures.tiled, "REPEAT", "REPEAT")
		frame.background:SetHorizTile(true)
		frame.background:SetVertTile(true)
	end

	frame.background:SetAlpha(config.backgroundAlpha)

	return frame
end

--- Creates a hidden Blizzard window with a title bar and frame.content.
---
--- @param config ArcaneWizardLibraryWindowConfig Window configuration.
---
--- @return ArcaneWizardLibraryWindowFrame frame The created window.
function ArcaneWizardLibrary.Frames:CreateWindow(config)
	assert(type(config) == "table", Errors:Format(config, "CreateWindow", "The 'config' value must be a table."))
	assert(type(config.title) == "string", Errors:Format(config, "CreateWindow", "The 'title' value must be a string."))
	assert(type(config.showPortrait) == "boolean", Errors:Format(config, "CreateWindow", "The 'showPortrait' value must be a boolean."))
	ValidateConfig(config, config.showPortrait and FrameConfig.portrait or FrameConfig.window, "CreateWindow")

	local style = config.style or "standard"
	assert(
		style == "standard" or style == "flat" or style == "solid",
		Errors:Format(config, "CreateWindow", "The 'style' value must be 'standard', 'flat', or 'solid'.")
	)

	local template = style == "flat" and "DefaultPanelFlatTemplate" or "DefaultPanelTemplate"
	local frame = CreateBaseFrame(config, config.showPortrait and "PortraitFrameTemplate" or template)

	frame.titleBar = frame.TitleContainer
	frame.titleText = frame.TitleText or frame.TitleContainer.TitleText
	frame.titleText:SetText(config.title)

	frame.background = frame.Bg

	if config.showPortrait and style == "flat" then
		frame.Bg:Hide()
		frame.background = CreateFrame("Frame", nil, frame, "FlatPanelBackgroundTemplate")
		frame.background:SetFrameLevel(0)
		frame.background:SetAllPoints(frame.Bg)
	end

	frame.background:SetAlpha(config.backgroundAlpha)

	if frame.TopTileStreaks then
		frame.TopTileStreaks:SetShown(style == "standard")
		frame.TopTileStreaks:SetAlpha(config.backgroundAlpha)
	end

	if config.showPortrait then
		frame.portrait = frame.portrait or frame.PortraitContainer.portrait
		frame.portraitFrame = frame.PortraitContainer
	end

	ConfigureCloseButton(frame, config)
	CreateContentFrame(frame, FrameConfig.window.contentInsets)

	if config.movable then
		RegisterDragHandle(frame, frame.titleBar)
	end

	windowFrames[frame] = true
	frame:Hide()

	return frame
end

--- Creates a compact Blizzard backdrop with frame.content and an optional border.
---
--- @param config ArcaneWizardLibraryPopupConfig Popup configuration.
---
--- @return ArcaneWizardLibraryPopupFrame frame The created popup.
function ArcaneWizardLibrary.Frames:CreatePopup(config)
	assert(type(config) == "table", Errors:Format(config, "CreatePopup", "The 'config' value must be a table."))
	ValidateConfig(config, FrameConfig.popup, "CreatePopup")
	assert(type(config.showBorder) == "boolean", Errors:Format(config, "CreatePopup", "The 'showBorder' value must be a boolean."))

	local style = config.style or "toast"
	assert(style == "toast" or style == "tooltip", Errors:Format(config, "CreatePopup", "The 'style' value must be 'toast' or 'tooltip'."))

	local frame = CreateBaseFrame(config, style == "tooltip" and "TooltipBackdropTemplate" or "BackdropTemplate")
	popupFrames[frame] = {}

	if style == "tooltip" then
		frame.background = frame.NineSlice.Center
		popupFrames[frame].borderColor = { frame:GetBackdropBorderColor() }
	end

	frame.SetBorderShown = SetPopupBorderShown
	frame:SetBorderShown(config.showBorder)
	frame.background:SetAlpha(config.backgroundAlpha)

	CreateContentFrame(frame, FrameConfig.popup.contentInsets)
	ConfigureCloseButton(frame, config)

	if config.movable then
		RegisterDragHandle(frame, frame)
	end

	frame:Hide()

	return frame
end

--- Creates native window tabs whose pages fill window.content.
---
--- @param window ArcaneWizardLibraryWindowFrame The owning window.
---
--- @return ArcaneWizardLibraryTabGroup tabGroup The created tab group.
function ArcaneWizardLibrary.Frames:CreateTabGroup(window)
	assert(windowFrames[window], Errors:Format(window, "CreateTabGroup", "The window must have been created by the Library."))
	assert(not window.tabGroup, Errors:Format(window, "CreateTabGroup", "The window already has a tab group."))

	local tabGroup = CreateFrame("Frame", nil, window)
	Errors:SetOwner(tabGroup, window)
	tabGroup:SetPoint("TOPLEFT", window, "BOTTOMLEFT", TabConfig.x, TabConfig.y)
	tabGroup:SetSize(1, FrameConfig.tabs.height)
	tabGroup.window = window
	tabGroup.tabEntries = {}
	tabGroup.tabsById = {}
	tabGroup.tabPadding = TabConfig.padding
	tabGroup.minTabWidth = TabConfig.minimumWidth
	tabGroup.maxTabWidth = TabConfig.maximumWidth
	tabGroup.AddTab = AddTab
	tabGroup.SelectTab = SelectTab
	tabGroup.GetSelectedTab = GetSelectedTab
	tabGroup.SetTabEnabled = SetTabEnabled
	tabGroup.SetOnTabChanged = SetOnTabChanged
	window.tabGroup = tabGroup

	return tabGroup
end
