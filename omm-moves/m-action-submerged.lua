----------
-- Init --
----------

function omm_act_water_ground_pound_land_init(m)
    omm_mario_init_action(m, 0, 0, 0)
end

function omm_act_water_ground_pound_init(m)
    omm_mario_init_action(m, 0, 0, 0)
end

function omm_act_water_ground_pound_jump_init(m)
    omm_mario_init_action(m, 0, 48, 0)
end

------------
-- Cancel --
------------

function omm_act_water_idle_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return end
end

function omm_act_water_action_end_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return end
end

function omm_act_breaststroke_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return end
end

function omm_act_swimming_end_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return end
end

function omm_act_flutter_kick_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return end
end

------------
-- Update --
------------

function omm_act_water_ground_pound(m)
    if omm_action_condition(m, (m.flags & MARIO_METAL_CAP) ~= 0, ACT_METAL_WATER_FALLING, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return 1 end

    m.faceAngle.x = 0
    m.faceAngle.z = 0
    m.marioObj.header.gfx.angle.x = 0
    m.marioObj.header.gfx.angle.y = m.faceAngle.y
    m.marioObj.header.gfx.angle.z = 0
    if m.actionState == 0 then
        set_mario_anim_with_accel(m, MARIO_ANIM_START_GROUND_POUND, 0x14000)
        if m.actionTimer < 10 then
            local yOffset = 20 - 2 * m.actionTimer
            if m.pos.y + yOffset + 160 < m.ceilHeight then
                m.pos.y = m.pos.y + yOffset
                vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
            end
        end
        m.actionTimer = m.actionTimer + 1
        if m.actionTimer >= 12 then
            play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
            play_sound(OMM_SOUND_ACTION_WATER_GP, m.marioObj.header.gfx.cameraToObject)
            m.vel.y = -105
            m.actionState = 1
        end
    else
        set_mario_animation(m, MARIO_ANIM_GROUND_POUND)
        m.particleFlags = m.particleFlags | PARTICLE_PLUNGE_BUBBLE | PARTICLE_BUBBLE
        m.vel.y = m.vel.y + 5
        local step = perform_water_step(m)
        if omm_action_condition(m, m.vel.y >= 0, ACT_WATER_IDLE, 0) then return 0 end
        if omm_action_condition(m, step == WATER_STEP_HIT_FLOOR, ACT_OMM_WATER_GROUND_POUND_LAND, 0) then
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
            return 0
        end
        m.health = m.health - 2
    end
    return 0
end

function omm_act_water_ground_pound_land(m)
    if omm_action_condition(m, m.pos.y >= m.waterLevel - 80, ACT_WATER_JUMP, 0) then return 1 end
    if omm_action_condition(m, (m.flags & MARIO_METAL_CAP) ~= 0, ACT_METAL_WATER_FALL_LAND, 0) then return 1 end

    stationary_ground_step(m)
    if m.actionState == 0 then
        set_mario_anim_with_accel(m, MARIO_ANIM_GROUND_POUND_LANDING, 0xC000)
        if omm_action_a_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND_JUMP, 0) then return 0 end
        if m.actionTimer >= 6 then
            m.actionState = 1
            m.actionTimer = 0
        end
    else
        set_mario_animation(m, MARIO_ANIM_STOP_SLIDE)        
        if omm_action_condition(m, m.actionTimer >= 18, ACT_WATER_IDLE, 0) then return 0 end
    end
    m.actionTimer = m.actionTimer + 1
    return 0
end

function omm_act_water_ground_pound_jump(m)
    if omm_action_condition(m, m.pos.y >= m.waterLevel - 80, ACT_WATER_JUMP, 0) then return 1 end
    if omm_action_condition(m, m.vel.y <= 0, ACT_WATER_IDLE, 0) then return 1 end
    if omm_action_condition(m, (m.flags & MARIO_METAL_CAP) ~= 0, ACT_METAL_WATER_FALLING, 0) then return 1 end
    if omm_action_z_pressed(m, 1, ACT_OMM_WATER_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_OMM_WATER_DASH, 0) then return 1 end

    omm_mario_water_stationary_slow_down(m, 2)
    perform_water_step(m)

    set_mario_animation(m, MARIO_ANIM_DOUBLE_JUMP_RISE)
    local g = omm_mario_get(m)
    if m.actionTimer == 0 or (g.spinYaw ~= 0 and g.spinYaw < 65536) then
        g.spinYaw = min(g.spinYaw + (0x90 * m.vel.y), 65536)
        m.actionTimer = 1
    else
        g.spinYaw = 0
    end
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + g.spinYaw
    m.particleFlags = m.particleFlags | PARTICLE_PLUNGE_BUBBLE | PARTICLE_BUBBLE
    return 0
end

function omm_act_water_dash(m)
    if omm_action_condition(m, (m.flags & MARIO_METAL_CAP) ~= 0, ACT_METAL_WATER_FALLING, 0) then return 1 end
    if omm_action_condition(m, (m.controller.buttonDown & B_BUTTON) == 0, ACT_SWIMMING_END, 0) then return 1 end

    local targetPitch = s16(-250 * m.controller.stickY)
    local yawVel = s16(0x200 * abs(m.controller.stickX / 64))
    m.forwardVel = 60
    m.vel.x = m.forwardVel * coss(m.faceAngle.x) * sins(m.faceAngle.y)
    m.vel.y = m.forwardVel * sins(m.faceAngle.x)
    m.vel.z = m.forwardVel * coss(m.faceAngle.x) * coss(m.faceAngle.y)
    m.faceAngle.x = s16(targetPitch - approach_s32(s16(targetPitch - m.faceAngle.x), 0, 0x200, 0x200))
    m.faceAngle.y = s16(m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, yawVel, yawVel))
    m.faceAngle.z = s16(m.controller.stickX * 64)
    
    local step = perform_water_step(m)
    if omm_action_condition(m, step == WATER_STEP_HIT_WALL, ACT_BACKWARD_WATER_KB, 0) then
        play_character_sound(m, CHAR_SOUND_OOOF2)
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        return 0
    end
    
    set_mario_anim_with_accel(m, MARIO_ANIM_FLUTTERKICK, 0x30000)
    m.marioBodyState.headAngle.x = s16(approach_s32(m.marioBodyState.headAngle.x, 0, 0x200, 0x200))
    m.particleFlags = m.particleFlags | PARTICLE_PLUNGE_BUBBLE | PARTICLE_BUBBLE
    m.actionTimer = ((m.actionTimer + 1) & 3)
    if m.actionTimer == 0 then
        play_sound(OMM_SOUND_ACTION_WATER_DASH, m.marioObj.header.gfx.cameraToObject)
    end
    m.health = m.health - 4
    return 0
end
