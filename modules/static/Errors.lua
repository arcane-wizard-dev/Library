local _, LIB = ...

LIB.Internal = LIB.Internal or {}
LIB.Internal.Errors = {}

local Errors = LIB.Internal.Errors
local owners = setmetatable({}, { __mode = "k" })

-----------------------
--- Local Functions ---
-----------------------

local function GetAddonName(owner)
	if type(owner) == "string" then return owner ~= "" and owner or nil end
	if owners[owner] then return owners[owner] end

	local visited = {}

	while type(owner) == "table" or type(owner) == "userdata" do
		if visited[owner] then return nil end
		visited[owner] = true

		local addonName = owners[owner] or owner.addonName
		if type(addonName) == "string" and addonName ~= "" then return addonName end

		if type(owner.GetParent) == "function" then
			owner = owner:GetParent()
		else
			owner = owner.parent
		end
	end
end

--------------------------
--- Internal Functions ---
--------------------------

--- Stores the addon name for later calls on a UI element.
---
--- @param frame Frame The created UI element.
--- @param owner table|string|nil Configuration, parent frame or addon name.
function Errors:SetOwner(frame, owner)
	owners[frame] = GetAddonName(owner)
end

--- Formats an assertion message with its addon and function group.
---
--- @param owner table|string|nil Configuration, frame or addon name.
--- @param group string The function group.
--- @param message string The error description.
---
--- @return string message The formatted error message.
function Errors:Format(owner, group, message)
	local addonName = GetAddonName(owner)
	local context = addonName and addonName .. "/" .. group or group

	return LIB.CommonData.errorPrefix .. " (" .. context .. "): " .. message
end
