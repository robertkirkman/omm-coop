function is_debug()
    return false
end

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

function nearest5(x, a, b, c, d, e)
    local xa = abs(a - x)
    local xb = abs(b - x)
    local xc = abs(c - x)
    local xd = abs(d - x)
    local xe = abs(e - x)
    local xm = min(min(min(min(xa, xb), xc), xd), xe)
    if xm == xa then return a end
    if xm == xb then return b end
    if xm == xc then return c end
    if xm == xd then return d end
    if xm == xe then return e end
    return x
end

function s8(x)
    x = (math.floor(x) & 0xFF)
    if x >= 128 then return x - 256 end
    return x
end

function s16(x)
    x = (math.floor(x) & 0xFFFF)
    if x >= 32768 then return x - 65536 end
    return x
end

function u8(x)
    x = (math.floor(x) & 0xFF)
    if x < 0 then return x + 256 end
    return x
end

function u16(x)
    x = (math.floor(x) & 0xFFFF)
    if x < 0 then return x + 65536 end
    return x
end

function vec3f_rotate_zxy(v, pitch, yaw, roll)
    local sx = sins(pitch)
    local cx = coss(pitch)
    local sy = sins(yaw)
    local cy = coss(yaw)
    local sz = sins(roll)
    local cz = coss(roll)
    local sysz = (sy * sz)
    local cycz = (cy * cz)
    local cysz = (cy * sz)
    local sycz = (sy * cz)
    local mtx00 = ((sysz * sx) + cycz)
    local mtx01 = (cx * sz)
    local mtx02 = ((cysz * sx) - sycz)
    local mtx10 = ((sycz * sx) - cysz)
    local mtx11 = (cx * cz)
    local mtx12 = ((cycz * sx) + sysz)
    local mtx20 = (cx * sy)
    local mtx21 = -sx
    local mtx22 = (cx * cy)
    local w = {
        x = v.x * mtx00 + v.y * mtx10 + v.z * mtx20,
        y = v.x * mtx01 + v.y * mtx11 + v.z * mtx21,
        z = v.x * mtx02 + v.y * mtx12 + v.z * mtx22,
    }
    return w
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
