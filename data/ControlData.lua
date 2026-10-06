local _, LIB = ...

LIB.ControlData = {
	button = { height = 22, minimumWidth = 44 },
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
	input = { height = 22, minimumWidth = 80, textLeftInset = 8, textRightInset = 22 },
	dropdown = {
		minimumWidth = 80,
		menuIconSize = 16,
		menuIconSpacing = 8,
		menuIconWidth = 56,
		menuRowHeight = 20,
		menuMaximumHeight = 300
	}
}
