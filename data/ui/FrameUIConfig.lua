local _, LIB = ...

LIB.UIConfig.Frame = {
	anchorPoints = {
		TOPLEFT = true,
		TOP = true,
		TOPRIGHT = true,
		LEFT = true,
		CENTER = true,
		RIGHT = true,
		BOTTOMLEFT = true,
		BOTTOM = true,
		BOTTOMRIGHT = true
	},
	window = {
		minimumWidth = 128,
		minimumHeight = 96,
		contentInsets = { left = 8, right = 8, top = 35, bottom = 8 }
	},
	portrait = { minimumWidth = 192, minimumHeight = 128 },
	inset = {
		template = "InsetFrameTemplate4",
		backgroundAtlases = {
			textured = "character-panel-background",
			shaded = "auctionhouse-background-index",
			["shaded-alt"] = "auctionhouse-background-auctions"
		},
		backgroundTextures = {
			tiled = "Interface\\DialogFrame\\UI-DialogBox-Background",
			["tiled-dark"] = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark"
		},
		fallbackTexture = "Interface\\FrameGeneral\\UI-Background-Marble"
	},
	popup = {
		minimumWidth = 64,
		minimumHeight = 48,
		contentInsets = { left = 10, right = 10, top = 10, bottom = 10 }
	},
	tabs = {
		height = 32,
		standard = {
			template = "PanelTabButtonTemplate",
			minimumWidth = 36,
			padding = 24,
			spacing = 3,
			x = 12,
			y = 2
		},
		classic = {
			template = "CharacterFrameTabButtonTemplate",
			minimumWidth = 36,
			padding = 6,
			maximumWidth = 88,
			spacing = -15,
			eraSpacing = -16,
			x = 11,
			y = 2
		}
	}
}
