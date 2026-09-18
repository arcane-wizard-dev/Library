local _, LIB = ...

------------------------
--- Public Functions ---
------------------------

--- Creates a deep copy of a table.
---
--- Copies nested table values recursively.
--- Intended for plain, acyclic SavedVariables-style tables.
--- Metatables are not preserved and cyclic references are not supported.
---
--- @param source table The table to copy.
---
--- @return table copy The copied table.
function ArcaneWizardLibrary.Utils:CopyTable(source)
	local target = {}

	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = self:CopyTable(value)
		else
			target[key] = value
		end
	end

	return target
end

--- Returns the character and realm name of the current player as separate values.
---
--- @return string characterName The character name.
--- @return string realmName The realm name.
function ArcaneWizardLibrary.Utils:GetCharacterAndRealm()
	local characterName = UnitName("player")
	local realmName = GetRealmName()

	return characterName, realmName
end

--- Returns the name-based character-realm key used by existing addon versions.
---
--- This API keeps its name-based format even when a GUID is available.
--- GUID-based addons use GetCharacterGUID and may use this key to find legacy data.
--- @return string? characterRealmKey "CharacterName#RealmName", or nil before names are available.
function ArcaneWizardLibrary.Utils:GetCharacterRealmKey()
	local characterName, realmName = self:GetCharacterAndRealm()
	if not characterName or characterName == "" or not realmName or realmName == "" then
		return nil
	end

	return characterName .. "#" .. realmName
end

--- Returns the current player's complete GUID. Check for nil before using it as a key.
--- This is a separate identity API; it does not change existing name-based keys or SavedVariables.
--- @return string? characterGUID The character identity, or nil if unavailable.
function ArcaneWizardLibrary.Utils:GetCharacterGUID()
	local guid = UnitGUID("player")
	if not guid or guid == "" then
		return nil
	end

	return guid
end

--- Merges missing values from plain SavedVariables tables without replacing existing values.
--- Migration is opt-in: the calling addon selects the tables and handles its own SavedVariables.
--- @param target table The destination table; false and zero are preserved.
--- @param source table The legacy table.
function ArcaneWizardLibrary.Utils:MergeMissingTableEntries(target, source)
	for key, value in pairs(source) do
		if target[key] == nil then
			target[key] = type(value) == "table" and self:CopyTable(value) or value
		elseif type(target[key]) == "table" and type(value) == "table" then
			self:MergeMissingTableEntries(target[key], value)
		end
	end
end
