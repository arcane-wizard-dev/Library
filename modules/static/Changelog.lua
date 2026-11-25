local _, LIB = ...

local Errors = LIB.Internal.Errors

local ChangelogConfig = LIB.UIConfig.Changelog
local ContentPadding = LIB.UIConfig.TextWindow.contentPadding

local changelogWindows = {}

-----------------------
--- Local Functions ---
-----------------------

local function CreateChangelogRow(state)
	local row = CreateFrame("Frame", nil, state.scrollArea.content)

	local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetSpacing(ChangelogConfig.lineSpacing)
	text:SetWordWrap(true)

	local bullet = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	bullet:SetPoint("TOPLEFT")
	bullet:SetWidth(ChangelogConfig.bulletWidth)
	bullet:SetJustifyH("CENTER")
	bullet:SetJustifyV("TOP")
	bullet:SetText("•")
	bullet:Hide()

	local noticeIcon = row:CreateTexture(nil, "OVERLAY")
	noticeIcon:SetPoint("TOPLEFT", ChangelogConfig.noticeIcon.offsetX, ChangelogConfig.noticeIcon.offsetY)
	noticeIcon:SetSize(ChangelogConfig.noticeIcon.size, ChangelogConfig.noticeIcon.size)
	noticeIcon:SetTexture(ChangelogConfig.noticeIcon.texture)
	noticeIcon:Hide()

	row.text = text
	row.bullet = bullet
	row.noticeIcon = noticeIcon

	return row
end

local function AddChangelogRow(layout, text, marker)
	local state = layout.state
	local padding = ContentPadding.x
	local spacing = ChangelogConfig.lineSpacing
	local isNotice = marker == "!" or marker == ""
	local textInset = marker ~= nil and ChangelogConfig.bulletWidth + ChangelogConfig.bulletSpacing or 0

	layout.rowCount = layout.rowCount + 1

	local row = state.rows[layout.rowCount]

	if not row then
		row = CreateChangelogRow(state)
		state.rows[layout.rowCount] = row
	end

	row:ClearAllPoints()
	row:SetPoint("TOPLEFT", state.scrollArea.content, "TOPLEFT", padding, -layout.offset)
	row:SetWidth(layout.width)
	row.bullet:SetText(marker or "")
	row.bullet:SetShown(marker ~= nil and not isNotice)
	row.noticeIcon:SetShown(marker == "!")

	row.text:ClearAllPoints()
	row.text:SetPoint("TOPLEFT", textInset, 0)
	row.text:SetWidth(math.max(1, layout.width - textInset))
	row.text:SetText(text == "" and " " or text)

	local _, fontHeight = row.text:GetFont()
	local textHeight = row.text:GetStringHeight() or 0
	local iconHeight = marker == "!" and ChangelogConfig.noticeIcon.size or 0
	local rowHeight = math.ceil(math.max(textHeight, fontHeight or 1, iconHeight))

	row:SetHeight(rowHeight)
	row:Show()
	layout.offset = layout.offset + rowHeight + spacing
end

local function RenderChangelog(state, versions)
	local padding = ContentPadding
	local layout = {
		state = state,
		width = math.max(1, state.scrollArea.scrollFrame:GetWidth() - padding.x * 2),
		offset = padding.y,
		rowCount = 0
	}

	local notices = versions.notices or {}

	if #notices > 0 then
		AddChangelogRow(layout, "|cffffd200" .. ChangelogConfig.noticeTitle .. "|r", "!")

		for _, notice in ipairs(notices) do
			AddChangelogRow(layout, notice, "")
			AddChangelogRow(layout, "")
		end
	end

	for versionIndex, versionData in ipairs(versions) do
		local heading = "|cffffd200" .. versionData.version

		if versionData.date then
			heading = heading .. " (" .. versionData.date .. ")"
		end

		heading = heading .. "|r"
		AddChangelogRow(layout, heading)
		AddChangelogRow(layout, "")

		for _, entry in ipairs(versionData.entries) do
			AddChangelogRow(layout, entry, "•")
		end

		if versionIndex < #versions then
			AddChangelogRow(layout, "")
		end
	end

	for index = layout.rowCount + 1, #state.rows do
		state.rows[index]:Hide()
	end

	state.scrollArea:SetContentHeight(math.ceil(layout.offset - ChangelogConfig.lineSpacing + padding.y))
end

local function FinishChangelogLayout(frame)
	frame:SetScript("OnUpdate", nil)
	local state = frame.changelogState

	if frame:IsShown() then
		RenderChangelog(state, state.versions)
	end
end

local function ValidateChangelog(versions, addonName)
	assert(
		type(versions) == "table" and #versions > 0,
		Errors:Format(addonName, "OpenChangelog", "The version list must be a non-empty table.")
	)
	assert(
		versions.notices == nil or type(versions.notices) == "table",
		Errors:Format(addonName, "OpenChangelog", "The 'notices' value must be a table or nil.")
	)

	for noticeIndex, notice in ipairs(versions.notices or {}) do
		assert(
			type(notice) == "string" and notice ~= "",
			Errors:Format(addonName, "OpenChangelog", "Notice " .. noticeIndex .. " must be a non-empty string.")
		)
	end

	for versionIndex, versionData in ipairs(versions) do
		local versionLabel = "Version " .. versionIndex

		assert(
			type(versionData) == "table",
			Errors:Format(addonName, "OpenChangelog", versionLabel .. " must be a table.")
		)
		assert(
			type(versionData.version) == "string" and versionData.version ~= "",
			Errors:Format(addonName, "OpenChangelog", versionLabel .. " must define a non-empty version string.")
		)
		assert(
			versionData.date == nil or type(versionData.date) == "string" and versionData.date ~= "",
			Errors:Format(addonName, "OpenChangelog", "The 'date' value of " .. versionLabel .. " must be a non-empty string or nil.")
		)
		assert(
			type(versionData.entries) == "table" and #versionData.entries > 0,
			Errors:Format(addonName, "OpenChangelog", "The 'entries' value of " .. versionLabel .. " must be a non-empty table.")
		)

		for entryIndex, entry in ipairs(versionData.entries) do
			assert(
				type(entry) == "string" and entry ~= "",
				Errors:Format(
					addonName,
					"OpenChangelog",
					"Entry " .. entryIndex .. " of " .. versionLabel .. " must be a non-empty string."
				)
			)
		end
	end
end

local function CreateChangelogWindow(addonName)
	local strings = LIB.SlashHelpLocalization and LIB.SlashHelpLocalization[addonName] or LIB.Localization
	local title = strings["changelog.window.title"]:format(addonName)
	---@class (partial) ArcaneWizardLibraryChangelogFrame
	local frame, scrollArea = LIB.Internal.CreateTextWindow(addonName, title, strings["window.close"])

	local state = {
		frame = frame,
		scrollArea = scrollArea,
		rows = {}
	}
	frame.changelogState = state
	changelogWindows[addonName] = state
	scrollArea.scrollFrame:HookScript("OnSizeChanged", function()
		if state.versions and frame:IsShown() then
			RenderChangelog(state, state.versions)
		end
	end)

	return state
end

------------------------
--- Public Functions ---
------------------------

--- Opens the addon's changelog window, creating it on first use.
---
--- @param addonName string The addon name.
--- @param versions ArcaneWizardLibraryChangelog Changelog versions and optional notices.
---
--- @return ArcaneWizardLibraryWindowFrame frame The changelog window.
function ArcaneWizardLibrary.Frames:OpenChangelog(addonName, versions)
	assert(
		type(addonName) == "string" and addonName ~= "",
		Errors:Format(addonName, "OpenChangelog", "The 'addonName' value must be a non-empty string.")
	)
	ValidateChangelog(versions, addonName)

	local state = changelogWindows[addonName] or CreateChangelogWindow(addonName)
	local frame = state.frame
	state.versions = versions
	frame:Show()
	RenderChangelog(state, versions)
	state.scrollArea:ScrollToTop()

	frame:SetScript("OnUpdate", FinishChangelogLayout)

	return frame
end
