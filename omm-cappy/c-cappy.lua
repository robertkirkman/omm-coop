-- Cappy fields
-- oAction              -> index (Mario's global index + 1)
-- oSubAction           -> spawned
-- oTimer               -> timer
-- oUnkBC               -> timestamp
-- oPosX, oPosY, oPosZ  -> position
-- oVelX, oVelY, oVelZ  -> velocity
-- oMoveAngleYaw        -> direction
-- oBehParams2ndByte    -> behavior
-- oCapUnkF4            -> bounced
-- oCapUnkF8            -> flags: 0 = none, 1 = interact with local Mario, 2 = homing attack

function bhv_cappy_init(o)
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

function bhv_cappy_loop(o)
    if o.oAction ~= 0 then
        local i = global_to_local(o.oAction - 1)
        local m = gMarioStates[i]
        omm_cappy_update(m, o)
        omm_cappy_update_gfx(m, o)
    end
end

id_bhvCappy = hook_behavior(nil, OBJ_LIST_SPAWNER, true, bhv_cappy_init, bhv_cappy_loop)

function omm_cappy_get_object(m)
    local index = get_global_index(m) + 1
    local cappy = obj_get_first_with_behavior_id_and_field_s32(id_bhvCappy, 0x31, index)
    if cappy == nil then
        cappy = spawn_non_sync_object(id_bhvCappy, E_MODEL_NONE, m.pos.x, m.pos.y, m.pos.z, nil)
        if cappy ~= nil then
            cappy.oAction = index
            cappy.globalPlayerIndex = index - 1
        end
    end
    return cappy
end

function omm_cappy_get_behavior(m)
    local air = if_then_else((m.action & (ACT_FLAG_AIR | ACT_FLAG_SWIMMING | ACT_FLAG_METAL_WATER)) ~= 0, 1, 0)
    if m.action == ACT_FLYING                  then return OMM_CAPPY_BHV_FLYING end
    if (m.controller.buttonDown & U_JPAD) ~= 0 then return OMM_CAPPY_BHV_UPWARDS_GROUND + air end
    if (m.controller.buttonDown & D_JPAD) ~= 0 then return OMM_CAPPY_BHV_DOWNWARDS_GROUND + air end
    if (m.controller.buttonDown & L_JPAD) ~= 0 then return OMM_CAPPY_BHV_SPIN_GROUND + air end
    if (m.controller.buttonDown & R_JPAD) ~= 0 then return OMM_CAPPY_BHV_SPIN_GROUND + air end
    if m.action == ACT_GROUND_POUND_LAND       then return OMM_CAPPY_BHV_DOWNWARDS_GROUND end
    if m.action == ACT_OMM_SPIN_GROUND         then return OMM_CAPPY_BHV_SPIN_GROUND end
    if m.action == ACT_OMM_SPIN_AIR            then return OMM_CAPPY_BHV_SPIN_AIR end
    if true                                    then return OMM_CAPPY_BHV_DEFAULT_GROUND + air end
end

function omm_cappy_spawn(m)
    local cappy = omm_cappy_get_object(m)
    if cappy ~= nil and cappy.oSubAction == 0 and (m.flags & MARIO_CAP_ON_HEAD) ~= 0 then
        if is_local_player(m) then
            local behavior = omm_cappy_get_behavior(m)
            cappy.oBehParams2ndByte = behavior
            cappy.oSubAction = 1
            cappy.oTimer = if_then_else(behavior < OMM_CAPPY_BHV_SPIN_GROUND, -4, 0)
            cappy.oUnkBC = m.marioObj.oTimer
            cappy.oCapUnkF8 = 0
            omm_cappy_send_event_spawn(m, cappy)
        end
        return true
    end
    return false
end

function omm_cappy_unload(m, cappy)
    if cappy.oSubAction ~= 0 then
        cappy.oSubAction = 0
        omm_cappy_send_event_unload(m, cappy)
    end
end
