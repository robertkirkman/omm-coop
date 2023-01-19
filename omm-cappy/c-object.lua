function obj_check_interaction(obj)
    return (obj.oInteractStatus & INT_STATUS_INTERACTED) == 0 and obj.oIntangibleTimer == 0 and obj.activeFlags ~= ACTIVE_FLAG_DEACTIVATED
end

function obj_check_hitbox_overlap(hb1, hb2)
    local r2 = sqr(hb1.r + hb2.r)
    local d2 = sqr(hb1.x - hb2.x) + sqr(hb1.z - hb2.z)
    if d2 > r2 then return false end
    local hb1lb = hb1.y - hb1.d
    local hb1ub = hb1lb + hb1.h
    local hb2lb = hb2.y - hb2.d
    local hb2ub = hb2lb + hb2.h
    local hbsoh = hb1.h + hb2.h
    if (hb2ub - hb1lb) > hbsoh or (hb1ub - hb2lb) > hbsoh then return false end
    return true
end

function obj_is_mario(obj)
    return obj_has_behavior_id(obj, id_bhvMario) == 1 and obj ~= gMarioStates[0].marioObj
end

function obj_is_coin(obj)
    return (obj.oInteractType & INTERACT_COIN) ~= 0
end

function obj_is_secret(obj)
    return obj_has_behavior_id(obj, id_bhvHiddenStarTrigger) == 1
end

function obj_is_mushroom_1up(obj)
    return (obj.header.gfx.node.flags & GRAPH_RENDER_INVISIBLE) == 0 and (
            obj_has_behavior_id(obj, id_bhv1Up) == 1 or
            obj_has_behavior_id(obj, id_bhv1upJumpOnApproach) == 1 or
            obj_has_behavior_id(obj, id_bhv1upRunningAway) == 1 or
            obj_has_behavior_id(obj, id_bhv1upSliding) == 1 or
            obj_has_behavior_id(obj, id_bhv1upWalking) == 1 or
            obj_has_behavior_id(obj, id_bhvHidden1up) == 1 or
            obj_has_behavior_id(obj, id_bhvHidden1upInPole) == 1 or
            obj_has_behavior_id(obj, id_bhvHidden1upInPoleSpawner) == 1 or
            obj_has_behavior_id(obj, id_bhvHidden1upInPoleTrigger) == 1 or
            obj_has_behavior_id(obj, id_bhvHidden1upTrigger) == 1)
end

function obj_is_exclamation_box(obj)
    return obj_has_behavior_id(obj, id_bhvExclamationBox) == 1 and obj.oAction == 2
end

function obj_is_bully(obj)
    return (obj.oInteractType & INTERACT_BULLY) ~= 0
end

function obj_is_grabbable(obj)
    return (obj.oInteractType & INTERACT_GRABBABLE) ~= 0 and (obj.oInteractionSubtype & INT_SUBTYPE_NOT_GRABBABLE) == 0
end

function obj_is_breakable(obj)
    return (obj_has_behavior_id(obj, id_bhvBreakableBox) == 1 or
            obj_has_behavior_id(obj, id_bhvBreakableBoxSmall) == 1 or
            obj_has_behavior_id(obj, id_bhvHiddenObject) == 1 or
            obj_has_behavior_id(obj, id_bhvJumpingBox) == 1)
end

function obj_is_attackable(obj)
    return ((obj.oInteractType & INTERACT_KOOPA) ~= 0 or
            (obj.oInteractType & INTERACT_BOUNCE_TOP) ~= 0 or
            (obj.oInteractType & INTERACT_BOUNCE_TOP2) ~= 0 or
            (obj.oInteractType & INTERACT_HIT_FROM_BELOW) ~= 0)
end
