function omm_cappy_return_to_mario(m, cappy)
    if cappy.oTimer <= OMM_CAPPY_LIFETIME then
        cappy.oTimer = OMM_CAPPY_LIFETIME + 1
        omm_cappy_send_event_return(m, cappy)
    end
end

function omm_cappy_bounce_back(m, cappy)
    if cappy.oBehParams2ndByte < OMM_CAPPY_BHV_SPIN_GROUND then
        spawn_non_sync_object(id_bhvHorStarParticleSpawner, E_MODEL_NONE, cappy.oPosX, cappy.oPosY, cappy.oPosZ, nil)
        play_sound(OMM_SOUND_OBJ_DEFAULT_DEATH, cappy.header.gfx.cameraToObject)
        omm_cappy_return_to_mario(m, cappy)
    end
end

function omm_cappy_perform_step(m, cappy, vx, vy, vz, wallColHandler, floorColHandler)
    for i = 1, 8 do
        local x = cappy.oPosX
        local y = cappy.oPosY
        local z = cappy.oPosZ
        cappy.oPosX = cappy.oPosX + (vx / 8)
        cappy.oPosY = cappy.oPosY + (vy / 8)
        cappy.oPosZ = cappy.oPosZ + (vz / 8)

        -- Walls
        if (m.flags & MARIO_VANISH_CAP) == 0 then
            local pos = { x = cappy.oPosX, y = cappy.oPosY, z = cappy.oPosZ }
            local wall = resolve_and_return_wall_collisions(pos, OMM_CAPPY_HITBOX_HEIGHT / 2, OMM_CAPPY_WALL_RADIUS)
            if wall ~= nil then
                cappy.oPosX = pos.x
                cappy.oPosY = pos.y
                cappy.oPosZ = pos.z
                if wallColHandler == OMM_CAPPY_COL_WALL_DEFAULT then
                    local wallDYaw = s16(atan2s(wall.normal.z, wall.normal.x) - atan2s(cappy.oVelZ, cappy.oVelX))
                    if (wallDYaw < 0x2000 or wallDYaw > 0x6000) and (wallDYaw > -0x2000 or wallDYaw < -0x6000) then
                        cappy.oVelX = 0
                        cappy.oVelY = 0
                        cappy.oVelZ = 0
                        return
                    end
                elseif wallColHandler == OMM_CAPPY_COL_WALL_FULL_STOP then
                    return
                end
            end
        end

        -- Floor
        local floorY = find_floor_height(cappy.oPosX, cappy.oPosY, cappy.oPosZ)
        if floorY > -11000 then
            local diffY = cappy.oPosY - floorY
            if diffY < 0 then
                cappy.oPosY = floorY
                if floorColHandler == OMM_CAPPY_COL_FLOOR_CHANGE_BEHAVIOR then
                    if cappy.oVelY ~= 0 then
                        cappy.oVelX = (OMM_CAPPY_BHV_DEFAULT_VEL / OMM_CAPPY_BHV_DOWNWARDS_VEL) * sins(cappy.oMoveAngleYaw) * abs(cappy.oVelY)
                        cappy.oVelZ = (OMM_CAPPY_BHV_DEFAULT_VEL / OMM_CAPPY_BHV_DOWNWARDS_VEL) * coss(cappy.oMoveAngleYaw) * abs(cappy.oVelY)
                        cappy.oVelY = 0
                        vx = cappy.oVelX
                        vy = cappy.oVelY
                        vz = cappy.oVelZ
                    end
                end
            end
        else
            cappy.oPosX = x
            cappy.oPosY = y
            cappy.oPosZ = z
        end
        
        -- Ceiling
        if (m.flags & MARIO_VANISH_CAP) == 0 then
            local ceilY = find_ceil_height(cappy.oPosX, cappy.oPosY, cappy.oPosZ)
            if ceilY < 20000 then
                local height = OMM_CAPPY_HITBOX_HEIGHT - OMM_CAPPY_HITBOX_OFFSET
                if ceilY - height < cappy.oPosY and cappy.oPosY < ceilY then
                    cappy.oPosY = max(ceilY - height, floorY)
                end
            end
        end
    end
end

function omm_cappy_slowdown(cappy)
    cappy.oVelX = cappy.oVelX / OMM_CAPPY_SLOWDOWN_FACTOR
    cappy.oVelY = cappy.oVelY / OMM_CAPPY_SLOWDOWN_FACTOR
    cappy.oVelZ = cappy.oVelZ / OMM_CAPPY_SLOWDOWN_FACTOR
end

function omm_cappy_call_back(m, cappy, cbStart)
    if cappy.oTimer >= cbStart then
        local udlrx = m.controller.buttonPressed & (U_JPAD | D_JPAD | L_JPAD | R_JPAD | X_BUTTON)
        if udlrx ~= 0 then

            -- Homing attack
            if (udlrx & X_BUTTON) == 0 then
                cappy.oCapUnkF8 = 2
                cappy.oTimer = max(20, OMM_CAPPY_LIFETIME - OMM_CAPPY_HOMING_DURATION - 1)
                local velocity = OMM_CAPPY_HOMING_VELOCITY
                local duration = OMM_CAPPY_LIFETIME - (cappy.oTimer + 1)
                local target = omm_cappy_find_target(cappy, velocity * duration)
                if target ~= nil then
                    local dx = target.oPosX - cappy.oPosX
                    local dy = target.oPosY - cappy.oPosY
                    local dz = target.oPosZ - cappy.oPosZ
                    local dv = math.sqrt(sqr(dx) + sqr(dy) + sqr(dz))
                    if dv ~= 0 then
                        cappy.oVelX = (velocity * dx) / dv
                        cappy.oVelY = (velocity * dy) / dv
                        cappy.oVelZ = (velocity * dz) / dv
                        omm_cappy_send_event_homing(m, cappy)
                    else
                        omm_cappy_return_to_mario(m, cappy)
                    end
                else
                    if (cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DEFAULT_AIR or
                        cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_UPWARDS_AIR or
                        cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_GROUND or cappy.oBehParams2ndByte == OMM_CAPPY_BHV_DOWNWARDS_AIR) then
                        if udlrx == U_JPAD then
                            cappy.oVelX = 0
                            cappy.oVelY = velocity
                            cappy.oVelZ = 0
                        elseif udlrx == D_JPAD then
                            cappy.oVelX = 0
                            cappy.oVelY = -velocity
                            cappy.oVelZ = 0
                        elseif udlrx == L_JPAD then
                            cappy.oVelX = velocity * sins(cappy.oMoveAngleYaw + 0x4000)
                            cappy.oVelY = 0
                            cappy.oVelZ = velocity * coss(cappy.oMoveAngleYaw + 0x4000)
                        elseif udlrx == R_JPAD then
                            cappy.oVelX = velocity * sins(cappy.oMoveAngleYaw - 0x4000)
                            cappy.oVelY = 0
                            cappy.oVelZ = velocity * coss(cappy.oMoveAngleYaw - 0x4000)
                        else
                            omm_cappy_return_to_mario(m, cappy)
                            return
                        end
                        omm_cappy_send_event_homing(m, cappy)
                    else
                        omm_cappy_return_to_mario(m, cappy)
                    end
                end
            else
                omm_cappy_return_to_mario(m, cappy)
            end
        end
    end
end

function omm_cappy_perform_step_return_to_mario(m, cappy)

    -- Disable interactions
    cappy.oCapUnkF8 = 0

    -- Move Cappy closer to Mario
    local dx = m.pos.x - cappy.oPosX
    local dy = m.pos.y - cappy.oPosY + (0.4 * m.marioObj.hitboxHeight * m.marioObj.header.gfx.scale.y)
    local dz = m.pos.z - cappy.oPosZ
    local dv = math.sqrt(sqr(dx) + sqr(dy) + sqr(dz))
    if dv > OMM_CAPPY_RETURN_VEL then
        cappy.oPosX = cappy.oPosX + (dx / dv) * OMM_CAPPY_RETURN_VEL
        cappy.oPosY = cappy.oPosY + (dy / dv) * OMM_CAPPY_RETURN_VEL
        cappy.oPosZ = cappy.oPosZ + (dz / dv) * OMM_CAPPY_RETURN_VEL
    else
        cappy.oPosX = cappy.oPosX + dx
        cappy.oPosY = cappy.oPosY + dy
        cappy.oPosZ = cappy.oPosZ + dz
    end

    -- Unloads Cappy if he's close enough to Mario
    local marioRadius = m.marioObj.header.gfx.scale.x * 50
    local cappyRadius = OMM_CAPPY_GFX_SCALE_X * OMM_CAPPY_HITBOX_RADIUS / 2
    return dv - OMM_CAPPY_RETURN_VEL <= marioRadius + cappyRadius
end
