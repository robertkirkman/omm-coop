function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

function min(a, b)
    if a < b then return a end
    return b
end

function max(a, b)
    if a > b then return a end
    return b
end

function clamp(x, a, b)
    if x < a then return a end
    if x > b then return b end
    return x
end

function abs(x)
    if x < 0 then return -x end
    return x
end

function sqr(x)
    return x * x
end

function lerp(t, a, b)
    return a + (b - a) * clamp(t, 0.0, 1.0)
end

function invlerp(x, a, b)
    return clamp((x - a) / (b - a), 0.0, 1.0)
end

function s16(x)
    x = (math.floor(x) & 0xFFFF)
    if x >= 32768 then return x - 65536 end
    return x
end

function u16(x)
    x = (math.floor(x) & 0xFFFF)
    if x < 0 then return x + 65536 end
    return x
end

function mario_anim_clamp(m, a, b)
    local frame = m.marioObj.header.gfx.animInfo.animFrame
    if frame < a then
        m.marioObj.header.gfx.animInfo.animFrame = a
        m.marioObj.header.gfx.animInfo.animFrameAccelAssist = (a << 16)
    end
    if frame > b then
        m.marioObj.header.gfx.animInfo.animFrame = b
        m.marioObj.header.gfx.animInfo.animFrameAccelAssist = (b << 16)
    end
end

function mario_anim_reset(m)
    m.marioObj.header.gfx.animInfo.animID = -1
end
