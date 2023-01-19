----------
-- Init --
----------

function omm_act_cappy_throw_water_init(m)
    omm_mario_init_action(m, m.forwardVel, m.vel.y, 0)
    mario_anim_reset(m)
end

------------
-- Cancel --
------------

------------
-- Update --
------------

function omm_act_cappy_throw_water(m)
    if omm_action_condition(m, (m.flags & MARIO_METAL_CAP) ~= 0, ACT_METAL_WATER_FALLING, 0) then return 1 end
    if omm_action_a_pressed(m, 1, ACT_BREASTSTROKE, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_WATER_PUNCH, 0) then return 1 end

    mario_set_forward_vel(m, m.forwardVel * 0.8)
    perform_water_step(m)
    if omm_action_condition(m, omm_mario_update_throw_anim(m), ACT_WATER_ACTION_END, 0) then return 0 end
    return 0
end
