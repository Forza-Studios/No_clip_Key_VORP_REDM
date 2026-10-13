local VORP = exports.vorp_core:GetCore()
local noclip = false
local speedIndex = 3 -- start at 'Normal'
local cachedAllowed = nil

local function Notify(msg, ms)
    if not Config.Notify then return end
    TriggerEvent('vorp:TipRight', msg, ms or 3000)
end

local function EnableNoclip(entity)
    ClearPedTasks(PlayerPedId(), true, true)
    SetGameplayCamInitialHeading(0.0)
    SetPlayerLockon(PlayerId(), false)
    SetEntityCollision(entity, false, true)
    FreezeEntityPosition(entity, true)
    SetEntityInvincible(entity, true)
    SetEntityVisible(entity, false)
    SetEveryoneIgnorePlayer(PlayerId(), true)
    SetPedCanBeTargetted(entity, false)
end

local function ResetNoclip(entity)
    SetEntityCollision(entity, true, true)
    FreezeEntityPosition(entity, false)
    SetEntityInvincible(entity, false)
    SetEntityVisible(entity, true)
    SetEveryoneIgnorePlayer(PlayerId(), false)
    SetPedCanBeTargetted(entity, true)
    SetGameplayCamInitialHeading(0.0)
    SetPlayerLockon(PlayerId(), true)
    ClearPedTasks(PlayerPedId(), true, true)
end

-- credits to txAdmin for the function
local function getFallImpulse(H)
    local coefficient = 1.6428571428571428
    local intercept = 3.5714285714285836
    return coefficient * H + intercept
end

local function DisableRagdollingWhileFall()
    CreateThread(function()
        local ped = PlayerPedId()
        local pedHeight = GetEntityHeightAboveGround(ped)
        if pedHeight == nil or pedHeight < 4.0 then
            return
        end
        SetEntityInvincible(ped, true)
        SetRagdollBlockingFlags(ped, (1 << 9))
        local downForce = getFallImpulse(pedHeight)
        ApplyForceToEntity(ped, 3, 0.0, 0.0, -downForce, 0.0, 0.0, 0.0, 0, true, true, false, true, false)
        local fallAwaitLimit, fallAwaitStep, fallAwaitElapsed = 1000, 25, 0
        while not IsPedFalling(ped) do
            if fallAwaitElapsed >= fallAwaitLimit then
                SetEntityInvincible(ped, false)
                return
            end
            fallAwaitElapsed = fallAwaitElapsed + fallAwaitStep
            Wait(fallAwaitStep)
        end
        repeat Wait(50) until not IsPedFalling(ped)
        Wait(750)
        SetEntityInvincible(ped, false)
        ClearRagdollBlockingFlags(ped, (1 << 9))
    end)
end

local function GetNoclipEntity()
    local ped = PlayerPedId()
    -- if mounted / in vehicle, move that entity so horse/wagon follows
    if IsPedOnMount(ped) then
        local mount = GetMount(ped)
        if mount ~= 0 and DoesEntityExist(mount) then
            return mount, ped
        end
    end
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 and DoesEntityExist(veh) then
            return veh, ped
        end
    end
    return ped, ped
end

local function SetNoclip(state)
    local entity = GetNoclipEntity()
    if state then
        EnableNoclip(entity)
        Notify('Noclip: ON', 3000)
    else
        ResetNoclip(entity)
        DisableRagdollingWhileFall()
        SetEntityVisible(PlayerPedId(), true)
        Notify('Noclip: OFF', 3000)
    end
    noclip = state
end

-- F1 toggle thread, no UI, no prompts
CreateThread(function()
    repeat Wait(1000) until LocalPlayer.state.IsInSession
    while true do
        Wait(0)
        if IsControlJustPressed(0, Config.ToggleKey) then
            -- re-check permission every toggle so revokes apply instantly
            local allowed = VORP.Callback.TriggerAwait('coi_no_clip:canUse')
            if allowed then
                SetNoclip(not noclip)
            else
                if cachedAllowed ~= false then
                    Notify('No permission', 4000)
                end
            end
            cachedAllowed = allowed
            -- debounce
            Wait(500)
        elseif noclip and IsDisabledControlJustPressed(0, Config.Controls.cancel) then
            SetNoclip(false)
            Wait(500)
        end
    end
end)

-- movement thread (only runs when noclip active, no prompts drawn)
CreateThread(function()
    repeat Wait(1000) until LocalPlayer.state.IsInSession
    local currentSpeed = Config.Speeds[speedIndex].speed
    while true do
        local sleep = 1000
        if noclip then
            sleep = 0
            local entity, ped = GetNoclipEntity()

            DisableControlAction(0, 0xB238FE0B, true)
            DisableControlAction(0, 0x3C0A40F2, true)
            SetEntityVisible(ped, false)

            -- re-apply noclip state if entity changed (dismount/mount)
            if not IsEntityPositionFrozen(entity) then
                EnableNoclip(entity)
            end

            if IsDisabledControlJustPressed(1, Config.Controls.changeSpeed) then
                if speedIndex ~= #Config.Speeds then
                    speedIndex = speedIndex + 1
                else
                    speedIndex = 1
                end
                currentSpeed = Config.Speeds[speedIndex].speed
                Notify('Speed: ' .. Config.Speeds[speedIndex].label, 1500)
            end

            local yoff, zoff = 0.0, 0.0

            if IsDisabledControlPressed(0, Config.Controls.goForward) then
                yoff = Config.Offsets.y
                SetEntityRotation(entity, 0.0, 0.0, 0.0, 2, false)
                SetEntityHeading(entity, GetGameplayCamRelativeHeading())
            end

            if IsDisabledControlPressed(0, Config.Controls.goBackward) then
                yoff = -Config.Offsets.y
                SetEntityRotation(entity, 0.0, 0.0, 0.0, 2, false)
                SetEntityHeading(entity, GetGameplayCamRelativeHeading())
            end

            -- Z key: some maps use 0x26E9DC00, vorp uses 0x07CE1E61. Accept both.
            if IsDisabledControlPressed(0, Config.Controls.goUp)
                or IsDisabledControlPressed(0, 0x26E9DC00) then
                zoff = Config.Offsets.z
                local newPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
                SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newPos.z, true, true, true)
            end

            if IsDisabledControlPressed(0, Config.Controls.goDown) then
                zoff = -Config.Offsets.z
                local newPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
                SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newPos.z, true, true, true)
            end

            local newPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, yoff * (currentSpeed + 0.3), zoff * (currentSpeed + 0.3))
            SetEntityCoordsNoOffset(entity, newPos.x, newPos.y, newPos.z, true, true, true)
        end
        Wait(sleep)
    end
end)

-- safety: force noclip off on death / respawn
AddEventHandler('vorp:PlayerForceRespawn', function()
    if noclip then SetNoclip(false) end
end)
