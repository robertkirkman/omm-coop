function omm_mario_play_cappy_throw_sound(m)
    local cappy = omm_cappy_get_object(m)
    if cappy ~= nil then
        if m.action == ACT_OMM_CAPPY_THROW_GROUND or m.action == ACT_OMM_CAPPY_THROW_AIRBORNE or m.action == ACT_OMM_CAPPY_THROW_WATER then
            if cappy.oBehParams2ndByte >= OMM_CAPPY_BHV_SPIN_GROUND then
                play_character_sound_offset(m, CHAR_SOUND_YAHOO_WAHA_YIPPEE, (2 + (m.marioObj.oTimer % 3)) << 16)
            else
                if (m.marioObj.oTimer % 3) == 0 then play_character_sound(m, CHAR_SOUND_PUNCH_YAH) end
                if (m.marioObj.oTimer % 3) == 1 then play_character_sound(m, CHAR_SOUND_PUNCH_WAH) end
                if (m.marioObj.oTimer % 3) == 2 then play_character_sound(m, CHAR_SOUND_PUNCH_HOO) end
            end
        else
            local actionSounds = {
                [ACT_FLYING]           = { isCharSound = true, sound = CHAR_SOUND_YAHOO_WAHA_YIPPEE, offset = 2 + (m.marioObj.oTimer % 3) },
                [ACT_OMM_CAPPY_BOUNCE] = { isCharSound = true, sound = CHAR_SOUND_HOOHOO,            offset = 0 },
                [ACT_OMM_CAPPY_VAULT]  = { isCharSound = true, sound = CHAR_SOUND_YAHOO_WAHA_YIPPEE, offset = 2 + (m.marioObj.oTimer % 3) },
            }
            actionSound = actionSounds[m.action]
            if actionSound ~= nil then
                if actionSound.isCharSound then
                    play_character_sound_offset(m, actionSound.sound, actionSound.offset << 16)
                else
                    play_sound(actionSound.sound + (actionSound.offset << 16), m.marioObj.header.gfx.cameraToObject)
                end
            end
        end
    end
end

function omm_mario_update_throw_anim(m)
    local cappy = omm_cappy_get_object(m)
    if cappy ~= nil then
        local cappyThrowAnims = {
            [OMM_CAPPY_BHV_DEFAULT_GROUND]   = { animID = MARIO_ANIM_GROUND_THROW,                 animSpeed = 0x18000, frameStart =  0, frameEnd = 20, duration = 12 },
            [OMM_CAPPY_BHV_DEFAULT_AIR]      = { animID = MARIO_ANIM_THROW_LIGHT_OBJECT,           animSpeed = 0x10000, frameStart =  0, frameEnd = 10, duration = 10 },
            [OMM_CAPPY_BHV_UPWARDS_GROUND]   = { animID = MARIO_ANIM_GROUND_KICK,                  animSpeed = 0x18000, frameStart =  0, frameEnd = 25, duration = 15 },
            [OMM_CAPPY_BHV_UPWARDS_AIR]      = { animID = MARIO_ANIM_AIR_KICK,                     animSpeed = 0x18000, frameStart =  0, frameEnd = 20, duration = 12 },
            [OMM_CAPPY_BHV_DOWNWARDS_GROUND] = { animID = MARIO_ANIM_GROUND_THROW,                 animSpeed = 0x18000, frameStart =  0, frameEnd = 20, duration = 12 },
            [OMM_CAPPY_BHV_DOWNWARDS_AIR]    = { animID = MARIO_ANIM_THROW_LIGHT_OBJECT,           animSpeed = 0x10000, frameStart =  0, frameEnd = 10, duration = 10 },
            [OMM_CAPPY_BHV_SPIN_GROUND]      = { animID = MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN, animSpeed = 0x18000, frameStart = 62, frameEnd = 94, duration = 20 },
            [OMM_CAPPY_BHV_SPIN_AIR]         = { animID = MARIO_ANIM_FINAL_BOWSER_RAISE_HAND_SPIN, animSpeed = 0x18000, frameStart = 62, frameEnd = 94, duration = 20 },
        }
        if cappyThrowAnims[cappy.oBehParams2ndByte] ~= nil then
            set_mario_anim_with_accel(m, cappyThrowAnims[cappy.oBehParams2ndByte].animID, cappyThrowAnims[cappy.oBehParams2ndByte].animSpeed)
            mario_anim_clamp(m, cappyThrowAnims[cappy.oBehParams2ndByte].frameStart, cappyThrowAnims[cappy.oBehParams2ndByte].frameEnd)
            m.actionTimer = m.actionTimer + 1
            return (m.actionTimer > cappyThrowAnims[cappy.oBehParams2ndByte].duration)
        end
    end
    return true
end

----------
-- Init --
----------

gActionInitTable = {

-- Moving
[ACT_OMM_CAPPY_THROW_GROUND]    = function (m) omm_act_cappy_throw_ground_init(m) end,

-- Airborne
[ACT_JUMP_KICK]                 = function (m) omm_act_jump_kick_init(m) end,
[ACT_OMM_CAPPY_BOUNCE]          = function (m) omm_act_cappy_bounce_init(m) end,
[ACT_OMM_CAPPY_VAULT]           = function (m) omm_act_cappy_vault_init(m) end,
[ACT_OMM_CAPPY_THROW_AIRBORNE]  = function (m) omm_act_cappy_throw_airborne_init(m) end,

-- Submerged
[ACT_OMM_CAPPY_THROW_WATER]     = function (m) omm_act_cappy_throw_water_init(m) end,

}

function mario_action_init(m)
    if gNetworkPlayers[m.playerIndex].connected then
        omm_mario_play_cappy_throw_sound(m)
        if gActionInitTable[m.action] then
            gActionInitTable[m.action](m)
        end
    end
end

hook_event(HOOK_ON_SET_MARIO_ACTION, mario_action_init)

------------
-- Cancel --
------------

gActionsNoCappyThrow = {
    [ACT_FIRST_PERSON] = true,
    [ACT_DIVE] = true,
    [ACT_SHOT_FROM_CANNON] = true,
    [ACT_VERTICAL_WIND] = true,
    [ACT_TWIRLING] = true,
    [ACT_AIR_HIT_WALL] = true,
    [ACT_GROUND_POUND] = true,
    [ACT_SLIDE_KICK] = true,
    [ACT_AIR_THROW] = true,
    [ACT_WATER_THROW] = true,
    [ACT_PICKING_UP] = true,
    [ACT_DIVE_PICKING_UP] = true,
    [ACT_STOMACH_SLIDE_STOP] = true,
    [ACT_PLACING_DOWN] = true,
    [ACT_THROWING] = true,
    [ACT_HEAVY_THROW] = true,
    [ACT_PICKING_UP_BOWSER] = true,
    [ACT_RELEASING_BOWSER] = true,
}

function omm_mario_check_cappy_throw(m)
    if gNetworkPlayers[m.playerIndex].connected then
        if (m.controller.buttonPressed & X_BUTTON) ~= 0 then
            if m.heldObj ~= nil or m.riddenObj ~= nil then return end
            if (m.action & ACT_GROUP_MASK) == ACT_GROUP_CUTSCENE then return end
            if (m.action & ACT_GROUP_MASK) == ACT_GROUP_AUTOMATIC then return end
            if (m.action & ACT_FLAG_BUTT_OR_STOMACH_SLIDE) ~= 0 then return end
            if (m.action & ACT_FLAG_METAL_WATER) ~= 0 then return end
            if (m.action & ACT_FLAG_ON_POLE) ~= 0 then return end
            if (m.action & ACT_FLAG_HANGING) ~= 0 then return end
            if (m.action & ACT_FLAG_INTANGIBLE) ~= 0 then return end
            if (m.action & ACT_FLAG_INVULNERABLE) ~= 0 then return end
            if (m.action & ACT_FLAG_RIDING_SHELL) ~= 0 then return end
            if gActionsNoCappyThrow[m.action] ~= nil then return end

            -- Cappy throw
            if omm_cappy_spawn(m) then

                -- Flying throw
                if m.action == ACT_FLYING then
                    omm_mario_play_cappy_throw_sound(m)
                    return
                end

                -- Water throw
                if (m.action & ACT_GROUP_MASK) == ACT_GROUP_SUBMERGED then
                    omm_mario_set_action(m, ACT_OMM_CAPPY_THROW_WATER, 0, X_BUTTON | A_BUTTON | B_BUTTON)
                    return
                end

                -- Airborne throw
                if (m.action & ACT_FLAG_AIR) ~= 0 then
                    omm_mario_set_action(m, ACT_OMM_CAPPY_THROW_AIRBORNE, 0, X_BUTTON | A_BUTTON | B_BUTTON)
                    return
                end

                -- Ground throw
                omm_mario_set_action(m, ACT_OMM_CAPPY_THROW_GROUND, 0, X_BUTTON | A_BUTTON | B_BUTTON)
                return
            end
        end
    end
end

hook_event(HOOK_BEFORE_MARIO_UPDATE, omm_mario_check_cappy_throw)

------------
-- Update --
------------

hook_mario_action(ACT_OMM_CAPPY_THROW_GROUND, omm_act_cappy_throw_ground)
hook_mario_action(ACT_OMM_CAPPY_BOUNCE, omm_act_cappy_bounce)
hook_mario_action(ACT_OMM_CAPPY_VAULT, omm_act_cappy_vault)
hook_mario_action(ACT_OMM_CAPPY_THROW_AIRBORNE, omm_act_cappy_throw_airborne)
hook_mario_action(ACT_OMM_CAPPY_THROW_WATER, omm_act_cappy_throw_water)