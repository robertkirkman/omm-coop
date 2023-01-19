function omm_mario_init_action(m, forwardVel, upwardsVel, particles, charSound)
    mario_set_forward_vel(m, forwardVel)
    m.vel.y = upwardsVel
    m.particleFlags = m.particleFlags | particles
end

function omm_mario_set_action(m, action, actionArg, buttons)

    -- Set action and remove buttons pressed
    if (action ~= 0) then set_mario_action(m, action, actionArg) end
    if (buttons & A_BUTTON) then m.input = m.input & (~(INPUT_A_PRESSED)) end
    if (buttons & B_BUTTON) then m.input = m.input & (~(INPUT_B_PRESSED)) end
    if (buttons & Z_TRIG  ) then m.input = m.input & (~(INPUT_Z_PRESSED)) end
    m.controller.buttonPressed = m.controller.buttonPressed & (~(buttons))
    
    -- Set Mario's facing direction
    if ((m.controller.stickMag > 32) and (
        (m.action == ACT_OMM_CAPPY_THROW_GROUND) or
        (m.action == ACT_OMM_CAPPY_THROW_AIRBORNE))) then
        m.faceAngle.y = m.intendedYaw
    end

    -- Update Mario's graphics
    if ((m.action ~= ACT_SWIMMING_END) and
        (m.action ~= ACT_OMM_CAPPY_THROW_WATER) and
        (m.action ~= ACT_FLYING)) then
        m.faceAngle.x = 0
        m.faceAngle.z = 0
        m.marioObj.header.gfx.angle.x = 0
        m.marioObj.header.gfx.angle.y = m.faceAngle.y
        m.marioObj.header.gfx.angle.z = 0
    end
end

function __action_buttons_pressed(buttons, m, condition, nextAction, actionArg)
    if (m.controller.buttonPressed & buttons) ~= 0 and condition then
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

function omm_action_condition(m, condition, nextAction, actionArg)
    return __action_condition(m, condition, nextAction, actionArg)
end
