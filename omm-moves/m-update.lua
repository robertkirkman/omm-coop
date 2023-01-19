----------
-- Data --
----------

function omm_mario_update_data(m)
    local g = omm_mario_get(m)

    -- Update some flags on ground
    if (m.action & ACT_FLAG_AIR) == 0 then
        g.wallSlideHeight = 20000
        g.wallSlideJumped = false
        g.wallSlideAngle = 0
        g.midairSpinTimer = 0
        g.midairSpinCounter = 0
        g.airCombo = 0
    end
end

--------------
-- Handling --
--------------

gActionsWithHandling = {
    [ACT_WALKING] = 1,
    [ACT_HOLD_WALKING] = 1,
    [ACT_HOLD_HEAVY_WALKING] = 1,
    [ACT_FINISH_TURNING_AROUND] = 1,
    [ACT_CRAWLING] = 1,
    [ACT_BURNING_GROUND] = 1,
    [ACT_JUMP_LAND] = 1,
    [ACT_FREEFALL_LAND] = 1,
    [ACT_DOUBLE_JUMP_LAND] = 1,
    [ACT_SIDE_FLIP_LAND] = 1,
    [ACT_HOLD_JUMP_LAND] = 1,
    [ACT_HOLD_FREEFALL_LAND] = 1,
    [ACT_QUICKSAND_JUMP_LAND] = 1,
    [ACT_HOLD_QUICKSAND_JUMP_LAND] = 1,
    [ACT_TRIPLE_JUMP_LAND] = 1,
    [ACT_LONG_JUMP_LAND] = 1,
    [ACT_BACKFLIP_LAND] = 1,
    [ACT_JUMP] = 1,
    [ACT_DOUBLE_JUMP] = 1,
    [ACT_TRIPLE_JUMP] = 1,
    [ACT_STEEP_JUMP] = 1,
    [ACT_WALL_KICK_AIR] = 100,
    [ACT_LONG_JUMP] = 100,
    [ACT_WATER_JUMP] = 1,
    [ACT_DIVE] = 100,
    [ACT_FREEFALL] = 1,
    [ACT_TOP_OF_POLE_JUMP] = 1,
    [ACT_VERTICAL_WIND] = 1,
    [ACT_HOLD_JUMP] = 1,
    [ACT_HOLD_FREEFALL] = 1,
    [ACT_HOLD_WATER_JUMP] = 1,
    [ACT_JUMP_KICK] = 1,
    [ACT_CRAZY_BOX_BOUNCE] = 1,
    [ACT_BURNING_JUMP] = 1,
    [ACT_BURNING_FALL] = 1,
    [ACT_LAVA_BOOST] = 1,
    [ACT_HANG_MOVING] = 1,
    [ACT_OMM_CAPPY_BOUNCE] = 1,
    [ACT_OMM_CAPPY_VAULT] = 1,
    [ACT_OMM_GROUND_POUND_JUMP] = 1,
    [ACT_OMM_ROLL_AIR] = 100,
    [ACT_OMM_SPIN_AIR] = 1,
    [ACT_OMM_SPIN_JUMP] = 1,
    [ACT_OMM_MIDAIR_SPIN] = 1,
}

function omm_mario_get_handling(m, vmin, vmax, hmin, hmax)
    local vel = max(abs(m.forwardVel), gActionsWithHandling[m.action])
    local mag = m.intendedMag / 32.0
    if m.action == ACT_OMM_ROLL_AIR then mag = mag / 2 end
    return ((hmin + sqr(1.0 - invlerp(vel, vmin, vmax)) * (hmax - hmin)) * mag)
end

function omm_mario_update_handling(m)
    if (m.input & INPUT_NONZERO_ANALOG) ~= 0 and gActionsWithHandling[m.action] ~= nil then
        local handling = if_then_else(
            (m.action & ACT_FLAG_AIR) ~= 0,
            omm_mario_get_handling(m, 8, 24, 0x200, 0x2000),
            omm_mario_get_handling(m, 8, 32, 0x800, 0x4000)
        )
        m.faceAngle.y = s16(m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, handling, handling))
        mario_set_forward_vel(m, m.forwardVel)
    end
end

----------
-- Spin --
----------

sIsGunModEnabled = -5
function is_gun_mod_enabled()
    if sIsGunModEnabled < 0 then
        for bhvId = 0x8000, 0x8020 do
            local obj = obj_get_first_with_behavior_id(bhvId)
            if obj ~= nil and abs(obj.header.gfx.scale.x - 0.12) < 0.01 then
                sIsGunModEnabled = 1
                return true
            end
        end
        sIsGunModEnabled = sIsGunModEnabled + 1
        return false
    end
    return sIsGunModEnabled == 1
end

function omm_spin_checkpoint(angle)
    return u16(u16(angle) / 0x4000)
end

function omm_spin_intended_next(cp, dir)
    return u16(u16(cp + dir + 4) & 3)
end

function omm_mario_update_spin(m)
    local g = omm_mario_get(m)

    -- Update spin timer
    if g.spinTimer > 0 then
        g.spinTimer = g.spinTimer - 1
    end

    -- Update midair spin timer
    if g.midairSpinTimer > 0 then
        g.midairSpinTimer = g.midairSpinTimer - 1
    end

    -- Update spin buffer
    if m.controller.stickMag >= 40.0 then
        local cp = omm_spin_checkpoint(atan2s(m.controller.stickY, m.controller.stickX))

        -- We first set the first cp
        if g.spinCheckpoint == -1 then
            g.spinCheckpoint = cp
            g.spinNumHitCheckpoints = g.spinNumHitCheckpoints + 1
            g.spinBufferTimer = OMM_MARIO_SPIN_BUFFER_DURATION

        -- Then we set the direction
        elseif g.spinDirection == 0 then
            if cp ~= g.spinCheckpoint then
                if cp == omm_spin_intended_next(g.spinCheckpoint, -1) then
                    g.spinCheckpoint = cp
                    g.spinDirection = -1
                    g.spinNumHitCheckpoints = g.spinNumHitCheckpoints + 1
                    g.spinBufferTimer = OMM_MARIO_SPIN_BUFFER_DURATION
                elseif cp == omm_spin_intended_next(g.spinCheckpoint, 1) then
                    g.spinCheckpoint = cp
                    g.spinDirection = 1
                    g.spinNumHitCheckpoints = g.spinNumHitCheckpoints + 1
                    g.spinBufferTimer = OMM_MARIO_SPIN_BUFFER_DURATION
                else
                    g.spinBufferTimer = 0
                end
            end

        -- And we check if the hit cp is the intended next
        elseif cp ~= g.spinCheckpoint then
            if cp == omm_spin_intended_next(g.spinCheckpoint, g.spinDirection) then
                g.spinCheckpoint = cp
                g.spinNumHitCheckpoints = g.spinNumHitCheckpoints + 1
                g.spinBufferTimer = OMM_MARIO_SPIN_BUFFER_DURATION
            else
                g.spinBufferTimer = 0
            end
        end
    else
        g.spinBufferTimer = 0
    end

    -- Hidden spin shortcut (Y button for coop)
    -- Gun mod uses Y as shoot button, don't trigger the shortcut
    if (m.controller.buttonPressed & Y_BUTTON) ~= 0 then
        if not is_gun_mod_enabled() then
            g.spinNumHitCheckpoints = OMM_MARIO_SPIN_MIN_HIT_CHECKPOINTS
        end
    end

    -- If Mario has the Vanish cap, press (A) after a Midair Spin or during an Air Spin to perform or extend an Air Spin
    if (m.flags & MARIO_VANISH_CAP) ~= 0 and (m.prevAction == ACT_OMM_MIDAIR_SPIN or m.action == ACT_OMM_SPIN_AIR) and (m.controller.buttonPressed & A_BUTTON) ~= 0 then
        g.spinNumHitCheckpoints = OMM_MARIO_SPIN_MIN_HIT_CHECKPOINTS
    end

    -- If we successfully hit OMM_MARIO_SPIN_MIN_HIT_CHECKPOINTS checkpoints in a row, Mario can start spinning
    if g.spinNumHitCheckpoints == OMM_MARIO_SPIN_MIN_HIT_CHECKPOINTS then
        g.spinTimer = OMM_MARIO_SPIN_DURATION
        g.spinBufferTimer = 0
    end

    -- Update spin buffer timer
    if g.spinBufferTimer == 0 then
        g.spinNumHitCheckpoints = 0
        g.spinCheckpoint = -1
        g.spinDirection = 0
    else
        g.spinBufferTimer = g.spinBufferTimer - 1
    end
end

------------
-- Camera --
------------

function omm_mario_update_camera(m)
    if is_local_player(m) and m.action ~= ACT_FLYING and m.action ~= ACT_SHOT_FROM_CANNON and m.area and m.area.camera and m.area.camera.mode ~= CAMERA_MODE_NEWCAM then
        local mode = m.area.camera.mode
        local group = (m.action & ACT_GROUP_MASK)
        
        -- Return to default camera when leaving water
        if (mode == CAMERA_MODE_WATER_SURFACE or mode == CAMERA_MODE_BEHIND_MARIO) and group ~= ACT_GROUP_SUBMERGED then
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
        end
        
        -- Set close camera if underwater with Metal Mario
        if (mode == CAMERA_MODE_WATER_SURFACE or mode == CAMERA_MODE_BEHIND_MARIO) and (m.flags & MARIO_METAL_CAP) ~= 0 then
            set_camera_mode(m.area.camera, CAMERA_MODE_CLOSE, 0)
        end
        
        -- Return to default camera when leaving water with Metal Mario
        if mode == CAMERA_MODE_CLOSE and (m.flags & MARIO_METAL_CAP) ~= 0 then
            set_camera_mode(m.area.camera, m.area.camera.defMode, 0)
        end
    end
end

-------------
-- Physics --
-------------

function omm_mario_update_physics(m)
    local g = omm_mario_get(m)
    if m.action == ACT_OMM_WALL_SLIDE then m.vel.y = clamp(m.vel.y + 2.0, -32, 20) end
    if m.action == ACT_OMM_SPIN_JUMP then m.vel.y = clamp(m.vel.y + 2.5, -20, 100) end
    if m.action == ACT_OMM_SPIN_AIR then m.vel.y = clamp(m.vel.y + 2.5, -20, 100) end
    if m.action == ACT_OMM_MIDAIR_SPIN then m.vel.y = clamp(m.vel.y + (4.0 - clamp((g.midairSpinCounter - 1) * 0.8, 0.01, 4.0)), -60, 0) end
end

---------
-- QoL --
---------

function omm_mario_update_qol(m)

    -- No game over
    m.numLives = max(m.numLives, 1)

    -- No fall damage
    m.peakHeight = m.pos.y

    -- Give 30 invincibility frames after a burn
    if m.health > 0xFF and (m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP or m.action == ACT_BURNING_FALL) then
        m.invincTimer = 30
        m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & (~(1 << 4))
    end

    -- Restore health after collecting a star
    if m.action == ACT_STAR_DANCE_EXIT or m.action == ACT_STAR_DANCE_NO_EXIT or m.action == ACT_STAR_DANCE_WATER then
        m.healCounter = 1
        m.hurtCounter = 0
    end

    -- Fix MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN
    if m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN and m.action ~= ACT_JUMBO_STAR_CUTSCENE then
        m.marioObj.header.gfx.pos.y = m.pos.y + 60
    end
end

-----------
-- Sound --
-----------

function omm_mario_update_sound(m)
    local g = omm_mario_get(m)
    if g.soundPlayed == 0 then
        local actionSounds = {
            [ACT_FLYING]                      = { isCharSound = true,  sound = CHAR_SOUND_YAHOO_WAHA_YIPPEE, offset = 2 + (m.marioObj.oTimer % 3) },
            [ACT_JUMP_KICK]                   = { isCharSound = true,  sound = CHAR_SOUND_PUNCH_HOO,         offset = 0 },
            [ACT_GROUND_POUND]                = { isCharSound = false, sound = OMM_SOUND_ACTION_SPIN,        offset = 0 },
            [ACT_OMM_SPIN_JUMP]               = { isCharSound = true,  sound = CHAR_SOUND_YAHOO_WAHA_YIPPEE, offset = 2 + (m.marioObj.oTimer % 3) },
            [ACT_OMM_MIDAIR_SPIN]             = { isCharSound = false, sound = OMM_SOUND_ACTION_TWIRL,       offset = 0 },
            [ACT_OMM_GROUND_POUND_JUMP]       = { isCharSound = true,  sound = CHAR_SOUND_YAHOO,             offset = 0 },
            [ACT_OMM_WATER_GROUND_POUND]      = { isCharSound = false, sound = OMM_SOUND_ACTION_SPIN,        offset = 0 },
            [ACT_OMM_WATER_GROUND_POUND_JUMP] = { isCharSound = false, sound = OMM_SOUND_ACTION_SPIN,        offset = 0 },
        }
        actionSound = actionSounds[m.action]
        if actionSound ~= nil then
            if actionSound.isCharSound then
                play_character_sound_offset(m, actionSound.sound, actionSound.offset << 16)
            else
                play_sound(actionSound.sound + (actionSound.offset << 16), m.marioObj.header.gfx.cameraToObject)
            end
            g.soundPlayed = 1
        end
    end
end

----------
-- Main --
----------

function omm_mario_main(m)
    if gNetworkPlayers[m.playerIndex].connected then
        omm_mario_update_data(m)
        omm_mario_update_handling(m)
        omm_mario_update_spin(m)
        omm_mario_update_camera(m)
        omm_mario_update_physics(m)
        omm_mario_update_qol(m)
        omm_mario_update_sound(m)
    end
end

hook_event(HOOK_MARIO_UPDATE, omm_mario_main)
