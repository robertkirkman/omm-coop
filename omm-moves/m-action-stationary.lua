----------
-- Init --
----------

function omm_act_debug_free_move_init(m)
    m.health = 0xFF
    omm_mario_set_action(m, ACT_SHOCKED, 0, 0)
end

function omm_act_ground_pound_land_init(m)
    omm_mario_init_action(m, 0, 0, 0)
end

function omm_act_spin_ground_init(m)
    omm_mario_init_action(m, m.forwardVel, 0, 0)
end

------------
-- Cancel --
------------

function omm_act_idle_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_panting_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_coughing_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_shivering_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_standing_against_wall_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_in_quicksand_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_PUNCHING, 0) then return end
end

function omm_act_crouching_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_crawling_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_braking_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_jump_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_double_jump_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_side_flip_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_freefall_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_triple_jump_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_backflip_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_long_jump_land_stop_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

------------
-- Update --
------------

-- OVERRIDE
-- m.actionArg == 0 -> Ground pound land
-- m.actionArg == 2 -> Spin pound land
function omm_act_ground_pound_land(m)
    if omm_action_a_pressed(m, 1, ACT_OMM_GROUND_POUND_JUMP, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_OMM_ROLL, 0) then return 1 end
    if omm_action_spin_ground(m, 1) then return 1 end
    if omm_action_off_floor(m, 1, ACT_FREEFALL, 0) then return 1 end
    if omm_action_condition(m, (m.input & INPUT_UNKNOWN_10) ~= 0, ACT_SHOCKWAVE_BOUNCE, 0) then return 1 end
    if omm_action_condition(m, (m.input & INPUT_ABOVE_SLIDE) ~= 0, ACT_BUTT_SLIDE, 0) then return 1 end
    
    if m.actionArg == 2 then
        landing_step(m, MARIO_ANIM_GENERAL_LAND, ACT_IDLE)
    else
        landing_step(m, MARIO_ANIM_GROUND_POUND_LANDING, ACT_BUTT_SLIDE_STOP)
    end
    return 0
end

function omm_act_spin_ground(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return 1 end
    if omm_action_a_pressed(m, 1, ACT_OMM_SPIN_JUMP, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return 1 end
    if omm_action_off_floor(m, 1, ACT_OMM_SPIN_AIR, 0) then return 1 end
    if omm_action_condition(m, m.actionTimer >= OMM_MARIO_SPIN_DURATION, ACT_IDLE, 0) then return 1 end

    local step = perform_ground_step(m)
    if omm_action_condition(m, step == GROUND_STEP_LEFT_GROUND, ACT_OMM_SPIN_AIR, 0) then return 0 end

    mario_set_forward_vel(m, max(0, m.forwardVel - 1.0))
    set_mario_animation(m, MARIO_ANIM_TWIRL)
    play_sound(OMM_SOUND_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    
    local g = omm_mario_get(m)
    g.spinYaw = s16(g.spinYaw + min(0x31E9, 0x280 * (OMM_MARIO_SPIN_DURATION - m.actionTimer)))
    m.marioObj.header.gfx.angle.y = s16(m.faceAngle.y - g.spinYaw)
    m.marioBodyState.handState = MARIO_HAND_OPEN
    m.particleFlags = m.particleFlags | PARTICLE_DUST
    m.actionTimer = if_then_else(g.spinTimer > 0, 0, m.actionTimer + 1)
    return 0
end
