-- A Cappy event is a "sync things now" event triggered by Mario or Cappy actions.
-- When received, the local game checks the whole value of the last event and compares it
-- with the received one. If they don't match, that means the received one is a new event.
--
-- An event fills specific Mario's object fields:
-- oUnk94 -> Event type
-- oUnkBC -> Target Id
-- oUnkC0 -> Timestamp
-- oUnk1A8 -> Behavior
-- oMoveFlags
-- oHomeX -> Pos X
-- oHomeY -> Pos Y
-- oHomeZ -> Pos Z
-- oParentRelativePosX -> Vel X
-- oParentRelativePosY -> Vel Y
-- oParentRelativePosZ -> Vel Z

gOmmCappyEvents = {}
for i = 0, (MAX_PLAYERS - 1) do
    local marioObj = gMarioStates[i].marioObj
    if marioObj ~= nil then marioObj.oUnk94 = 0 end
    gOmmCappyEvents[i] = {
        [OMM_CAPPY_EVENT_SPAWN]  = 0,
        [OMM_CAPPY_EVENT_HOMING] = 0,
        [OMM_CAPPY_EVENT_RETURN] = 0,
        [OMM_CAPPY_EVENT_UNLOAD] = 0,
        [OMM_CAPPY_EVENT_BOUNCE] = 0,
    }
end

function omm_cappy_send_event(m, cappy, e, values)
    m.marioObj.oUnk94 = e
    m.marioObj.oUnkBC = cappy.oAction
    m.marioObj.oUnkC0 = m.marioObj.oTimer
    if values["behavior"] ~= nil then m.marioObj.oUnk1A8 = cappy.oBehParams2ndByte end
    if values["posX"] ~= nil then m.marioObj.oHomeX = cappy.oPosX end
    if values["posY"] ~= nil then m.marioObj.oHomeY = cappy.oPosY end
    if values["posZ"] ~= nil then m.marioObj.oHomeZ = cappy.oPosZ end
    if values["velX"] ~= nil then m.marioObj.oParentRelativePosX = cappy.oVelX end
    if values["velY"] ~= nil then m.marioObj.oParentRelativePosY = cappy.oVelY end
    if values["velZ"] ~= nil then m.marioObj.oParentRelativePosZ = cappy.oVelZ end
    gOmmCappyEvents[m.playerIndex][e] = m.marioObj.oTimer
    if is_debug() then
        local cappyEvents = {
            [OMM_CAPPY_EVENT_SPAWN]  = "SPAWN",
            [OMM_CAPPY_EVENT_HOMING] = "HOMING",
            [OMM_CAPPY_EVENT_RETURN] = "RETURN",
            [OMM_CAPPY_EVENT_UNLOAD] = "UNLOAD",
            [OMM_CAPPY_EVENT_BOUNCE] = "BOUNCE",
        }
        local log = "Player " .. get_global_index(m) .. " sent [" .. cappyEvents[e] .. "] event with params: ("
        if values["behavior"] ~= nil then log = log .. "behavior: " .. cappy.oBehParams2ndByte .. ", " end
        if values["posX"] ~= nil then log = log .. "posX: " .. cappy.oPosX .. ", " end
        if values["posY"] ~= nil then log = log .. "posY: " .. cappy.oPosY .. ", " end
        if values["posZ"] ~= nil then log = log .. "posZ: " .. cappy.oPosZ .. ", " end
        if values["velX"] ~= nil then log = log .. "velX: " .. cappy.oVelX .. ", " end
        if values["velY"] ~= nil then log = log .. "velY: " .. cappy.oVelY .. ", " end
        if values["velZ"] ~= nil then log = log .. "velZ: " .. cappy.oVelZ .. ", " end
        log = log .. "target: " .. cappy.oAction .. ", timestamp: " .. m.marioObj.oTimer .. ")"
        print(log)
    end
end

function omm_cappy_process_event(m, cappy, e, values)
    if m.marioObj == nil then return false end
    if m.marioObj.oUnk94 ~= e then return false end
    if m.marioObj.oUnkBC ~= cappy.oAction then return false end
    if m.marioObj.oUnkC0 == 0 then return false end
    if m.marioObj.oUnkC0 == gOmmCappyEvents[m.playerIndex][e] then return false end
    if values["behavior"] ~= nil then cappy.oBehParams2ndByte = m.marioObj.oUnk1A8 end
    if values["posX"] ~= nil then cappy.oPosX = m.marioObj.oHomeX end
    if values["posY"] ~= nil then cappy.oPosY = m.marioObj.oHomeY end
    if values["posZ"] ~= nil then cappy.oPosZ = m.marioObj.oHomeZ end
    if values["velX"] ~= nil then cappy.oVelX = m.marioObj.oParentRelativePosX end
    if values["velY"] ~= nil then cappy.oVelY = m.marioObj.oParentRelativePosY end
    if values["velZ"] ~= nil then cappy.oVelZ = m.marioObj.oParentRelativePosZ end
    gOmmCappyEvents[m.playerIndex][e] = m.marioObj.oUnkC0
    if is_debug() then
        local cappyEvents = {
            [OMM_CAPPY_EVENT_SPAWN]  = "SPAWN",
            [OMM_CAPPY_EVENT_HOMING] = "HOMING",
            [OMM_CAPPY_EVENT_RETURN] = "RETURN",
            [OMM_CAPPY_EVENT_UNLOAD] = "UNLOAD",
            [OMM_CAPPY_EVENT_BOUNCE] = "BOUNCE",
        }
        local log = "Player " .. get_global_index(m) .. " received [" .. cappyEvents[e] .. "] event with params: ("
        if values["behavior"] ~= nil then log = log .. "behavior: " .. m.marioObj.oUnk1A8 .. ", " end
        if values["posX"] ~= nil then log = log .. "posX: " .. m.marioObj.oHomeX .. ", " end
        if values["posY"] ~= nil then log = log .. "posY: " .. m.marioObj.oHomeY .. ", " end
        if values["posZ"] ~= nil then log = log .. "posZ: " .. m.marioObj.oHomeZ .. ", " end
        if values["velX"] ~= nil then log = log .. "velX: " .. m.marioObj.oParentRelativePosX .. ", " end
        if values["velY"] ~= nil then log = log .. "velY: " .. m.marioObj.oParentRelativePosY .. ", " end
        if values["velZ"] ~= nil then log = log .. "velZ: " .. m.marioObj.oParentRelativePosZ .. ", " end
        log = log .. "target: " .. cappy.oAction .. ", timestamp: " .. m.marioObj.oTimer .. ")"
        print(log)
    end
    return true
end

function omm_cappy_reset_events()
    for i = 0, (MAX_PLAYERS - 1) do
        local marioObj = gMarioStates[i].marioObj
        if marioObj ~= nil then marioObj.oUnk94 = 0 end
        gOmmCappyEvents[i] = {
            [OMM_CAPPY_EVENT_SPAWN]  = 0,
            [OMM_CAPPY_EVENT_HOMING] = 0,
            [OMM_CAPPY_EVENT_RETURN] = 0,
            [OMM_CAPPY_EVENT_UNLOAD] = 0,
            [OMM_CAPPY_EVENT_BOUNCE] = 0,
        }
    end
    local cappy = obj_get_first_with_behavior_id(id_bhvCappy)
    while cappy ~= nil do
        cappy.oSubAction = 0
        cappy = obj_get_next_with_same_behavior_id(cappy)
    end
    if is_debug() then
        print("<!> Resetting all Cappy objects and Cappy events...")
    end
end

hook_event(HOOK_ON_PLAYER_CONNECTED, omm_cappy_reset_events)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, omm_cappy_reset_events)

-- Spawn event: triggered when a player press (X) to throw Cappy
function omm_cappy_send_event_spawn(m, cappy)
    if is_local_player(m) and m.marioObj ~= nil then
        omm_cappy_send_event(m, cappy, OMM_CAPPY_EVENT_SPAWN, {
            behavior = true
        })
    end
end

function omm_cappy_process_event_spawn(m, cappy)
    if omm_cappy_process_event(m, cappy, OMM_CAPPY_EVENT_SPAWN, {
        behavior = true
    }) then
        cappy.oSubAction = 1
        cappy.oTimer = if_then_else(cappy.oBehParams2ndByte < OMM_CAPPY_BHV_SPIN_GROUND, -4, 0)
        cappy.oCapUnkF8 = 0
    end
end

-- Homing event: triggered when a player press a D-pad button to perform a homing attack
function omm_cappy_send_event_homing(m, cappy)
    if is_local_player(m) and m.marioObj ~= nil then
        omm_cappy_send_event(m, cappy, OMM_CAPPY_EVENT_HOMING, {
            posX = true,
            posY = true,
            posZ = true,
            velX = true,
            velY = true,
            velZ = true,
        })
    end
end

function omm_cappy_process_event_homing(m, cappy)
    if omm_cappy_process_event(m, cappy, OMM_CAPPY_EVENT_HOMING, {
        posX = true,
        posY = true,
        posZ = true,
        velX = true,
        velY = true,
        velZ = true,
    }) then
        cappy.oTimer = max(20, OMM_CAPPY_LIFETIME - OMM_CAPPY_HOMING_DURATION)
        cappy.oCapUnkF8 = 2
    end
end

-- Return event: triggered when a player's Cappy enters the state 'Return to Mario'
function omm_cappy_send_event_return(m, cappy)
    if is_local_player(m) and m.marioObj ~= nil then
        omm_cappy_send_event(m, cappy, OMM_CAPPY_EVENT_RETURN, {
            posX = true,
            posY = true,
            posZ = true,
        })
    end
end

function omm_cappy_process_event_return(m, cappy)
    if omm_cappy_process_event(m, cappy, OMM_CAPPY_EVENT_RETURN, {
        posX = true,
        posY = true,
        posZ = true,
    }) then
        cappy.oTimer = OMM_CAPPY_LIFETIME + 1
    end
end

-- Unload event: triggered when a player's Cappy must be unloaded
function omm_cappy_send_event_unload(m, cappy)
    if is_local_player(m) and m.marioObj ~= nil then
        omm_cappy_send_event(m, cappy, OMM_CAPPY_EVENT_UNLOAD, {
        })
    end
end

function omm_cappy_process_event_unload(m, cappy)
    if omm_cappy_process_event(m, cappy, OMM_CAPPY_EVENT_UNLOAD, {
    }) then
        cappy.oSubAction = 0
    end
end

-- Bounce event: triggered when a player bounces on a Cappy
function omm_cappy_send_event_bounce(m, cappy)
    if is_local_player(m) and m.marioObj ~= nil then
        omm_cappy_send_event(m, cappy, OMM_CAPPY_EVENT_BOUNCE, {
        })
    end
end

function omm_cappy_process_event_bounce(m, cappy)
    if omm_cappy_process_event(m, cappy, OMM_CAPPY_EVENT_BOUNCE, {
    }) then
        cappy.oSubAction = 0
    end
end

-- Process events
function omm_cappy_process_events(m)
    local cappy = obj_get_first_with_behavior_id(id_bhvCappy)
    while cappy ~= nil do
        omm_cappy_process_event_spawn (m, cappy)
        omm_cappy_process_event_homing(m, cappy)
        omm_cappy_process_event_return(m, cappy)
        omm_cappy_process_event_unload(m, cappy)
        omm_cappy_process_event_bounce(m, cappy)
        cappy = obj_get_next_with_same_behavior_id(cappy)
    end
end

function is_local_player(m)
    return m.playerIndex == 0
end

function get_global_index(m)
    return gNetworkPlayers[m.playerIndex].globalIndex
end

function global_to_local(i)
    for j = 0, (MAX_PLAYERS - 1) do
        if get_global_index(gMarioStates[j]) == i then
            return j
        end
    end
    return -1
end

function get_location(m)
    local np = gNetworkPlayers[m.playerIndex]
    return (
        (np.currLevelNum  << 8) |
        (np.currActNum    << 4) |
        (np.currAreaIndex << 0)
    )
end
