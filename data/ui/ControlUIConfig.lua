local _, LIB = ...

LIB.UIConfig.Control = {
	button = { height = 22, minimumWidth = 44 },
	infoTooltip = { width = 320, padding = 14, gap = 8 },
	selection = {
		height = 22,
		minimumWidth = 44,
		iconSize = 22,
		textOffset = 24,
		optionSpacing = 4,
		textureGetters = {
			"GetNormalTexture", "GetPushedTexture", "GetHighlightTexture",
			"GetDisabledTexture", "GetCheckedTexture", "GetDisabledCheckedTexture"
		}
	},
	input = {
		height = 22,
		minimumWidth = 80,
		textLeftInset = 8,
		textRightInset = 22,
		clearButton = {
			size = 17,
			rightInset = 3,
			iconSize = 10,
			iconInset = 3,
			iconAlpha = 0.5,
			atlas = "common-search-clearbutton"
		}
	},
	dropdown = {
		minimumWidth = 80,
		menuIconSize = 16,
		menuIconSpacing = 8,
		menuIconWidth = 56,
		menuRowHeight = 20,
		menuMaximumHeight = 300
	}
}
