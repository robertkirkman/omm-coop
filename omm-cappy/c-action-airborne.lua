----------
-- Init --
----------

function omm_act_jump_kick_init(m)
    local cappy = omm_cappy_get_object(m)
    m.actionArg = if_then_else(cappy ~= nil and cappy.oSubAction == 1, 1, 0)
end

function omm_act_cappy_bounce_init(m)
    omm_mario_init_action(m, m.forwardVel * 0.8, 57, 0)
end

function omm_act_cappy_vault_init(m)
    omm_mario_init_action(m, m.forwardVel * 0.8, 68, 0)
end

function omm_act_cappy_throw_airborne_init(m)
    omm_mario_init_action(m, min(m.forwardVel, 8), 16, 0)
    mario_anim_reset(m)
end

------------
-- Cancel --
------------

------------
-- Update --
------------

function omm_act_cappy_bounce(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    if m.vel.y < 0 then
        set_mario_animation(m, MARIO_ANIM_DOUBLE_JUMP_FALL)
        m.action = ACT_DOUBLE_JUMP
        m.prevAction = ACT_DOUBLE_JUMP
        m.actionArg = 0
        m.actionState = 1
        m.actionTimer = 1
        m.flags = m.flags | MARIO_ACTION_SOUND_PLAYED | MARIO_MARIO_SOUND_PLAYED
        return 1
    end

    m.actionTimer = m.actionTimer + 1
    local step = common_air_action_step(m, ACT_DOUBLE_JUMP_LAND, MARIO_ANIM_DOUBLE_JUMP_RISE, AIR_STEP_CHECK_LEDGE_GRAB)
    if omm_action_condition(m, step ~= AIR_STEP_NONE, 0, 0) then return 0 end
    return 0
end

function omm_act_cappy_vault(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end
    if omm_action_condition(m, m.marioObj.header.gfx.animInfo.animID == MARIO_ANIM_TRIPLE_JUMP and m.marioObj.header.gfx.animInfo.animFrame >= m.marioObj.header.gfx.animInfo.curAnim.loopEnd - 1, ACT_FREEFALL, 0) then return 1 end

    m.actionTimer = m.actionTimer + 1
    local step = common_air_action_step(m, ACT_DOUBLE_JUMP_LAND, MARIO_ANIM_TRIPLE_JUMP, AIR_STEP_CHECK_LEDGE_GRAB)
    if omm_action_condition(m, step ~= AIR_STEP_NONE, 0, 0) then return 0 end
    play_flip_sounds(m, 2, 8, 20)
    return 0
end

function omm_act_cappy_throw_airborne(m)
    if omm_action_z_pressed(m, 1, ACT_GROUND_POUND, 0) then return 1 end
    if omm_action_b_pressed(m, 1, ACT_JUMP_KICK, 0) then return 1 end

    local step = common_air_action_step(m, ACT_FREEFALL_LAND, m.marioObj.header.gfx.animInfo.animID, 0)
    if omm_action_condition(m, step ~= AIR_STEP_NONE, 0, 0) then return 0 end
    if omm_action_condition(m, omm_mario_update_throw_anim(m), ACT_FREEFALL, 0) then return 0 end
    return 0
end
