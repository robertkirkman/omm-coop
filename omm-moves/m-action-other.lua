----------
-- Init --
----------

------------
-- Cancel --
------------

function omm_act_punching_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_start_hanging_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_FREEFALL, 0) then return end
    set_mario_anim_with_accel(m, m.marioObj.header.gfx.animInfo.animID, 0x20000)
    m.input = m.input | INPUT_A_DOWN
    m.controller.buttonDown = m.controller.buttonDown | A_BUTTON
end

function omm_act_hanging_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_FREEFALL, 0) then return end
    m.input = m.input | INPUT_A_DOWN
    m.controller.buttonDown = m.controller.buttonDown | A_BUTTON
end

function omm_act_hang_moving_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_FREEFALL, 0) then return end
    set_mario_anim_with_accel(m, m.marioObj.header.gfx.animInfo.animID, 0x20000)
    update_hang_moving(m)
    m.input = m.input | INPUT_A_DOWN
    m.controller.buttonDown = m.controller.buttonDown | A_BUTTON
end

function omm_act_holding_pole_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_FREEFALL, 0) then
        mario_set_forward_vel(m, -10)
    end
end

function omm_act_climbing_pole_cancel(m)
    if (m.controller.buttonDown & B_BUTTON) ~= 0 then
        m.controller.stickY = m.controller.stickY * 2
    end
end

------------
-- Update --
------------
