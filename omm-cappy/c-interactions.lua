-------------------------
-- Object interactions --
-------------------------

gCappyInteractionLists = {
    OBJ_LIST_PLAYER,
    OBJ_LIST_LEVEL,
    OBJ_LIST_SURFACE,
    OBJ_LIST_POLELIKE,
    OBJ_LIST_PUSHABLE,
    OBJ_LIST_GENACTOR,
    OBJ_LIST_DESTRUCTIVE
}

function omm_cappy_is_obj_targetable(obj)
    return obj_check_interaction(obj) and (
           obj_is_mario(obj) or
           obj_is_coin(obj) or
           obj_is_mushroom_1up(obj) or
           obj_is_exclamation_box(obj) or
           obj_is_bully(obj) or
           obj_is_grabbable(obj) or
           obj_is_breakable(obj) or
           obj_is_attackable(obj))
end

function omm_cappy_find_target(cappy, distmax)
    local target = nil
    local targetCoin = nil
    local distmin = distmax
    local distminCoin = distmax
    for i, objList in ipairs(gCappyInteractionLists) do
        local obj = obj_get_first(objList)
        while obj ~= nil do
            if omm_cappy_is_obj_targetable(obj) then
                local distToCappy = math.sqrt(sqr(obj.oPosX - cappy.oPosX) + sqr(obj.oPosY - cappy.oPosY) + sqr(obj.oPosZ - cappy.oPosZ)) - (OMM_CAPPY_HITBOX_RADIUS + obj.hitboxRadius)
                if obj_is_coin(obj) then
                    if distToCappy < distminCoin then
                        distminCoin = distToCappy
                        targetCoin = obj
                    end
                else
                    if distToCappy < distmin then
                        distmin = distToCappy
                        target = obj
                    end
                end
            end
            obj = obj_get_next(obj)
        end
    end
    return if_then_else(targetCoin ~= nil, targetCoin, target)
end

function omm_cappy_mario_can_grab(m, obj)
    if m.heldObj ~= nil or m.riddenObj ~= nil then return false end
    if m.action == ACT_FIRST_PERSON then return false end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_CUTSCENE then return false end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_AUTOMATIC then return false end
    if (m.action & ACT_FLAG_AIR) ~= 0 then return false end
    if (m.action & ACT_FLAG_SWIMMING) ~= 0 then return false end
    if (m.action & ACT_FLAG_METAL_WATER) ~= 0 then return false end
    if (m.action & ACT_FLAG_ON_POLE) ~= 0 then return false end
    if (m.action & ACT_FLAG_HANGING) ~= 0 then return false end
    if (m.action & ACT_FLAG_INTANGIBLE) ~= 0 then return false end
    if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 then return false end
    if (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then return false end
    if (obj_has_behavior_id(obj, id_bhvBowser) == 1) then return false end
    if (obj_has_behavior_id(obj, id_bhvBowserTailAnchor) == 1) then return false end
    return true
end

function omm_cappy_process_object_interaction(m, cappy, obj)

    -- Coin
    --- Teleport it to Mario
    --- Homing attack: target the next nearest coin or object
    if obj_is_coin(obj) then

        -- Target next nearest object
        if cappy.oCapUnkF8 == 2 then
            obj.oInteractStatus = INT_STATUS_INTERACTED
            local target = omm_cappy_find_target(cappy, OMM_CAPPY_HOMING_VELOCITY * OMM_CAPPY_HOMING_DURATION)
            obj.oInteractStatus = 0
            if target ~= nil then
                local dx = target.oPosX - cappy.oPosX
                local dy = target.oPosY - cappy.oPosY
                local dz = target.oPosZ - cappy.oPosZ
                local dv = math.sqrt(sqr(dx) + sqr(dy) + sqr(dz))
                if dv ~= 0 then
                    cappy.oVelX = (OMM_CAPPY_HOMING_VELOCITY * dx) / dv
                    cappy.oVelY = (OMM_CAPPY_HOMING_VELOCITY * dy) / dv
                    cappy.oVelZ = (OMM_CAPPY_HOMING_VELOCITY * dz) / dv
                    cappy.oTimer = max(20, OMM_CAPPY_LIFETIME - OMM_CAPPY_HOMING_DURATION)
                    omm_cappy_send_event_homing(m, cappy)
                end
            end
        end

        -- Collect coin
        if is_local_player(m) then
            obj.oPosX = m.pos.x + m.vel.x
            obj.oPosY = m.pos.y + m.vel.y + 60
            obj.oPosZ = m.pos.z + m.vel.z
        else
            obj.oIntangibleTimer = -1
            obj.oInteractStatus = INT_STATUS_INTERACTED
        end
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        return true
    end

    -- Mushroom 1up
    --- Teleport it to Mario
    if obj_is_mushroom_1up(obj) then
        obj.oPosX = m.pos.x + m.vel.x
        obj.oPosY = m.pos.y + m.vel.y + 60
        obj.oPosZ = m.pos.z + m.vel.z
        obj.header.gfx.node.flags = obj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        return false
    end



    -- Secret
    --- Set interacted flag to collect it
    if obj_is_secret(obj) then
        obj.oInteractStatus = INT_STATUS_INTERACTED
        return false
    end

    -- Exclamation box
    --- Attack it to break it
    if obj_is_exclamation_box(obj) then
        obj.oInteractStatus = INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        omm_cappy_bounce_back(m, cappy)
        return true
    end

    -- Bully
    --- Bully the bully
    if obj_is_bully(obj) then
        obj.oForwardVel = 3600 / obj.hitboxRadius
        obj.oMoveAngleYaw = cappy.oMoveAngleYaw
        obj.oFaceAngleYaw = obj.oMoveAngleYaw + 0x8000
        obj.oInteractStatus = ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        play_sound(OMM_SOUND_OBJ_BULLY_METAL, obj.header.gfx.cameraToObject)
        omm_cappy_bounce_back(m, cappy)
        return true
    end

    -- Grabbable
    --- Make Mario instantly grab the interacted object
    --- Change the current animation to the first punch, and make it end next frame
    if obj_is_grabbable(obj) then
        if omm_cappy_mario_can_grab(m, obj) then
            if is_local_player(m) then
                m.usedObj = obj
                mario_grab_used_object(m)
                omm_mario_set_action(m, ACT_PICKING_UP, 0, 0)
                set_mario_animation(m, MARIO_ANIM_FIRST_PUNCH)
                mario_anim_clamp(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd - 2, m.marioObj.header.gfx.animInfo.curAnim.loopEnd - 2)
            end
            omm_cappy_return_to_mario(m, cappy)
            return true
        end
    end

    -- Breakable
    --- Set some specific flags to send a signal 'break that box'
    if obj_is_breakable(obj) then
        obj.oInteractStatus = ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED | INT_STATUS_STOP_RIDING
        omm_cappy_bounce_back(m, cappy)
        return true
    end

    -- Attackable
    --- Attack it to damage it
    --- Do a ground-pound type attack to huge goombas to make them spawn their blue coin
    if obj_is_attackable(obj) then
        if obj_has_behavior_id(obj, id_bhvGoomba) and (obj.oGoombaSize & 1) ~= 0 then
            obj.oInteractStatus = ATTACK_GROUND_POUND_OR_TWIRL | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        else
            obj.oInteractStatus = ATTACK_KICK_OR_TRIP | INT_STATUS_INTERACTED | INT_STATUS_WAS_ATTACKED
        end
        omm_cappy_bounce_back(m, cappy)
        return true
    end

    -- No interaction
    return false
end

function omm_cappy_process_object_interactions(m, cappy)
    local hitboxCappy = {
        x = cappy.oPosX,
        y = cappy.oPosY,
        z = cappy.oPosZ,
        r = OMM_CAPPY_HITBOX_RADIUS,
        h = OMM_CAPPY_HITBOX_HEIGHT,
        d = OMM_CAPPY_HITBOX_OFFSET
    }
    for i, objList in ipairs(gCappyInteractionLists) do
        local obj = obj_get_first(objList)
        while obj ~= nil do
            if obj_check_interaction(obj) then
                local hitboxObj = {
                    x = obj.oPosX,
                    y = obj.oPosY,
                    z = obj.oPosZ,
                    r = max(obj.hitboxRadius, obj.hurtboxRadius),
                    h = max(obj.hitboxHeight, obj.hurtboxHeight),
                    d = obj.hitboxDownOffset
                }
                if obj_check_hitbox_overlap(hitboxCappy, hitboxObj) and omm_cappy_process_object_interaction(m, cappy, obj) then
                    return
                end
            end
            obj = obj_get_next(obj)
        end
    end
end

----------------------------
-- Gamemodes interactions --
----------------------------

function is_chaser(i)
    return (gNetworkPlayers[i].description == "seeker" or
            gNetworkPlayers[i].description == "It" or
            gNetworkPlayers[i].description == "Zombie") and
           (gMarioStates[i].marioBodyState.modelState == MODEL_STATE_METAL) and
           (gMarioStates[i].flags & (MARIO_METAL_CAP | MARIO_METAL_SHOCK)) == 0
end

function is_runner(i)
    return gNetworkPlayers[i].description == "hider" or
           gNetworkPlayers[i].description == "Runner" or
           gNetworkPlayers[i].description == "Frozen" or
           gNetworkPlayers[i].description == "Survivor" or
           not is_chaser(i)
end

function resolve_cappy_collision(m, i)
    if i ~= m.playerIndex and is_chaser(i) and is_runner(m.playerIndex) then
        m.health = 0x10F
    end
end

------------------------
-- Mario interactions --
------------------------

function omm_cappy_mario_can_bounce(m)
    if m.heldObj ~= nil or m.riddenObj ~= nil then return false end
    if m.vel.y <= 0 and (m.action == ACT_LAVA_BOOST or m.action == ACT_LAVA_BOOST_LAND) then return true end
    if m.action == ACT_BUBBLED then return true end
    if m.action == ACT_FIRST_PERSON then return false end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_CUTSCENE then return false end
    if (m.action & ACT_GROUP_MASK) == ACT_GROUP_AUTOMATIC then return false end
    if (m.action & ACT_FLAG_SWIMMING) ~= 0 then return false end
    if (m.action & ACT_FLAG_METAL_WATER) ~= 0 then return false end
    if (m.action & ACT_FLAG_ON_POLE) ~= 0 then return false end
    if (m.action & ACT_FLAG_INTANGIBLE) ~= 0 then return false end
    if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 then return false end
    return true
end

function omm_cappy_process_mario_interactions(m, cappy)
    if omm_cappy_mario_can_bounce(m) then
        local hitboxMario = {
            x = m.pos.x,
            y = m.pos.y,
            z = m.pos.z,
            r = 50,
            h = m.marioObj.hitboxHeight,
            d = 0
        }

        local obj = obj_get_first_with_behavior_id(id_bhvCappy)
        while obj ~= nil do
            if (obj.oSubAction == 1 and             -- Cappy is spawned
                obj.oTimer > 0 and                  -- Cappy is active
                obj.oTimer < OMM_CAPPY_LIFETIME and -- Cappy is not returning to Mario
                obj.oCapUnkF4 == 0 and (            -- Mario can bounce on that Cappy
                obj.oCapUnkF8 == 1 or               -- Cappy can interact with Mario
                obj.oAction ~= cappy.oAction)       -- That Cappy is not local Mario's
            ) then
                local hitboxCappy = {
                    x = obj.oPosX,
                    y = obj.oPosY,
                    z = obj.oPosZ,
                    r = OMM_CAPPY_HITBOX_RADIUS,
                    h = OMM_CAPPY_HITBOX_HEIGHT,
                    d = OMM_CAPPY_HITBOX_OFFSET
                }

                -- Check hitbox overlap
                if obj_check_hitbox_overlap(hitboxCappy, hitboxMario) then

                    -- Pop bubble
                    if m.action == ACT_BUBBLED then
                        m.vel.x = 0
                        m.vel.y = 0
                        m.vel.z = 0
                        m.health = 0x100
                        m.hurtCounter = 0
                        m.healCounter = 31
                        m.peakHeight = m.pos.y
                        m.marioObj.oIntangibleTimer = 0
                        m.marioObj.activeFlags = m.marioObj.activeFlags & ~ACTIVE_FLAG_MOVE_THROUGH_GRATE
                        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
                        if m.pos.y < m.waterLevel then
                            omm_mario_set_action(m, ACT_WATER_IDLE, 0, 0)
                        else
                            omm_mario_set_action(m, ACT_FREEFALL, 0, 0)
                        end
                        play_sound(OMM_SOUND_OBJ_DEFAULT_DEATH, m.marioObj.header.gfx.cameraToObject)

                    -- Cappy bounce
                    elseif (m.action & ACT_FLAG_AIR) ~= 0 or m.floor.type == 0x0001 then
                        obj.oCapUnkF4 = 1
                        omm_mario_set_action(m, ACT_OMM_CAPPY_BOUNCE, 0, 0)
                        play_sound(OMM_SOUND_ACTION_BOING, m.marioObj.header.gfx.cameraToObject)

                    -- Cappy vault
                    else
                        omm_mario_set_action(m, ACT_OMM_CAPPY_VAULT, 0, 0)
                        play_sound(OMM_SOUND_ACTION_BOING, m.marioObj.header.gfx.cameraToObject)
                    end

                    -- Coop gamemodes
                    resolve_cappy_collision(m, global_to_local(obj.oAction - 1))

                    -- Unload interacted Cappy
                    omm_cappy_send_event_bounce(m, obj)
                    obj.oSubAction = 0
                    m.particleFlags = m.particleFlags | PARTICLE_HORIZONTAL_STAR
                    return
                end
            end
            obj = obj_get_next_with_same_behavior_id(obj)
        end
    end
end
