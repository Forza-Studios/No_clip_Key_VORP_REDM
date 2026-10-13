local Core = exports.vorp_core:GetCore()

local function HasAdminPower(source)
    local user = Core.getUser(source)
    if not user then return false end

    local group = Config.UseCharacterGroup
        and user.getUsedCharacter.group
        or user.getGroup

    if group and Config.AllowedGroups[group] then
        return true
    end

    return false
end

Core.Callback.Register('coi_no_clip:canUse', function(source, cb)
    cb(HasAdminPower(source))
end)
