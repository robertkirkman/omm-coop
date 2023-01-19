----------
-- Init --
----------

function omm_act_jump_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_double_jump_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_triple_jump_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_flying_triple_jump_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_special_triple_jump_init(m)
    omm_mario_set_action(m, ACT_TRIPLE_JUMP, 0, B_BUTTON)
end

function omm_act_freefall_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_side_flip_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_wall_kick_air_init(m)
    omm_mario_set_action(m, 0, 0, B_BUTTON)
end

function omm_act_steep_jump_init(m)
    omm_mario_set_action(m, ACT_JUMP, 0, B_BUTTON)
end

function omm_act_flying_init(m)
    local g = omm_mario_get(m)
    if m.prevAction == ACT_JUMP_KICK then
        omm_mario_init_action(m, max(m.forwardVel, 60), 0, 0)
    end
    g.soundPlayed = 1
end

function omm_act_dive_init(m)
    omm_mario_init_action(m, 32, omm_get_initial_upwards_velocity(m, 40), PARTICLE_MIST_CIRCLE)
    vec3s_set(m.faceAngle, 0, m.faceAngle.y, 0)
end

function omm_act_ground_pound_init(m)
    omm_mario_init_action(m, 0, -50, 0)
end

function omm_act_air_hit_wall_init(m)
    local g = omm_mario_get(m)
    if omm_mario_check_wall_slide(m) then
        local wallAngle = atan2s(m.wall.normal.z, m.wall.normal.x)
        local wallHeight = m.pos.y
        if g.wallSlideJumped then
            local diffAngle = u16(abs(wallAngle - g.wallSlideAngle))
            local diffHeight = wallHeight - g.wallSlideHeight
            if diffAngle < 0x2000 and diffHeight > 0 then return end
        end
        g.wallSlideAngle = wallAngle
        g.wallSlideHeight = wallHeight
        omm_mario_set_action(m, ACT_OMM_WALL_SLIDE, 0, 0)
    end
end

function omm_act_ground_pound_jump_init(m)
    omm_mario_init_action(m, 0, 66, 0)
end

function omm_act_spin_air_init(m)
    omm_mario_init_action(m, m.forwardVel, omm_get_initial_upwards_velocity(m, 12), 0)
end

function omm_act_spin_jump_init(m)
    omm_mario_init_action(m, m.forwardVel, 45, 0)
end

function omm_act_midair_spin_init(m)
    local g = omm_mario_get(m)
    omm_mario_init_action(m, m.forwardVel, omm_get_initial_upwards_velocity(m, 0), 0)
    m.actionTimer = 0
    g.midairSpinTimer = 24
    g.midairSpinCounter = g.midairSpinCounter + 1
end

------------
-- Cancel --
------------

function omm_act_jump_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_double_jump_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_flying_triple_jump_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, 0, 0) then return end
end

function omm_act_backflip_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_long_jump_cancel(m)
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_freefall_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_side_flip_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_wall_kick_air_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_water_jump_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_burning_jump_cancel(m)
    if omm_action_condition(m, m.marioObj.oMarioBurnTimer > 160, ACT_FREEFALL, 0) then return end
end

function omm_act_burning_fall_cancel(m)
    if omm_action_condition(m, m.marioObj.oMarioBurnTimer > 160, ACT_FREEFALL, 0) then return end
end

function omm_act_top_of_pole_jump_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return end
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_twirling_cancel(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 2) then return end
end

function omm_act_soft_bonk_cancel(m)
    if (m.prevAction == ACT_LEDGE_GRAB or
        m.prevAction == ACT_LEDGE_CLIMB_SLOW_1 or
        m.prevAction == ACT_LEDGE_CLIMB_SLOW_2 or
        m.prevAction == ACT_LEDGE_CLIMB_DOWN or
        m.prevAction == ACT_LEDGE_CLIMB_FAST) then
        omm_mario_set_action(m, ACT_FREEFALL, 0, 0)
    end
end

function omm_act_forward_rollout_cancel(m)
    m.actionTimer = m.actionTimer + 1
    if omm_action_condition(m, m.actionTimer > 15, ACT_FREEFALL, 0) then return end
end

function omm_act_backward_rollout_cancel(m)
    m.actionTimer = m.actionTimer + 1
    if omm_action_condition(m, m.actionTimer > 15, ACT_FREEFALL, 0) then return end
end

function omm_act_lava_boost_cancel(m)
    local g = omm_mario_get(m)
    g.airCombo = 0
end

function omm_act_getting_blown_cancel(m)
    m.actionTimer = 0
    m.actionArg = m.actionArg + 1
    if omm_action_condition(m, m.actionArg > 60, ACT_FREEFALL, 0) then return end
end

function omm_act_thrown_forward_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_thrown_backward_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_forward_air_kb_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_backward_air_kb_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_hard_forward_air_kb_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_hard_backward_air_kb_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_soft_bonk_cancel(m)
    if m.vel.y < 0 then m.actionTimer = m.actionTimer + 1 end
    if omm_action_condition(m, m.actionTimer > 30, ACT_FREEFALL, 0) then return end
end

function omm_act_cappy_bounce_cancel(m)
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

function omm_act_cappy_vault_cancel(m)
    if omm_action_midair_spin(m, 1) then return end
    if omm_action_spin_air(m, 1) then return end
end

------------
-- Update --
------------

-- OVERRIDE
-- m.actionArg == 0 -> Ground pound
-- m.actionArg == 1 -> Flying ground pound
-- m.actionArg == 2 -> Spin pound
function omm_act_ground_pound(m)
    if omm_action_b_pressed(m, 1, ACT_DIVE, 0) then return 1 end
    m.marioObj.header.gfx.angle.x = 0
    m.marioObj.header.gfx.angle.y = m.faceAngle.y
    m.marioObj.header.gfx.angle.z = 0
    
    mario_set_forward_vel(m, 0)
    if m.actionArg <= 1 and m.actionState == 0 then
        if m.actionTimer < 10 then
            local yOffset = 20 - 2 * m.actionTimer
            if m.pos.y + yOffset + 160 < m.ceilHeight then
                m.pos.y = m.pos.y + yOffset
                m.peakHeight = m.pos.y
                vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
            end
        end
        m.actionTimer = m.actionTimer + 1
        if m.actionTimer >= 15 then
            play_character_sound(m, CHAR_SOUND_GROUND_POUND_WAH)
            m.actionState = 1
        end
    else
        m.actionState = 1
        local step = perform_air_step(m, 0)
        if step == AIR_STEP_LANDED then
            omm_mario_set_action(m, ACT_GROUND_POUND_LAND, m.actionArg, 0)
            play_mario_heavy_landing_sound(m, OMM_SOUND_TERRAIN_HEAVY_LANDING)
            m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE | PARTICLE_HORIZONTAL_STAR
            if is_local_player(m) then set_camera_shake_from_hit(SHAKE_GROUND_POUND) end
            return 0
        end
    end
    
    if m.actionArg <= 1 then
        set_mario_animation(m,
            if_then_else(m.actionState == 0,
            if_then_else(m.actionArg == 0,
            MARIO_ANIM_START_GROUND_POUND,
            MARIO_ANIM_TRIPLE_JUMP_GROUND_POUND),
            MARIO_ANIM_GROUND_POUND)
        )
    else
        set_mario_animation(m, MARIO_ANIM_TWIRL)
        local g = omm_mario_get(m)
        local prevSpinYaw = g.spinYaw
        g.spinYaw = s16(g.spinYaw + 0x4000)
        if g.spinYaw < prevSpinYaw then play_sound(OMM_SOUND_ACTION_SIDE_FLIP, m.marioObj.header.gfx.cameraToObject) end
        m.marioObj.header.gfx.angle.y = s16(m.faceAngle.y - g.spinYaw)
        m.marioBodyState.handState = MARIO_HAND_OPEN
        m.particleFlags = m.particleFlags | PARTICLE_DUST
    end
    return 0
end

-- OVERRIDE
-- Needed to prevent the special triple jump from triggering
function omm_act_triple_jump(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    if omm_action_midair_spin(m, 1) then return 1 end
    if omm_action_spin_air(m, 1) then return 1 end

    local step = common_air_action_step(m, ACT_TRIPLE_JUMP_LAND, MARIO_ANIM_TRIPLE_JUMP, AIR_STEP_CHECK_LEDGE_GRAB)
    if omm_action_condition(m, step ~= AIR_STEP_NONE, 0, 0) then return 0 end

    play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, 0)
    play_flip_sounds(m, 2, 8, 20)
    return 0
end

-- OVERRIDE
-- m.actionArg == 0 -> Jump kick
-- m.actionArg == 1 -> Rainbow spin
function omm_act_jump_kick(m)
    if m.actionState == 0 then
        mario_set_forward_vel(m, m.forwardVel / (1.0 + m.actionArg))
        m.vel.y = omm_get_initial_upwards_velocity(m, (20.0 + 10.0 * m.actionArg))
        mario_anim_reset(m)
        m.actionTimer = 0
        m.actionState = 1
    end
    
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, (m.pos.y - m.floorHeight) >= 200 and (m.flags & MARIO_WING_CAP) ~= 0, ACT_FLYING, 0) then return 1 end
    if omm_action_midair_spin(m, m.actionTimer >= 16) then return 1 end
    m.controller.buttonPressed = m.controller.buttonPressed & (~(B_BUTTON))
    m.actionTimer = m.actionTimer + 1

    update_air_without_turn(m)
    local step = perform_air_step(m, AIR_STEP_CHECK_LEDGE_GRAB)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_FREEFALL_LAND, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_WALL, ACT_AIR_HIT_WALL, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_GRABBED_LEDGE, ACT_LEDGE_GRAB, 0) then return 0 end

    if m.actionArg == 1 then
        local frame = set_mario_anim_with_accel(m, MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN, 0x18000)
        mario_anim_clamp(m, 74, 94)
        m.marioBodyState.punchState = 0
        if frame < 94 then m.flags = m.flags | MARIO_KICKING end
    else
        local frame = set_mario_animation(m, MARIO_ANIM_AIR_KICK)
        if frame < 1 then m.marioBodyState.punchState = ((2 << 6) | 6) end
        if frame < 8 then m.flags = m.flags | MARIO_KICKING end
    end
    return 0
end

function omm_act_wall_slide(m)
    if omm_action_condition(m, m.wall == nil, ACT_FREEFALL, 0) then return 1 end
    if omm_action_a_pressed(m, 1, ACT_WALL_KICK_AIR, 0) then return omm_wall_slide_cancel(m, 24, 52, 1) end
    if omm_action_z_pressed(m, 1, ACT_SOFT_BONK, 0) then return omm_wall_slide_cancel(m, -8, 0, 0) end
    if omm_action_spin_air(m, 1) then return omm_wall_slide_cancel(m, 8, 0, 1) end

    set_mario_animation(m, MARIO_ANIM_START_WALLKICK)
    play_sound(OMM_SOUND_TERRAIN_SLIDE + m.terrainSoundAddend, m.marioObj.header.gfx.cameraToObject)
    m.particleFlags = m.particleFlags | PARTICLE_DUST

    m.faceAngle.y = s16(0x8000 + atan2s(m.wall.normal.z, m.wall.normal.x))
    mario_set_forward_vel(m, 1.0)
    local step = perform_air_step(m, 0)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_FREEFALL_LAND, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_NONE, ACT_FREEFALL, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_WALL and omm_mario_check_wall_slide(m) == 0, ACT_FREEFALL, 0) then return 0 end
    if omm_action_condition(m, m.wall == nil, ACT_FREEFALL, 0) then return 0 end

    m.marioObj.header.gfx.angle.y = atan2s(m.wall.normal.z, m.wall.normal.x)
    m.marioBodyState.handState = MARIO_HAND_OPEN
    return 0
end

function omm_act_ground_pound_jump(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    if omm_action_midair_spin(m, 1) then return 1 end
    if omm_action_spin_air(m, 1) then return 1 end

    if m.vel.y >= 42 then
        local step = perform_air_step(m, 0)
        if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_JUMP_LAND, 0) then return 0 end
    else
        local step = common_air_action_step(m, ACT_JUMP_LAND, MARIO_ANIM_SINGLE_JUMP, AIR_STEP_CHECK_LEDGE_GRAB)
        if omm_action_condition(m, step ~= AIR_STEP_NONE, 0, 0) then return 0 end
    end

    set_mario_animation(m, MARIO_ANIM_SINGLE_JUMP)
    local g = omm_mario_get(m)
    if (m.actionTimer == 0 or (g.spinYaw ~= 0 and g.spinYaw < 65536)) and m.vel.y > 0 then
        g.spinYaw = min(g.spinYaw + (128 * m.vel.y), 65536)
        m.actionTimer = 1
    else
        g.spinYaw = 0
    end
    m.marioObj.header.gfx.angle.y = m.faceAngle.y + g.spinYaw
    if m.vel.y > 0 then
        m.particleFlags = m.particleFlags | PARTICLE_DUST
    end
    return 0
end

function omm_act_roll_air(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_condition(m, m.forwardVel < 45 and (m.controller.buttonDown & Z_TRIG) == 0, ACT_FREEFALL, 0) then return 1 end

    update_air_without_turn(m)
    local step = perform_air_step(m, 0)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_OMM_ROLL, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_WALL, ACT_BACKWARD_AIR_KB, 0) then
        m.particleFlags = m.particleFlags | PARTICLE_VERTICAL_STAR
        return 0
    end
    
    omm_mario_update_roll_anim(m)
    return 0
end

function omm_act_spin_air(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 2) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    if omm_action_condition(m, m.actionTimer >= OMM_MARIO_SPIN_DURATION, ACT_FREEFALL, 0) then return 1 end

    update_air_without_turn(m)
    local step = perform_air_step(m, 0)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_JUMP_LAND, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_WALL, ACT_AIR_HIT_WALL, 0) then return 0 end

    set_mario_animation(m, MARIO_ANIM_TWIRL)
    local g = omm_mario_get(m)
    local prevSpinYaw = g.spinYaw
    g.spinYaw = s16(g.spinYaw + min(0x4714, 0x400 * (OMM_MARIO_SPIN_DURATION - m.actionTimer)))
    if g.spinYaw < prevSpinYaw then play_sound(OMM_SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject) end
    m.marioObj.header.gfx.angle.y = s16(m.faceAngle.y - g.spinYaw)
    m.marioBodyState.handState = MARIO_HAND_OPEN
    m.actionTimer = if_then_else(g.spinTimer > 0, 0, m.actionTimer + 1)
    return 0
end

function omm_act_spin_jump(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 2) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end

    update_air_without_turn(m)
    local step = perform_air_step(m, 0)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_JUMP_LAND, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    if omm_action_condition(m, m.vel.y <= 0.0, ACT_FREEFALL, 0) then return 0 end

    set_mario_animation(m, MARIO_ANIM_TWIRL)
    local g = omm_mario_get(m)
    local prevSpinYaw = g.spinYaw
    g.spinYaw = s16(g.spinYaw + min(0x5EDC, 0x400 * m.vel.y))
    if g.spinYaw < prevSpinYaw then play_sound(OMM_SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject) end
    m.marioObj.header.gfx.angle.y = s16(m.faceAngle.y - g.spinYaw)
    m.marioBodyState.handState = MARIO_HAND_OPEN
    m.particleFlags = m.particleFlags | PARTICLE_SPARKLES
    return 0
end

function omm_act_midair_spin(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    
    update_air_without_turn(m)
    local step = perform_air_step(m, 0)
    if omm_action_condition(m, step == AIR_STEP_LANDED, ACT_JUMP_LAND, 0) then return 0 end
    if omm_action_condition(m, step == AIR_STEP_HIT_LAVA_WALL and lava_boost_on_wall(m), ACT_LAVA_BOOST, 1) then return 0 end
    
    if m.actionTimer == 8 then
        if m.prevAction == ACT_DOUBLE_JUMP then
            set_mario_animation(m, MARIO_ANIM_DOUBLE_JUMP_FALL)
            m.prevAction = m.action
            m.action = ACT_DOUBLE_JUMP
            m.actionArg = 0
            m.actionState = 1
            m.actionTimer = 1
            m.flags = m.flags | MARIO_ACTION_SOUND_PLAYED | MARIO_MARIO_SOUND_PLAYED
        else
            set_mario_animation(m, MARIO_ANIM_GENERAL_FALL)
            omm_mario_set_action(m, ACT_FREEFALL, 0, 0)
        end
    else
        set_mario_animation(m, MARIO_ANIM_TWIRL)
        m.actionTimer = m.actionTimer + 1
        m.marioObj.header.gfx.angle.y = m.faceAngle.y - s16(m.actionTimer * 0x2000)
        m.marioBodyState.handState = MARIO_HAND_FISTS
    end
    return 0
end
