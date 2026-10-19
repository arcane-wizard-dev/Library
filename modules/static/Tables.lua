local _, LIB = ...

local AWL = ArcaneWizardLibrary
local Errors = LIB.Internal.Errors
local TableConfig = LIB.UIConfig.Table

---@class ArcaneWizardLibraryTableColumn
---@field text string Column heading.
---@field width? number Fixed width; omitted widths share the remaining space.
---@field align? string Row text alignment: LEFT, CENTER or RIGHT; defaults to LEFT.

---@class ArcaneWizardLibraryTableColumnLayout
---@field x number Content-relative horizontal position.
---@field width number Available text width.
---@field align string Row text alignment.

---@class ArcaneWizardLibraryTableHeader: Frame
---@field cells Button[] Column heading buttons.

---@class ArcaneWizardLibraryTableConfig
---@field addonName? string Owning addon for errors.
---@field parent Frame Parent frame.
---@field width number Framed body width.
---@field height number Framed body height, excluding the heading above it.
---@field backgroundStyle? string Inset background style.
---@field backgroundAlpha number Inset background opacity.
---@field columns ArcaneWizardLibraryTableColumn[] Column definitions.
---@field settingsMenu? fun(owner: DropdownButton, root: table) Native menu builder with addon actions.
---@field showSettingsMenu? boolean Defaults to true when a menu builder is supplied.

---@class ArcaneWizardLibraryTable: ArcaneWizardLibraryScrollFrame
---@field inset Frame Framed background.
---@field header ArcaneWizardLibraryTableHeader Fixed column headings.
---@field contentInsets {left: number, right: number, top: number, bottom: number} Shared viewport margins.
---@field columns ArcaneWizardLibraryTableColumn[] Owned column definitions.
---@field columnLayouts ArcaneWizardLibraryTableColumnLayout[] Calculated column positions.
---@field layoutWidth? number Width used by the latest layout.
---@field settingsMenu? DropdownButton Optional settings button.
---@field GetContentWidth fun(self: ArcaneWizardLibraryTable): number
---@field GetColumnLayout fun(self: ArcaneWizardLibraryTable, index: number): number, number, string
---@field SetColumnText fun(self: ArcaneWizardLibraryTable, index: number, text: string)

-----------------------
--- Local Functions ---
-----------------------

---@param frame ArcaneWizardLibraryTable
local function UpdateLayout(frame)
	local width = frame:GetWidth()
	local insets = frame.contentInsets
	local available = math.max(1, width - insets.left - insets.right)
	local padding = TableConfig.cellPadding
	local minimum = math.min(padding * 2 + 1, available / #frame.columns)
	local fixedExtra, flexible = 0, 0

	for _, column in ipairs(frame.columns) do
		if column.width then
			fixedExtra = fixedExtra + math.max(0, column.width - minimum)
		else
			flexible = flexible + 1
		end
	end

	local extra = math.max(0, available - minimum * #frame.columns)
	local scale = fixedExtra > 0 and math.min(1, extra / fixedExtra) or 1
	local remainder = math.max(0, extra - fixedExtra)
	local x = 0

	for index, column in ipairs(frame.columns) do
		local columnWidth = minimum

		if column.width then
			columnWidth = columnWidth + math.max(0, column.width - minimum) * scale
		else
			columnWidth = columnWidth + remainder / flexible
		end

		if flexible == 0 and index == #frame.columns then
			columnWidth = columnWidth + remainder
		end

		local cellPadding = math.min(padding, math.max(0, (columnWidth - 1) / 2))
		frame.columnLayouts[index] = {
			x = x + cellPadding,
			width = math.max(1, columnWidth - cellPadding * 2),
			align = column.align or "LEFT"
		}
		x = x + columnWidth
	end

	local headerConfig = TableConfig.header
	local rightEdge = width - headerConfig.edgeInset

	if frame.settingsMenu and frame.settingsMenu:IsShown() then
		rightEdge = rightEdge - TableConfig.settingsMenu.size - TableConfig.settingsMenu.gap
	end

	for index, cell in ipairs(frame.header.cells) do
		local layout = frame.columnLayouts[index]
		local nextLayout = frame.columnLayouts[index + 1]
		local left = index == 1 and headerConfig.edgeInset or insets.left + layout.x - headerConfig.padding
		local right = nextLayout and insets.left + nextLayout.x - headerConfig.padding or rightEdge
		cell:ClearAllPoints()
		cell:SetPoint("BOTTOMLEFT", frame.header, "BOTTOMLEFT", left, 0)
		cell:SetSize(math.max(1, right - left), headerConfig.height)

		local text = cell:GetFontString()
		text:ClearAllPoints()
		text:SetPoint("LEFT", cell, "LEFT", insets.left + layout.x - left, 0)
		text:SetPoint("RIGHT", cell, "RIGHT", insets.left + layout.x + layout.width - right, 0)
		text:SetJustifyH(headerConfig.align)
	end

	frame.layoutWidth = width
end

------------------------
--- Public Functions ---
------------------------

--- Creates a framed scroll area with fixed column headings and an optional settings menu.
---
--- @param config ArcaneWizardLibraryTableConfig Table configuration.
---
--- @return ArcaneWizardLibraryTable frame The table body; rows remain addon-owned.
function ArcaneWizardLibrary.Tables:CreateTable(config)
	assert(type(config) == "table", Errors:Format(config, "CreateTable", "The 'config' value must be a table."))
	assert(type(config.columns) == "table" and #config.columns > 0, Errors:Format(config, "CreateTable", "At least one column is required."))
	assert(
		config.settingsMenu == nil or type(config.settingsMenu) == "function",
		Errors:Format(config, "CreateTable", "The 'settingsMenu' value must be a function or nil.")
	)
	assert(
		config.showSettingsMenu == nil or type(config.showSettingsMenu) == "boolean",
		Errors:Format(config, "CreateTable", "The 'showSettingsMenu' value must be a boolean or nil.")
	)
	assert(
		not config.showSettingsMenu or config.settingsMenu ~= nil,
		Errors:Format(config, "CreateTable", "A menu builder is required to show the settings menu.")
	)

	for _, column in ipairs(config.columns) do
		assert(type(column) == "table" and type(column.text) == "string", Errors:Format(config, "CreateTable", "Each column requires a text label."))
		assert(
			column.width == nil or type(column.width) == "number" and column.width > TableConfig.cellPadding * 2,
			Errors:Format(config, "CreateTable", "A fixed column width must exceed the cell padding.")
		)
		assert(
			column.align == nil or column.align == "LEFT" or column.align == "CENTER" or column.align == "RIGHT",
			Errors:Format(config, "CreateTable", "Column alignment must be LEFT, CENTER or RIGHT.")
		)
	end

	local frame = AWL.ScrollFrames:CreateScrollFrame({
		addonName = config.addonName,
		parent = config.parent,
		width = config.width,
		height = config.height,
		backgroundAlpha = 0,
		showBorder = false,
		contentInsets = TableConfig.contentInsets
	})
	---@cast frame ArcaneWizardLibraryTable
	frame.contentInsets = AWL.Utils:CopyTable(TableConfig.contentInsets)
	frame.columns = AWL.Utils:CopyTable(config.columns)
	frame.columnLayouts = {}
	frame.inset = AWL.Frames:CreateInset({
		parent = frame,
		width = config.width,
		height = config.height,
		backgroundStyle = config.backgroundStyle,
		backgroundAlpha = config.backgroundAlpha
	})
	frame.inset:SetAllPoints(frame)
	local header = CreateFrame("Frame", nil, frame)
	frame.header = header
	frame.header:SetPoint("BOTTOMLEFT", frame, "TOPLEFT")
	frame.header:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT")
	frame.header:SetHeight(TableConfig.header.height)
	frame.header.cells = {}

	for index, column in ipairs(frame.columns) do
		local cell = CreateFrame("Button", nil, frame.header, TableConfig.header.template)
		cell:EnableMouse(false)
		cell:SetText(column.text)
		frame.header.cells[index] = cell
	end

	if config.settingsMenu then
		local menuConfig = TableConfig.settingsMenu
		local button = CreateFrame("DropdownButton", nil, frame.header, menuConfig.template)
		button:SetSize(menuConfig.size, menuConfig.size)
		button:SetPoint("RIGHT", frame.header, "RIGHT", -TableConfig.header.edgeInset, 0)

		for _, region in ipairs({button:GetRegions()}) do
			if region:IsObjectType("Texture") then
				---@cast region Texture
				region:SetTexture(menuConfig.texture)
				region:SetTexCoord(0, 1, 0, 1)
				region:SetSize(menuConfig.size, menuConfig.size)
			end
		end

		button:SetupMenu(config.settingsMenu)
		button:SetShown(config.showSettingsMenu ~= false)
		frame.settingsMenu = button
		button:HookScript("OnHide", function(menuButton)
			menuButton:CloseMenu()
			UpdateLayout(frame)
		end)
		button:HookScript("OnShow", function()
			UpdateLayout(frame)
		end)
	end

	--- Returns the usable row width, including when the table is hidden.
	---
	--- @return number width
	function frame:GetContentWidth()
		return math.max(1, self:GetWidth() - self.contentInsets.left - self.contentInsets.right)
	end

	--- Returns a cell's content-relative position, text width and alignment.
	---
	--- @param index number Column index.
	---
	--- @return number x
	--- @return number width
	--- @return string align
	function frame:GetColumnLayout(index)
		assert(self.columns[index] ~= nil, Errors:Format(self, "Table:GetColumnLayout", "The column index is invalid."))

		if self.layoutWidth ~= self:GetWidth() then
			UpdateLayout(self)
		end

		local layout = self.columnLayouts[index]
		return layout.x, layout.width, layout.align
	end

	--- Updates a column heading without rebuilding the table.
	---
	--- @param index number Column index.
	--- @param text string Column heading.
	function frame:SetColumnText(index, text)
		assert(self.columns[index] ~= nil, Errors:Format(self, "Table:SetColumnText", "The column index is invalid."))
		assert(type(text) == "string", Errors:Format(self, "Table:SetColumnText", "The column text must be a string."))
		self.columns[index].text = text
		self.header.cells[index]:SetText(text)
	end

	frame:HookScript("OnSizeChanged", UpdateLayout)
	frame:HookScript("OnShow", UpdateLayout)
	UpdateLayout(frame)

	return frame
end
