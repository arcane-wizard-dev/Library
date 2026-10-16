-- Synthetic SavedVariables: account, current and offline character profiles; preserve false and zero.
-- No real player data. Version "test" is the version supplied by the test harness.
-- Library_TestOptions belongs to a synthetic API consumer, not to the Library addon.

Library_TestOptions = {
	["account"] = {
		["feature"] = {
			["enabled"] = false,
			["label"] = "",
			["limit"] = 0,
			["nested"] = {
				["added"] = 4,
				["keep"] = 9,
			},
		},
		["general"] = {
			["debug-mode"] = false,
			["minimap-button"] = {
				["hide"] = false,
				["lock"] = false,
				["minimapPos"] = 90,
				["showInCompartment"] = false,
			},
		},
	},
	["global"] = {
		["version"] = "test",
	},
	["profileKeys"] = {
		["Player-TEST-CURRENT"] = {
			["open-settings"] = false,
			["use-account"] = false,
		},
		["Player-TEST-OFFLINE"] = {
			["open-settings"] = false,
			["use-account"] = true,
		},
	},
	["profiles"] = {
		["Player-TEST-CURRENT"] = {
			["feature"] = {
				["enabled"] = false,
				["label"] = "",
				["limit"] = 0,
				["nested"] = {
					["added"] = 4,
					["keep"] = 9,
				},
			},
			["general"] = {
				["debug-mode"] = false,
				["minimap-button"] = {
					["hide"] = true,
					["lock"] = false,
					["minimapPos"] = 0,
					["showInCompartment"] = false,
				},
			},
		},
		["Player-TEST-OFFLINE"] = {
			["feature"] = {
				["enabled"] = false,
				["label"] = "",
				["limit"] = 0,
				["nested"] = {
					["added"] = 4,
					["keep"] = 9,
				},
			},
			["general"] = {
				["debug-mode"] = false,
				["minimap-button"] = {
					["hide"] = false,
					["lock"] = false,
					["minimapPos"] = 270,
					["showInCompartment"] = false,
				},
			},
		},
	},
}
