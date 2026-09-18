local _, LIB = ...

---@class ArcaneWizardLibraryAddon
---@field name string
---@field version string|nil
---@field buildDate string|nil
---@field mediaPath string
---@field mainCategoryId number|nil
---@field initializationAborted boolean|nil
---@field GetMediaPath fun(self: ArcaneWizardLibraryAddon, fileName: string|nil): string Returns the addon media path or a media file path below it.
---@field SetMainCategoryId fun(self: ArcaneWizardLibraryAddon, categoryId: number) Stores the Blizzard settings category ID for this addon.
---@field OpenCategory fun(self: ArcaneWizardLibraryAddon): boolean Opens the stored Blizzard settings category when not blocked by combat lockdown.
---@field AbortInitialization fun(self: ArcaneWizardLibraryAddon, frame: Frame) Stops startup when the player identity is unavailable.
---@field RegisterMinimapButton fun(self: ArcaneWizardLibraryAddon, config: table): table Registers a LibDataBroker minimap button for this addon.
---@field CreateCompartmentHandlers fun(self: ArcaneWizardLibraryAddon, config: table): table Creates AddonCompartment handler functions for this addon.

local AddonContextMixin = {}

local AddonLauncher = LIB.Internal.AddonLauncher

local addonContexts = {}

---@param addonName string
---@return ArcaneWizardLibraryAddon context
local function CreateAddonContext(addonName)
	if addonContexts[addonName] then
		return addonContexts[addonName]
	end

	local context = {
		name = addonName,
		version = C_AddOns.GetAddOnMetadata(addonName, "Version"),
		buildDate = C_AddOns.GetAddOnMetadata(addonName, "X-BuildDate"),
		mediaPath = "Interface\\AddOns\\" .. addonName .. "\\assets\\"
	}

	setmetatable(context, { __index = AddonContextMixin })
	addonContexts[addonName] = context

	return context
end

--------------------------
--- Addon Context API ---
--------------------------

function AddonContextMixin:GetMediaPath(fileName)
	if fileName and fileName ~= "" then
		return self.mediaPath .. fileName
	end

	return self.mediaPath
end

function AddonContextMixin:SetMainCategoryId(categoryId)
	self.mainCategoryId = categoryId
end

function AddonContextMixin:OpenCategory()
	if self.initializationAborted then return false end

	local categoryId = self.mainCategoryId

	assert(categoryId, LIB.CommonData.debugPrefix .. "No Options Category ID defined for " .. tostring(self.name) .. ". The options menu cannot be opened.")

	if not InCombatLockdown() then
		Settings.OpenToCategory(categoryId)
		return true
	end

	return false
end

--- Call before initializing settings, feature hooks, or timers if the player identity is unavailable.
--- Stops the supplied event frame and blocks launcher actions for this session.
--- Does not unload Lua files or change the addon's enabled state; /reload allows another attempt.
---@param frame Frame The addon's startup event frame.
function AddonContextMixin:AbortInitialization(frame)
	self.initializationAborted = true
	frame:UnregisterAllEvents()
	frame:SetScript("OnEvent", nil)
	print(self.name .. ": " .. LIB.Localization["error.character-identity-unavailable"])
end

function AddonContextMixin:RegisterMinimapButton(config)
	return AddonLauncher:RegisterMinimapButton(self, config)
end

function AddonContextMixin:CreateCompartmentHandlers(config)
	return AddonLauncher:CreateCompartmentHandlers(self, config)
end

------------------------
--- Public Functions ---
------------------------

--- Creates an addon context.
---
--- @param addonName string The addon name.
---
--- @return ArcaneWizardLibraryAddon context The addon context.
function ArcaneWizardLibrary:NewAddon(addonName)
	assert(type(addonName) == "string" and addonName ~= "", LIB.CommonData.debugPrefix .. "No addon name defined.")

	return CreateAddonContext(addonName)
end

--- Returns a registered addon context.
---
--- @param addonName string The addon name.
---
--- @return ArcaneWizardLibraryAddon context The registered addon context.
function ArcaneWizardLibrary:GetAddon(addonName)
	local context = addonContexts[addonName]

	assert(context, LIB.CommonData.debugPrefix .. "addon context is not initialized for " .. tostring(addonName))

	return context
end
