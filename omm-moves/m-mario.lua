gOmmMario = {}

for i = 0, (MAX_PLAYERS - 1) do
    gOmmMario[i] = {}

    -- Wall slide
    gOmmMario[i].wallSlideHeight = 20000
    gOmmMario[i].wallSlideJumped = false
    gOmmMario[i].wallSlideAngle = 0

    -- Spin
    gOmmMario[i].spinYaw = 0
    gOmmMario[i].spinTimer = 0
    gOmmMario[i].spinBufferTimer = 0
    gOmmMario[i].spinNumHitCheckpoints = 0
    gOmmMario[i].spinCheckpoint = -1
    gOmmMario[i].spinDirection = 0

    -- Midair spin
    gOmmMario[i].midairSpinTimer = 0
    gOmmMario[i].midairSpinCounter = 0

    -- Other
    gOmmMario[i].airCombo = 0
    gOmmMario[i].soundPlayed = 0
end

function omm_mario_get(m)
    return gOmmMario[m.playerIndex]
end

function is_local_player(m)
    return m.playerIndex == 0
end
