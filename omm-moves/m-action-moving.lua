----------
-- Init --
----------

function omm_act_walking_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_decelerating_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_crawling_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_roll_init(m)
    if m.prevAction == ACT_GROUND_POUND_LAND or (m.prevAction == ACT_OMM_ROLL and m.forwardVel >= 45) then
        omm_mario_init_action(m, max(m.forwardVel, 75), 0, PARTICLE_HORIZONTAL_STAR)
    else
        omm_mario_init_action(m, max(m.forwardVel, 60), 0, PARTICLE_MIST_CIRCLE)
    end
    if m.prevAction ~= ACT_OMM_ROLL then m.faceAngle.x = 0 end
end

------------
-- Cancel --
------------

function omm_act_walking_cancel(m)
    if omm_action_za_pressed(m, m.forwardVel > 8.0, ACT_LONG_JUMP, 0) then return end
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_turning_around_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_finish_turning_around_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_braking_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_decelerating_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_MOVE_PUNCHING, 0) then return end
    if omm_action_spin_ground(m, 1) then return end
end

function omm_act_crouch_slide_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_jump_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_freefall_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_double_jump_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_side_flip_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_triple_jump_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_backflip_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_quicksand_jump_land_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

function omm_act_long_jump_land_cancel(m)
    if omm_action_condition(m, omm_mario_is_roll_landing(m), ACT_OMM_ROLL, 0) then return end
end

function omm_act_dive_slide_cancel(m)
    if omm_action_condition(m, omm_mario_is_roll_landing(m), ACT_OMM_ROLL, 0) then return end
end

function omm_act_burning_ground_cancel(m)
    if omm_action_condition(m, m.marioObj.oMarioBurnTimer > 160, ACT_WALKING, 0) then return end
end

function omm_act_move_punching_cancel(m)
    if omm_action_zb_pressed(m, 1, ACT_OMM_ROLL, 0) then return end
end

------------
-- Update --
------------

function omm_act_roll(m)
    if omm_action_a_pressed(m, 1, ACT_LONG_JUMP, 0) then return 1 end
    if omm_action_b_pressed(m, m.actionTimer >= 6, ACT_OMM_ROLL, 0) then return 1 end
    m.actionTimer = m.actionTimer + 1
    
    -- Speed
    local floorClass = mario_get_floor_class(m)
    local isFloorFlat = (floorClass == 0x0015 or (floorClass ~= 0x0014 and floorClass ~= 0x0013 and m.floor.normal.y > 0.94))
    if isFloorFlat then

        -- Mario slowly decelerates on flat ground
        -- Decelerates even slower if Z is held
        local decelMult = if_then_else((m.controller.buttonDown & Z_TRIG) ~= 0, 0.25, 1.0)
        mario_set_forward_vel(m, max(0, m.forwardVel - OMM_MARIO_ROLL_DECEL * decelMult))
        m.faceAngle.y = s16(m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, OMM_MARIO_ROLL_YAW_VEL, OMM_MARIO_ROLL_YAW_VEL))
    else

        -- Mario accelerates if he's facing away the slope
        -- If not, hold Z to decelerate slower
        local dir = sins(m.faceAngle.y) * m.floor.normal.x + coss(m.faceAngle.y) * m.floor.normal.z
        local sign = if_then_else(dir > 0, 1, -1)
        local delta = clamp(1.0 - m.floor.normal.y, 0.0, 1.0)
        local decelMult = if_then_else((m.controller.buttonDown & Z_TRIG) ~= 0 and sign == -1, 0.25, 1.0)
        mario_set_forward_vel(m, clamp(m.forwardVel + sign * OMM_MARIO_ROLL_DECEL * decelMult * (1.0 + 2.0 * delta), 0.0, OMM_MARIO_ROLL_MAX_SPEED))

        -- Progressively turn Mario in the direction of the slope...
        if m.floor.normal.z ~= 0 or m.floor.normal.x ~= 0 then
            local floorAngle = atan2s(m.floor.normal.z, m.floor.normal.x)
            local floorMult = if_then_else(sign == -1, 5.0, 1.0)
            local floorHandling = OMM_MARIO_ROLL_YAW_VEL * (0.75 + delta * floorMult)
            m.faceAngle.y = s16(floorAngle - approach_s32(s16(floorAngle - m.faceAngle.y), 0, floorHandling, floorHandling))
        end
        
        -- ...but this rotation can be partially canceled with the control stick
        if (m.input & INPUT_NONZERO_ANALOG) ~= 0 then
            local stickMult = 1.0 + 0.25 * (m.forwardVel / OMM_MARIO_ROLL_MAX_SPEED)
            local stickHandling = OMM_MARIO_ROLL_YAW_VEL * stickMult
            m.faceAngle.y = s16(m.intendedYaw - approach_s32(s16(m.intendedYaw - m.faceAngle.y), 0, stickHandling, stickHandling))
        end
    end
    
    -- Stop if Mario isn't fast enough
    if omm_action_condition(m, m.forwardVel <= OMM_MARIO_ROLL_MIN_SPEED and isFloorFlat == true, ACT_WALKING, 0) then return 1 end
    if omm_action_condition(m, m.forwardVel <= OMM_MARIO_ROLL_MIN_SPEED and isFloorFlat == false, ACT_STOMACH_SLIDE, 0) then return 1 end

    -- Perform step
    local step = perform_ground_step(m)
    if omm_action_condition(m, step == GROUND_STEP_LEFT_GROUND, ACT_OMM_ROLL_AIR, 0) then return 0 end
    if omm_action_condition(m, step == GROUND_STEP_HIT_WALL, ACT_BACKWARD_GROUND_KB, 0) then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        return 0
    end
    
    -- Animation
    omm_mario_update_roll_anim(m)
    m.particleFlags = m.particleFlags | PARTICLE_DUST
    return 0
end
