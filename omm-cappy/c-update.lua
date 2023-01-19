function omm_cappy_init_behavior(m, cappy)
    local isWater = if_then_else((m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED, 1, 0)

    -- Regular throw
    if cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_AIR then
        cappy.oPosX = m.pos.x
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_DEFAULT_OFFSET * (1 - isWater)
        cappy.oPosZ = m.pos.z
        cappy.oVelX = OMM_CAPPY_BHV_DEFAULT_VEL * coss(m.faceAngle.x * isWater) * sins(m.faceAngle.y)
        cappy.oVelY = OMM_CAPPY_BHV_DEFAULT_VEL * sins(m.faceAngle.x * isWater)
        cappy.oVelZ = OMM_CAPPY_BHV_DEFAULT_VEL * coss(m.faceAngle.x * isWater) * coss(m.faceAngle.y)

    -- Up-throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_AIR then
        cappy.oPosX = m.pos.x + OMM_CAPPY_BHV_UPWARDS_OFFSET * sins(m.faceAngle.y)
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_UPWARDS_OFFSET
        cappy.oPosZ = m.pos.z + OMM_CAPPY_BHV_UPWARDS_OFFSET * coss(m.faceAngle.y)
        cappy.oVelX = 0
        cappy.oVelY = OMM_CAPPY_BHV_UPWARDS_VEL
        cappy.oVelZ = 0

    -- Down-throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_AIR then
        cappy.oPosX = m.pos.x + OMM_CAPPY_BHV_DOWNWARDS_OFFSET * sins(m.faceAngle.y)
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_DOWNWARDS_OFFSET
        cappy.oPosZ = m.pos.z + OMM_CAPPY_BHV_DOWNWARDS_OFFSET * coss(m.faceAngle.y)
        cappy.oVelX = 0
        cappy.oVelY = -OMM_CAPPY_BHV_DOWNWARDS_VEL
        cappy.oVelZ = 0

    -- Spin throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_SPIN_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_SPIN_AIR then
        cappy.oPosX = m.pos.x
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_SPIN_OFFSET
        cappy.oPosZ = m.pos.z

    -- Flying throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_FLYING then
        cappy.oPosX = m.pos.x
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_FLYING_OFFSET
        cappy.oPosZ = m.pos.z
    end
end

function omm_cappy_update_behavior(m, cappy)

    -- Homing attack
    if cappy.oCapUnkF8 == 2 then
        if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
            omm_cappy_return_to_mario(m, cappy)
        else
            omm_cappy_perform_step(m, cappy, cappy.oVelX, cappy.oVelY, cappy.oVelZ, 0, 0)
        end
        return
    end

    -- Regular throw
    if cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_AIR then
        if cappy.oTimer < OMM_CAPPY_BHV_DEFAULT_CALL_BACK_START then
            cappy.oCapUnkF8 = 0
            omm_cappy_perform_step(m, cappy, cappy.oVelX, cappy.oVelY, cappy.oVelZ, OMM_CAPPY_COL_WALL_DEFAULT, 0)
            omm_cappy_slowdown(cappy)
        else
            cappy.oCapUnkF8 = 1
            omm_cappy_call_back(m, cappy, OMM_CAPPY_BHV_DEFAULT_CALL_BACK_START)
        end

    -- Up-throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_AIR then
        if cappy.oTimer < OMM_CAPPY_BHV_UPWARDS_CALL_BACK_START then
            cappy.oCapUnkF8 = 0
            omm_cappy_perform_step(m, cappy, cappy.oVelX, cappy.oVelY, cappy.oVelZ, 0, 0)
            omm_cappy_slowdown(cappy)
        else
            cappy.oCapUnkF8 = 1
            omm_cappy_call_back(m, cappy, OMM_CAPPY_BHV_UPWARDS_CALL_BACK_START)
        end

    -- Down-throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_AIR then
        if cappy.oTimer < OMM_CAPPY_BHV_DOWNWARDS_CALL_BACK_START then
            cappy.oCapUnkF8 = 0
            omm_cappy_perform_step(m, cappy, cappy.oVelX, cappy.oVelY, cappy.oVelZ, 0, OMM_CAPPY_COL_FLOOR_CHANGE_BEHAVIOR)
            omm_cappy_slowdown(cappy)
            if cappy.oVelY == 0 then
                cappy.oVelY = -(math.sqrt(sqr(cappy.oVelX) + sqr(cappy.oVelZ)) * OMM_CAPPY_BHV_DOWNWARDS_VEL) / OMM_CAPPY_BHV_DEFAULT_VEL
                cappy.oVelX = 0
                cappy.oVelZ = 0
            end
        else
            cappy.oCapUnkF8 = 1
            omm_cappy_call_back(m, cappy, OMM_CAPPY_BHV_DOWNWARDS_CALL_BACK_START)
        end

    -- Spin throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_SPIN_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_SPIN_AIR then
        local r = min(cappy.oTimer * OMM_CAPPY_BHV_SPIN_RADIUS_GROWTH, OMM_CAPPY_BHV_SPIN_RADIUS_MAX)
        cappy.oMoveAngleYaw = s16(cappy.oMoveAngleYaw + OMM_CAPPY_BHV_SPIN_ANGLE_VEL)
        cappy.oPosX = m.pos.x
        cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_SPIN_OFFSET
        cappy.oPosZ = m.pos.z
        cappy.oCapUnkF8 = 0
        omm_cappy_perform_step(m, cappy, r * coss(cappy.oMoveAngleYaw), 0, r * sins(cappy.oMoveAngleYaw), OMM_CAPPY_COL_WALL_FULL_STOP, 0)
        omm_cappy_call_back(m, cappy, OMM_CAPPY_BHV_SPIN_CALL_BACK_START)

    -- Flying throw
    elseif cappy.oBehParams2ndByte == OMM_CAPPY_BHV_FLYING then
        if m.action == ACT_FLYING then
            local r = min(cappy.oTimer * OMM_CAPPY_BHV_FLYING_RADIUS_GROWTH, OMM_CAPPY_BHV_FLYING_RADIUS_MAX)
            local a = s16(cappy.oTimer * OMM_CAPPY_BHV_FLYING_ANGLE_VEL)
            local v = { x = r * coss(a), y = r * sins(a), z = 0 }
            v = vec3f_rotate_zxy(v, -m.faceAngle.x, m.faceAngle.y, 0)
            cappy.oPosX = m.pos.x
            cappy.oPosY = m.pos.y + OMM_CAPPY_BHV_FLYING_OFFSET
            cappy.oPosZ = m.pos.z
            omm_cappy_perform_step(m, cappy, v.x, v.y, v.z, OMM_CAPPY_COL_WALL_FULL_STOP, 0)
        else
            omm_cappy_return_to_mario(m, cappy)
        end
        cappy.oMoveAngleYaw = m.faceAngle.y
        cappy.oCapUnkF8 = 0
        omm_cappy_call_back(m, cappy, OMM_CAPPY_BHV_FLYING_CALL_BACK_START)
    end
end

function omm_cappy_update(m, cappy)

    -- Unload Cappy if the player is not connected
    if not gNetworkPlayers[m.playerIndex].connected then
        omm_cappy_unload(m, cappy)
        cappy.oCapUnkF4 = 0
        return
    end

    -- Unload Cappy if not the same location as local Mario's
    if get_location(m) ~= get_location(gMarioStates[0]) then
        omm_cappy_unload(m, cappy)
        cappy.oCapUnkF4 = 0
        return
    end

    -- If not spawned, reset some values
    if cappy.oSubAction == 0 then
        cappy.oPosX = m.pos.x
        cappy.oPosY = m.pos.y
        cappy.oPosZ = m.pos.z
        cappy.oVelX = 0
        cappy.oVelY = 0
        cappy.oVelZ = 0
        cappy.oMoveAngleYaw = 0
        cappy.oCapUnkF8 = 0
        cappy.oTimer = -255
        return
    end

    -- Unload Cappy if Mario lost his cap
    if (m.flags & MARIO_CAP_ON_HEAD) == 0 then
        omm_cappy_unload(m, cappy)
        return
    end

    -- Init Cappy
    if cappy.oTimer == 0 then
        omm_cappy_init_behavior(m, cappy)
        cappy.oMoveAngleYaw = m.faceAngle.y
    end
    
    -- Update Cappy's behavior
    if cappy.oTimer >= 0 then
        if cappy.oTimer < OMM_CAPPY_LIFETIME then
            omm_cappy_update_behavior(m, cappy)
            omm_cappy_process_object_interactions(m, cappy)
        elseif cappy.oTimer == OMM_CAPPY_LIFETIME then
            omm_cappy_return_to_mario(m, cappy)
        elseif omm_cappy_perform_step_return_to_mario(m, cappy) then
            omm_cappy_unload(m, cappy)
            return
        end
    end
end

function omm_cappy_main(m)
    if gNetworkPlayers[m.playerIndex].connected then
        
        -- Apply weaker gravity on air throw
        if m.action == ACT_OMM_CAPPY_THROW_AIRBORNE then
            m.vel.y = clamp(m.vel.y + 2.0, -75, 100)
        end

        -- Fix MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN
        if m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN and m.action ~= ACT_JUMBO_STAR_CUTSCENE then
            m.marioObj.header.gfx.pos.y = m.pos.y + 60
        end
        
        -- Process Mario interactions with Cappy's and update Mario's state
        local cappy = omm_cappy_get_object(m)
        if cappy ~= nil then
            if is_local_player(m) then

                -- Reset bounced flag for all Cappy's when grounded
                if ((m.action & ACT_FLAG_AIR) == 0 and m.floor.type ~= 0x0001) then
                    local obj = obj_get_first_with_behavior_id(id_bhvCappy)
                    while obj ~= nil do
                        obj.oCapUnkF4 = 0
                        obj = obj_get_next_with_same_behavior_id(obj)
                    end
                end
                omm_cappy_process_mario_interactions(m, cappy)
            end

            -- Process Cappy events
            omm_cappy_process_events(m)

            -- Update Mario's roll during a flying throw
            if cappy.oSubAction == 1 and cappy.oBehParams2ndByte == OMM_CAPPY_BHV_FLYING and m.action == ACT_FLYING and cappy.oTimer < OMM_CAPPY_BHV_FLYING_CALL_BACK_START then
                m.marioObj.header.gfx.angle.z = s16(m.marioObj.header.gfx.angle.z + (cappy.oTimer * 0x10000) / OMM_CAPPY_BHV_FLYING_CALL_BACK_START)
            end

            -- Update Mario's cap state
            if cappy.oSubAction == 1 and cappy.oTimer >= 0 then
                m.marioBodyState.capState = MARIO_HAS_DEFAULT_CAP_OFF
            end
        end
    end
end

hook_event(HOOK_MARIO_UPDATE, omm_cappy_main)
