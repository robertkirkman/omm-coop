function omm_mario_init_action(m, forwardVel, upwardsVel, particles, charSound)
    mario_set_forward_vel(m, forwardVel)
    m.vel.y = upwardsVel
    m.particleFlags = m.particleFlags | particles
end

function omm_mario_set_action(m, action, actionArg, buttons)
    local g = omm_mario_get(m)

    -- Set action and remove buttons pressed
    if (action ~= 0) then set_mario_action(m, action, actionArg) end
    if (buttons & A_BUTTON) then m.input = m.input & (~(INPUT_A_PRESSED)) end
    if (buttons & B_BUTTON) then m.input = m.input & (~(INPUT_B_PRESSED)) end
    if (buttons & Z_TRIG  ) then m.input = m.input & (~(INPUT_Z_PRESSED)) end
    m.controller.buttonPressed = m.controller.buttonPressed & (~(buttons))
    
    -- Set Mario's facing direction
    if ((m.controller.stickMag > 32) and (
        (m.action == ACT_OMM_GROUND_POUND_JUMP) or
        (m.action == ACT_OMM_SPIN_JUMP) or
        (m.action == ACT_DIVE and m.prevAction == ACT_GROUND_POUND) or
        (m.action == ACT_OMM_ROLL and (m.prevAction ~= ACT_OMM_ROLL and m.prevAction ~= ACT_OMM_ROLL_AIR)))) then
        m.faceAngle.y = m.intendedYaw
    end

    -- Update Mario's graphics
    if ((m.action ~= ACT_SWIMMING_END) and
        (m.action ~= ACT_OMM_ROLL) and
        (m.action ~= ACT_OMM_ROLL_AIR) and
        (m.action ~= ACT_OMM_WATER_GROUND_POUND) and
        (m.action ~= ACT_OMM_WATER_DASH) and
        (m.action ~= ACT_FLYING)) then
        m.faceAngle.x = 0
        m.faceAngle.z = 0
        m.marioObj.header.gfx.angle.x = 0
        m.marioObj.header.gfx.angle.y = m.faceAngle.y
        m.marioObj.header.gfx.angle.z = 0
    end

    -- Reset spin
    g.spinYaw = 0
    g.spinTimer = 0
end

function __action_buttons_pressed(buttons, m, condition, nextAction, actionArg)
    if (m.controller.buttonPressed & buttons) ~= 0 and condition then
        omm_mario_set_action(m, nextAction, actionArg, buttons)
        return true
    end
    return false
end

function __action_buttons_down(buttons, m, condition, nextAction, actionArg)
    if (m.controller.buttonDown & buttons) ~= 0 and condition then
        omm_mario_set_action(m, nextAction, actionArg, buttons)
        return true
    end
    return false
end

function __action_condition(m, condition, nextAction, actionArg)
    if condition then
        omm_mario_set_action(m, nextAction, actionArg, 0)
        return true
    end
    return false
end

function omm_action_a_pressed(m, condition, nextAction, actionArg)
    return __action_buttons_pressed(A_BUTTON, m, condition, nextAction, actionArg)
end

function omm_action_b_pressed(m, condition, nextAction, actionArg)
    return __action_buttons_pressed(B_BUTTON, m, condition, nextAction, actionArg)
end

function omm_action_z_pressed(m, condition, nextAction, actionArg)
    return __action_buttons_pressed(Z_TRIG, m, condition, nextAction, actionArg)
end

function omm_action_za_pressed(m, condition, nextAction, actionArg)
    return __action_buttons_pressed(A_BUTTON, m, condition and (m.controller.buttonDown & Z_TRIG) ~= 0, nextAction, actionArg)
end

function omm_action_zb_pressed(m, condition, nextAction, actionArg)
    return __action_buttons_pressed(B_BUTTON, m, condition and (m.controller.buttonDown & Z_TRIG) ~= 0, nextAction, actionArg)
end

function omm_action_condition(m, condition, nextAction, actionArg)
    return __action_condition(m, condition, nextAction, actionArg)
end

function omm_action_spin_ground(m, condition)
    local g = omm_mario_get(m)
    return __action_condition(m, condition and g.spinTimer > 0, ACT_OMM_SPIN_GROUND, 0)
end

function omm_action_spin_air(m, condition)
    local g = omm_mario_get(m)
    return __action_condition(m, condition and g.spinTimer > 0 and m.vel.y <= 12, ACT_OMM_SPIN_AIR, 0)
end

function omm_action_midair_spin(m, condition)
    local g = omm_mario_get(m)
    return __action_condition(m, condition and (m.controller.buttonPressed & A_BUTTON) ~= 0 and m.vel.y < 0 and g.midairSpinTimer == 0, ACT_OMM_MIDAIR_SPIN, 0)
end

function omm_action_off_floor(m, condition, nextAction, actionArg)
    return __action_condition(m, condition and (m.input & INPUT_OFF_FLOOR) ~= 0, nextAction, actionArg)
end

function omm_get_initial_upwards_velocity(m, vel)
    local g = omm_mario_get(m)
    local airActions = {
        [ACT_DIVE]            = { -1, 0 },
        [ACT_JUMP_KICK]       = {  1, 1 },
        [ACT_OMM_SPIN_AIR]    = {  1, 1 },
        [ACT_OMM_MIDAIR_SPIN] = {  0, 1 },
    }
    if airActions[m.action] ~= nil then
        g.airCombo = g.airCombo + airActions[m.action][1]
        if airActions[m.action][2] == 1 then vel = vel * clamp(1.0 - ((g.airCombo - 5) / 5.0), 0.0, 1.0) end
        return vel
    end
    g.airCombo = 0
    return vel
end

function omm_wall_slide_get_jump_angle(m)
    local wAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
    if m.controller.stickMag > 32 then
        local dAngle = s16(clamp(s16(m.intendedYaw - wAngle), -OMM_MARIO_WALL_SLIDE_JUMP_ANGLE_MAX, OMM_MARIO_WALL_SLIDE_JUMP_ANGLE_MAX))
        return s16(wAngle + dAngle)
    end
    return wAngle
end

function omm_wall_slide_cancel(m, forwardVel, upwardsVel, jump)
    local g = omm_mario_get(m)
    if jump then
        m.faceAngle.y = omm_wall_slide_get_jump_angle(m)
    else
        m.faceAngle.y = -atan2s(m.wall.normal.z, m.wall.normal.x)
    end
    mario_set_forward_vel(m, forwardVel)
    m.vel.y = omm_get_initial_upwards_velocity(m, upwardsVel)
    g.wallSlideHeight = m.pos.y - 200
    g.wallSlideJumped = true
    g.midairSpinCounter = 0
    return 1
end

function omm_mario_check_wall_slide(m)
    return (
        (m.action ~= ACT_DIVE) and
        (m.action ~= ACT_LONG_JUMP) and
        (m.heldObj == nil) and
        (m.wall ~= nil) and
        (m.wall.type < 0x00A6)
    )
end

function omm_mario_is_roll_landing(m)
    return (m.controller.buttonDown & Z_TRIG) ~= 0 and m.forwardVel >= OMM_MARIO_ROLL_MIN_SPEED
end

function omm_mario_update_roll_anim(m)
    local prevPitch = m.faceAngle.x
    local pitchSpeed = (0x1C00 * m.forwardVel) / 60.0
    m.faceAngle.x = s16(m.faceAngle.x + pitchSpeed)
    m.marioObj.header.gfx.angle.x = 0
    if prevPitch > m.faceAngle.x then play_sound(OMM_SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject) end
    set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING)
    set_anim_to_frame(m, (m.marioObj.header.gfx.animInfo.curAnim.loopEnd * u16(m.faceAngle.x)) / 0x10000)
end

function omm_mario_water_stationary_slow_down(m, slowModifier)
    m.angleVel.x = 0
    m.angleVel.y = 0
    m.faceAngle.x = approach_s32(m.faceAngle.x, 0, 0x200, 0x200)
    m.faceAngle.z = approach_s32(m.faceAngle.z, 0, 0x100, 0x100)
    m.forwardVel = approach_f32(m.forwardVel, 0, slowModifier, slowModifier)
    m.vel.x = m.forwardVel * coss(m.faceAngle.x) * sins(m.faceAngle.y)
    m.vel.z = m.forwardVel * coss(m.faceAngle.x) * coss(m.faceAngle.y)
    m.vel.y = approach_f32(m.vel.y, 0, 2 * slowModifier, slowModifier)
end
