-- Synthetic SavedVariables: previous addon version with the current database schema; fill defaults and remove obsolete options.
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
			["obsolete-option"] = 1,
		},
		["general"] = {
			["debug-mode"] = "obsolete-type",
			["minimap-button"] = {
				["hide"] = false,
				["minimapPos"] = 90,
				["obsolete"] = true,
			},
		},
		["obsolete-section"] = {
			["enabled"] = true,
		},
	},
	["global"] = {
		["obsolete"] = true,
		["version"] = "fixture-previous",
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
				["obsolete-option"] = 1,
			},
			["general"] = {
				["debug-mode"] = "obsolete-type",
				["minimap-button"] = {
					["hide"] = true,
					["minimapPos"] = 0,
					["obsolete"] = true,
				},
			},
			["obsolete-section"] = {
				["enabled"] = true,
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
				["obsolete-option"] = 1,
			},
			["general"] = {
				["debug-mode"] = "obsolete-type",
				["minimap-button"] = {
					["hide"] = false,
					["minimapPos"] = 270,
					["obsolete"] = true,
				},
			},
			["obsolete-section"] = {
				["enabled"] = true,
			},
		},
	},
}
