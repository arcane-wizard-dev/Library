local _, LIB = ...

LIB.FrameData = {
	anchorPoints = {
		TOPLEFT = true, TOP = true, TOPRIGHT = true,
		LEFT = true, CENTER = true, RIGHT = true,
		BOTTOMLEFT = true, BOTTOM = true, BOTTOMRIGHT = true
	},
	window = {
		minimumWidth = 128,
		minimumHeight = 96,
		contentInsets = { left = 8, right = 8, top = 35, bottom = 8 }
	},
	portrait = { minimumWidth = 192, minimumHeight = 128 },
	inset = {
		template = "InsetFrameTemplate4",
		backgroundColor = {0, 0, 0, 1},
		backgroundAtlas = "character-panel-background",
		fallbackTexture = "Interface\\FrameGeneral\\UI-Background-Marble"
	},
	popup = {
		minimumWidth = 64,
		minimumHeight = 48,
		contentInsets = { left = 10, right = 10, top = 10, bottom = 10 }
	},
	tabs = {
		height = 32,
		standard = { template = "PanelTabButtonTemplate", minimumWidth = 72, padding = 44, spacing = 3, x = 12, y = 2 },
		-- Classic's width limits apply to the middle texture.
		classic = { template = "CharacterFrameTabButtonTemplate", minimumWidth = 36, maximumWidth = 88, spacing = -15, eraSpacing = -16, x = 11, y = 2 }
	}
}
