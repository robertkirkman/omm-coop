----------
-- Init --
----------

function omm_act_cappy_throw_ground_init(m)
    omm_mario_init_action(m, m.forwardVel, 0, 0)
    mario_anim_reset(m)
end

------------
-- Cancel --
------------

------------
-- Update --
------------

function omm_act_cappy_throw_ground(m)
    if omm_action_a_pressed(m, 1, ACT_JUMP, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return 1 end
    if omm_action_z_pressed(m, 1, ACT_CROUCH_SLIDE, 0) then return 1 end

    local f = (coss(abs(m.faceAngle.y - m.intendedYaw)) * m.controller.stickMag) / 64
    mario_set_forward_vel(m, m.forwardVel * clamp(f, 0.80, 0.98))

    local step = perform_ground_step(m)
    if omm_action_condition(m, step == GROUND_STEP_LEFT_GROUND, ACT_FREEFALL, 0) then return 0 end
    if omm_action_condition(m, step == GROUND_STEP_HIT_WALL, ACT_IDLE, 0) then return 0 end
    if omm_action_condition(m, omm_mario_update_throw_anim(m), ACT_WALKING, 0) then return 0 end
    return 0
end

