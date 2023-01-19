----------
-- Init --
----------

gActionInitTable = {

-- Stationary
[ACT_DEBUG_FREE_MOVE]                   = function (m) omm_act_debug_free_move_init(m) end,
[ACT_GROUND_POUND_LAND]                 = function (m) omm_act_ground_pound_land_init(m) end,
[ACT_OMM_SPIN_GROUND]                   = function (m) omm_act_spin_ground_init(m) end,

-- Moving
[ACT_WALKING]                           = function (m) omm_act_walking_init(m) end,
[ACT_DECELERATING]                      = function (m) omm_act_decelerating_init(m) end,
[ACT_CRAWLING]                          = function (m) omm_act_crawling_init(m) end,
[ACT_OMM_ROLL]                          = function (m) omm_act_roll_init(m) end,

-- Airborne
[ACT_JUMP]                              = function (m) omm_act_jump_init(m) end,
[ACT_DOUBLE_JUMP]                       = function (m) omm_act_double_jump_init(m) end,
[ACT_TRIPLE_JUMP]                       = function (m) omm_act_triple_jump_init(m) end,
[ACT_FLYING_TRIPLE_JUMP]                = function (m) omm_act_flying_triple_jump_init(m) end,
[ACT_SPECIAL_TRIPLE_JUMP]               = function (m) omm_act_special_triple_jump_init(m) end,
[ACT_FREEFALL]                          = function (m) omm_act_freefall_init(m) end,
[ACT_SIDE_FLIP]                         = function (m) omm_act_side_flip_init(m) end,
[ACT_WALL_KICK_AIR]                     = function (m) omm_act_wall_kick_air_init(m) end,
[ACT_STEEP_JUMP]                        = function (m) omm_act_steep_jump_init(m) end,
[ACT_FLYING]                            = function (m) omm_act_flying_init(m) end,
[ACT_DIVE]                              = function (m) omm_act_dive_init(m) end,
[ACT_GROUND_POUND]                      = function (m) omm_act_ground_pound_init(m) end,
[ACT_AIR_HIT_WALL]                      = function (m) omm_act_air_hit_wall_init(m) end,
[ACT_OMM_GROUND_POUND_JUMP]             = function (m) omm_act_ground_pound_jump_init(m) end,
[ACT_OMM_SPIN_AIR]                      = function (m) omm_act_spin_air_init(m) end,
[ACT_OMM_SPIN_JUMP]                     = function (m) omm_act_spin_jump_init(m) end,
[ACT_OMM_MIDAIR_SPIN]                   = function (m) omm_act_midair_spin_init(m) end,

-- Submerged
[ACT_OMM_WATER_GROUND_POUND]            = function (m) omm_act_water_ground_pound_init(m) end,
[ACT_OMM_WATER_GROUND_POUND_LAND]       = function (m) omm_act_water_ground_pound_land_init(m) end,
[ACT_OMM_WATER_GROUND_POUND_JUMP]       = function (m) omm_act_water_ground_pound_jump_init(m) end,

}

function mario_action_init(m)
    if gNetworkPlayers[m.playerIndex].connected then
        local g = omm_mario_get(m)
        g.soundPlayed = 0
        if gActionInitTable[m.action] then
            gActionInitTable[m.action](m)
        end
    end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, mario_action_init)

------------
-- Cancel --
------------

gActionCancelTable = {

-- Stationary
[ACT_IDLE]                              = function (m) omm_act_idle_cancel(m) end,
[ACT_PANTING]                           = function (m) omm_act_panting_cancel(m) end,
[ACT_COUGHING]                          = function (m) omm_act_coughing_cancel(m) end,
[ACT_SHIVERING]                         = function (m) omm_act_shivering_cancel(m) end,
[ACT_STANDING_AGAINST_WALL]             = function (m) omm_act_standing_against_wall_cancel(m) end,
[ACT_IN_QUICKSAND]                      = function (m) omm_act_in_quicksand_cancel(m) end,
[ACT_START_CROUCHING]                   = function (m) omm_act_crouching_cancel(m) end,
[ACT_CROUCHING]                         = function (m) omm_act_crouching_cancel(m) end,
[ACT_STOP_CROUCHING]                    = function (m) omm_act_crouching_cancel(m) end,
[ACT_START_CRAWLING]                    = function (m) omm_act_crawling_cancel(m) end,
[ACT_STOP_CRAWLING]                     = function (m) omm_act_crawling_cancel(m) end,
[ACT_BRAKING_STOP]                      = function (m) omm_act_braking_stop_cancel(m) end,
[ACT_JUMP_LAND_STOP]                    = function (m) omm_act_jump_land_stop_cancel(m) end,
[ACT_DOUBLE_JUMP_LAND_STOP]             = function (m) omm_act_double_jump_land_stop_cancel(m) end,
[ACT_SIDE_FLIP_LAND_STOP]               = function (m) omm_act_side_flip_land_stop_cancel(m) end,
[ACT_FREEFALL_LAND_STOP]                = function (m) omm_act_freefall_land_stop_cancel(m) end,
[ACT_TRIPLE_JUMP_LAND_STOP]             = function (m) omm_act_triple_jump_land_stop_cancel(m) end,
[ACT_BACKFLIP_LAND_STOP]                = function (m) omm_act_backflip_land_stop_cancel(m) end,
[ACT_LONG_JUMP_LAND_STOP]               = function (m) omm_act_long_jump_land_stop_cancel(m) end,

-- Moving
[ACT_WALKING]                           = function (m) omm_act_walking_cancel(m) end,
[ACT_TURNING_AROUND]                    = function (m) omm_act_turning_around_cancel(m) end,
[ACT_FINISH_TURNING_AROUND]             = function (m) omm_act_finish_turning_around_cancel(m) end,
[ACT_BRAKING]                           = function (m) omm_act_braking_cancel(m) end,
[ACT_CRAWLING]                          = function (m) omm_act_crawling_cancel(m) end,
[ACT_DECELERATING]                      = function (m) omm_act_decelerating_cancel(m) end,
[ACT_CROUCH_SLIDE]                      = function (m) omm_act_crouch_slide_cancel(m) end,
[ACT_JUMP_LAND]                         = function (m) omm_act_jump_land_cancel(m) end,
[ACT_FREEFALL_LAND]                     = function (m) omm_act_freefall_land_cancel(m) end,
[ACT_DOUBLE_JUMP_LAND]                  = function (m) omm_act_double_jump_land_cancel(m) end,
[ACT_SIDE_FLIP_LAND]                    = function (m) omm_act_side_flip_land_cancel(m) end,
[ACT_TRIPLE_JUMP_LAND]                  = function (m) omm_act_triple_jump_land_cancel(m) end,
[ACT_BACKFLIP_LAND]                     = function (m) omm_act_backflip_land_cancel(m) end,
[ACT_QUICKSAND_JUMP_LAND]               = function (m) omm_act_quicksand_jump_land_cancel(m) end,
[ACT_LONG_JUMP_LAND]                    = function (m) omm_act_long_jump_land_cancel(m) end,
[ACT_DIVE_SLIDE]                        = function (m) omm_act_dive_slide_cancel(m) end,
[ACT_BURNING_GROUND]                    = function (m) omm_act_burning_ground_cancel(m) end,
[ACT_MOVE_PUNCHING]                     = function (m) omm_act_move_punching_cancel(m) end,

-- Airborne
[ACT_JUMP]                              = function (m) omm_act_jump_cancel(m) end,
[ACT_DOUBLE_JUMP]                       = function (m) omm_act_double_jump_cancel(m) end,
[ACT_FLYING_TRIPLE_JUMP]                = function (m) omm_act_flying_triple_jump_cancel(m) end,
[ACT_BACKFLIP]                          = function (m) omm_act_backflip_cancel(m) end,
[ACT_LONG_JUMP]                         = function (m) omm_act_long_jump_cancel(m) end,
[ACT_FREEFALL]                          = function (m) omm_act_freefall_cancel(m) end,
[ACT_SIDE_FLIP]                         = function (m) omm_act_side_flip_cancel(m) end,
[ACT_WALL_KICK_AIR]                     = function (m) omm_act_wall_kick_air_cancel(m) end,
[ACT_WATER_JUMP]                        = function (m) omm_act_water_jump_cancel(m) end,
[ACT_BURNING_JUMP]                      = function (m) omm_act_burning_jump_cancel(m) end,
[ACT_BURNING_FALL]                      = function (m) omm_act_burning_fall_cancel(m) end,
[ACT_TOP_OF_POLE_JUMP]                  = function (m) omm_act_top_of_pole_jump_cancel(m) end,
[ACT_TWIRLING]                          = function (m) omm_act_twirling_cancel(m) end,
[ACT_SOFT_BONK]                         = function (m) omm_act_soft_bonk_cancel(m) end,
[ACT_FORWARD_ROLLOUT]                   = function (m) omm_act_forward_rollout_cancel(m) end,
[ACT_BACKWARD_ROLLOUT]                  = function (m) omm_act_backward_rollout_cancel(m) end,
[ACT_LAVA_BOOST]                        = function (m) omm_act_lava_boost_cancel(m) end,
[ACT_GETTING_BLOWN]                     = function (m) omm_act_getting_blown_cancel(m) end,
[ACT_THROWN_FORWARD]                    = function (m) omm_act_thrown_forward_cancel(m) end,
[ACT_THROWN_BACKWARD]                   = function (m) omm_act_thrown_backward_cancel(m) end,
[ACT_FORWARD_AIR_KB]                    = function (m) omm_act_forward_air_kb_cancel(m) end,
[ACT_BACKWARD_AIR_KB]                   = function (m) omm_act_backward_air_kb_cancel(m) end,
[ACT_HARD_FORWARD_AIR_KB]               = function (m) omm_act_hard_forward_air_kb_cancel(m) end,
[ACT_HARD_BACKWARD_AIR_KB]              = function (m) omm_act_hard_backward_air_kb_cancel(m) end,
[ACT_SOFT_BONK]                         = function (m) omm_act_soft_bonk_cancel(m) end,
[ACT_OMM_CAPPY_BOUNCE]                  = function (m) omm_act_cappy_bounce_cancel(m) end,
[ACT_OMM_CAPPY_VAULT]                   = function (m) omm_act_cappy_vault_cancel(m) end,

-- Submerged
[ACT_WATER_IDLE]                        = function (m) omm_act_water_idle_cancel(m) end,
[ACT_WATER_ACTION_END]                  = function (m) omm_act_water_action_end_cancel(m) end,
[ACT_BREASTSTROKE]                      = function (m) omm_act_breaststroke_cancel(m) end,
[ACT_SWIMMING_END]                      = function (m) omm_act_swimming_end_cancel(m) end,
[ACT_FLUTTER_KICK]                      = function (m) omm_act_flutter_kick_cancel(m) end,

-- Other
[ACT_PUNCHING]                          = function (m) omm_act_punching_cancel(m) end,
[ACT_START_HANGING]                     = function (m) omm_act_start_hanging_cancel(m) end,
[ACT_HANGING]                           = function (m) omm_act_hanging_cancel(m) end,
[ACT_HANG_MOVING]                       = function (m) omm_act_hang_moving_cancel(m) end,
[ACT_HOLDING_POLE]                      = function (m) omm_act_holding_pole_cancel(m) end,
[ACT_CLIMBING_POLE]                     = function (m) omm_act_climbing_pole_cancel(m) end,

}

function mario_action_cancel(m)
    if gNetworkPlayers[m.playerIndex].connected then
        local g = omm_mario_get(m)
        if gActionCancelTable[m.action] then
            gActionCancelTable[m.action](m)
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, mario_action_cancel)

------------
-- Update --
------------

hook_mario_action(ACT_GROUND_POUND_LAND, omm_act_ground_pound_land) -- overridden
hook_mario_action(ACT_GROUND_POUND, omm_act_ground_pound) -- overridden
hook_mario_action(ACT_TRIPLE_JUMP, omm_act_triple_jump) -- overridden
hook_mario_action(ACT_JUMP_KICK, omm_act_jump_kick) -- overridden
hook_mario_action(ACT_OMM_SPIN_GROUND, omm_act_spin_ground)
hook_mario_action(ACT_OMM_ROLL, omm_act_roll)
hook_mario_action(ACT_OMM_GROUND_POUND_JUMP, omm_act_ground_pound_jump)
hook_mario_action(ACT_OMM_WALL_SLIDE, omm_act_wall_slide)
hook_mario_action(ACT_OMM_ROLL_AIR, omm_act_roll_air)
hook_mario_action(ACT_OMM_SPIN_AIR, omm_act_spin_air)
hook_mario_action(ACT_OMM_SPIN_JUMP, omm_act_spin_jump)
hook_mario_action(ACT_OMM_MIDAIR_SPIN, omm_act_midair_spin)
hook_mario_action(ACT_OMM_WATER_GROUND_POUND, omm_act_water_ground_pound, INT_GROUND_POUND_OR_TWIRL)
hook_mario_action(ACT_OMM_WATER_GROUND_POUND_LAND, omm_act_water_ground_pound_land, INT_GROUND_POUND_OR_TWIRL)
hook_mario_action(ACT_OMM_WATER_GROUND_POUND_JUMP, omm_act_water_ground_pound_jump)
hook_mario_action(ACT_OMM_WATER_DASH, omm_act_water_dash)
