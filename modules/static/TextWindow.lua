local _, LIB = ...

-- Library
local AWL = ArcaneWizardLibrary

-- Localization
local L = LIB.Localization

-- Module imports
local TextWindowConfig = LIB.UIConfig.TextWindow

local function PositionScrollBar(area)
	local pixel = PixelUtil.GetPixelToUIUnitFactor() / area:GetEffectiveScale()
	local barInsets = LIB.UIConfig.ScrollFrame.barInsets
	local barRight = barInsets.right + TextWindowConfig.scrollBarShiftLeft * pixel
	local bar = area.scrollBar
	bar:SetPoint("TOPRIGHT", -barRight, -barInsets.top)
	bar:SetPoint("BOTTOMRIGHT", -barRight, barInsets.bottom)

	local insets = TextWindowConfig.scrollFrame.contentInsets
	local arrowWidth = math.max(area.scrollUpButton:GetWidth(), area.scrollDownButton:GetWidth())
	local arrowLeftInset = barRight + (bar:GetWidth() + arrowWidth) / 2
	area.scrollFrame:SetPoint("BOTTOMRIGHT", -arrowLeftInset - insets.left, insets.bottom)
end

--- Creates the shared help and changelog frame with its scrollable reading area.
function LIB.Internal.CreateTextWindow(addonName, title, closeLabel)
	local frame = AWL.Frames:CreateWindow({
		addonName = addonName,
		title = title,
		style = "flat",
		width = TextWindowConfig.width,
		height = TextWindowConfig.height,
		backgroundAlpha = 1,
		showPortrait = false,
		showCloseButton = true,
		movable = true,
		closeOnEscape = true
	})
	frame:SetFrameStrata("DIALOG")
	local insets = TextWindowConfig.insets
	local buttonInset = TextWindowConfig.buttonInset
	frame.content:ClearAllPoints()
	frame.content:SetPoint("TOPLEFT", frame, "TOPLEFT", insets.left, -insets.top)
	frame.content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -insets.right, insets.bottom)

	local closeButton = AWL.Controls:CreateButton({
		parent = frame,
		width = TextWindowConfig.closeButtonWidth,
		label = closeLabel or L["window.close"],
		onClick = function()
			frame:Hide()
		end
	})

	closeButton:SetPoint("TOPRIGHT", frame.content, "BOTTOMRIGHT", -buttonInset, -buttonInset)

	local scrollConfig = TextWindowConfig.scrollFrame
	local contentWidth = math.max(frame:GetWidth() - insets.left - insets.right, scrollConfig.minimumWidth)
	local contentHeight = math.max(frame:GetHeight() - insets.top - insets.bottom, scrollConfig.minimumHeight)

	local scrollArea = AWL.ScrollFrames:CreateScrollFrame({
		parent = frame.content,
		width = contentWidth,
		height = contentHeight,
		backgroundAlpha = scrollConfig.backgroundAlpha,
		showBorder = scrollConfig.showBorder,
		contentInsets = scrollConfig.contentInsets
	})

	scrollArea:SetPoint("TOPLEFT", frame.content, "TOPLEFT", buttonInset, 0)
	scrollArea:SetPoint("BOTTOMRIGHT", frame.content, "BOTTOMRIGHT", -buttonInset, 0)
	local inset = AWL.Frames:CreateInset({
		parent = scrollArea,
		width = contentWidth,
		height = contentHeight,
		borderStyle = "outline",
		backgroundStyle = "plain",
		backgroundAlpha = TextWindowConfig.listOpacity
	})
	inset:SetAllPoints(scrollArea)

	PositionScrollBar(scrollArea)
	scrollArea:RegisterEvent("UI_SCALE_CHANGED")
	scrollArea:RegisterEvent("DISPLAY_SIZE_CHANGED")
	scrollArea:SetScript("OnEvent", PositionScrollBar)

	return frame, scrollArea
end
