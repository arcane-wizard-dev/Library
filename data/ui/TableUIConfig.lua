local _, LIB = ...

LIB.UIConfig.Table = {
	contentInsets = {left = 10, right = 25, top = 15, bottom = 15},
	cellPadding = 5,
	header = {
		template = "ColumnDisplayButtonShortTemplate",
		align = "LEFT",
		height = 19,
		padding = 8,
		edgeInset = 6
	},
	tableMenu = {
		template = "UIPanelIconDropdownButtonTemplate",
		size = 16,
		gap = 4,
		texture = "Interface\\AddOns\\ArcaneWizardLibrary\\assets\\tables\\settings-gear.tga"
	}
}
