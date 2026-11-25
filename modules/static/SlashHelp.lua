local _, LIB = ...

-- Module imports
local HelpConfig = LIB.UIConfig.TextWindow
local ContentPadding = HelpConfig.contentPadding

local HelpFrames = {}

local function AddSection(area, title)
	local header = CreateFrame("Frame", nil, area.content, "ArcaneWizardLibrary_SettingsExpandTemplate")
	header.Button:ClearAllPoints()
	header.Button:SetAllPoints(header)
	header.Button.Text:SetText(title)

	local body = CreateFrame("Frame", nil, area.content)
	body:SetPoint("TOPLEFT", header, "BOTTOMLEFT", HelpConfig.indent, -HelpConfig.groupSpacing)
	body:Hide()

	return {header = header, body = body, lines = {}}
end

local function AddLine(section, value, style, gap)
	local text = section.body:CreateFontString(nil, "OVERLAY", style == "text" and "GameFontHighlight" or "GameFontNormal")
	text:SetJustifyH("LEFT")
	text:SetJustifyV("TOP")
	text:SetWordWrap(true)
	text:SetSpacing(HelpConfig.lineSpacing)

	if style == "command" then
		local _, size = text:GetFont()
		text:SetFont(HelpConfig.commandFont, size)
	end

	text:SetText(value)
	section.lines[#section.lines + 1] = {text = text, gap = gap}
end

local function CreateHelpWindow(addonName, aliases, extraCommands, questions)
	local strings = LIB.SlashHelpLocalization and LIB.SlashHelpLocalization[addonName] or LIB.Localization
	local title = strings["help.title"]:format(addonName)
	local frame, area = LIB.Internal.CreateTextWindow(addonName, title, strings["window.close"])

	local intro = area.content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	intro:SetPoint("TOPLEFT", ContentPadding.x, -ContentPadding.y)
	intro:SetJustifyH("LEFT")
	intro:SetWordWrap(true)
	intro:SetText(strings["help.intro"]:format(addonName))

	local sections = {}
	local faq

	for _, entry in ipairs(questions or {}) do
		if entry.available ~= false then
			if not faq then
				faq = AddSection(area, strings["help.faq"])
				sections[1] = faq
			end

			AddLine(faq, entry.question, "question", #faq.lines == 0 and 0 or HelpConfig.groupSpacing)
			AddLine(faq, entry.answer, "text", HelpConfig.lineSpacing)
		end
	end

	local commands = AddSection(area, strings["help.commands"])
	sections[#sections + 1] = commands

	local function AddCommand(usage, description)
		AddLine(commands, usage, "command", #commands.lines == 0 and 0 or HelpConfig.groupSpacing)
		AddLine(commands, description, "text", HelpConfig.lineSpacing)
	end

	AddCommand(aliases[1], strings["help.settings"])

	for _, command in ipairs(extraCommands or {}) do
		AddCommand(aliases[1] .. " " .. command.name, command.description)
	end

	AddCommand(aliases[1] .. " changelog", strings["help.changelog"])
	AddCommand(aliases[1] .. " help", strings["help.open"])

	local function UpdateLayout()
		local width = math.max(1, area.scrollFrame:GetWidth() - 2 * ContentPadding.x)
		intro:SetWidth(width)
		local textWidth = math.max(1, width - HelpConfig.indent)
		local height = ContentPadding.y + math.ceil(intro:GetStringHeight()) + HelpConfig.introSpacing

		for index, section in ipairs(sections) do
			local header, body = section.header, section.body
			local expanded = body:IsShown()
			header:SetPoint("TOPLEFT", ContentPadding.x, -height)
			header:SetWidth(width)
			header:EvaluateVisibility(expanded)
			height = height + header:GetHeight()

			if expanded then
				local offset = 0
				body:SetWidth(textWidth)

				for _, line in ipairs(section.lines) do
					offset = offset + line.gap
					line.text:SetWidth(textWidth)
					line.text:SetPoint("TOPLEFT", body, "TOPLEFT", 0, -offset)
					offset = offset + math.ceil(line.text:GetStringHeight())
				end

				body:SetHeight(offset)
				height = height + HelpConfig.groupSpacing + offset
			end

			local gapBelow = expanded and index < #sections and HelpConfig.groupSpacing or HelpConfig.bottomPadding
			height = height + gapBelow
		end

		area:SetContentHeight(height)
	end

	local function FinishLayout()
		frame:SetScript("OnUpdate", nil)
		UpdateLayout()
	end

	area.scrollFrame:HookScript("OnSizeChanged", UpdateLayout)

	for _, section in ipairs(sections) do
		local body = section.body
		section.header.Button:SetScript("OnClick", function()
			body:SetShown(not body:IsShown())
			UpdateLayout()
		end)
	end

	frame:SetScript("OnShow", function()
		UpdateLayout()
		area:ScrollToTop()
		frame:SetScript("OnUpdate", FinishLayout)
	end)

	return frame
end

--- Shows slash commands and any questions available on the current game client.
--- @param addonName string The addon whose help window to open.
--- @param aliases string[] Registered slash aliases, with the primary alias first.
--- @param extraCommands? ArcaneWizardLibrarySlashCommand[] Additional rows in display order.
--- @param questions? ArcaneWizardLibraryHelpQuestion[] Optional questions in display order.
--- @return ArcaneWizardLibraryWindowFrame frame The addon's help window.
function ArcaneWizardLibrary.Frames:OpenSlashHelp(addonName, aliases, extraCommands, questions)
	local frame = HelpFrames[addonName]

	if not frame then
		frame = CreateHelpWindow(addonName, aliases, extraCommands, questions)
		HelpFrames[addonName] = frame
	end

	frame:Show()

	return frame
end
