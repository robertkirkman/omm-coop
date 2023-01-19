gCappyModel = {
    [4 * CT_MARIO + 0]   = E_MODEL_MARIOS_CAP,
    [4 * CT_MARIO + 1]   = E_MODEL_MARIOS_WING_CAP,
    [4 * CT_MARIO + 2]   = E_MODEL_MARIOS_METAL_CAP,
    [4 * CT_MARIO + 3]   = E_MODEL_MARIOS_WINGED_METAL_CAP,
    [4 * CT_LUIGI + 0]   = E_MODEL_LUIGIS_CAP,
    [4 * CT_LUIGI + 1]   = E_MODEL_LUIGIS_WING_CAP,
    [4 * CT_LUIGI + 2]   = E_MODEL_LUIGIS_METAL_CAP,
    [4 * CT_LUIGI + 3]   = E_MODEL_LUIGIS_WINGED_METAL_CAP,
    [4 * CT_TOAD + 0]    = E_MODEL_TOADS_CAP,
    [4 * CT_TOAD + 1]    = E_MODEL_TOADS_WING_CAP,
    [4 * CT_TOAD + 2]    = E_MODEL_TOADS_METAL_CAP,
    [4 * CT_TOAD + 3]    = E_MODEL_TOADS_WING_CAP,
    [4 * CT_WALUIGI + 0] = E_MODEL_WALUIGIS_CAP,
    [4 * CT_WALUIGI + 1] = E_MODEL_WALUIGIS_WING_CAP,
    [4 * CT_WALUIGI + 2] = E_MODEL_WALUIGIS_METAL_CAP,
    [4 * CT_WALUIGI + 3] = E_MODEL_WALUIGIS_WINGED_METAL_CAP,
    [4 * CT_WARIO + 0]   = E_MODEL_WARIOS_CAP,
    [4 * CT_WARIO + 1]   = E_MODEL_WARIOS_WING_CAP,
    [4 * CT_WARIO + 2]   = E_MODEL_WARIOS_METAL_CAP,
    [4 * CT_WARIO + 3]   = E_MODEL_WARIOS_WINGED_METAL_CAP,
}

function omm_cappy_update_gfx(m, cappy)
    if cappy.oSubAction == 1 and cappy.oTimer >= 0 then
        obj_set_model_extended(cappy, gCappyModel[
            m.character.type * 4 +
            if_then_else((m.flags & MARIO_METAL_CAP) ~= 0, 2, 0) +
            if_then_else((m.flags & MARIO_WING_CAP) ~= 0, 1, 0)
        ])
        cappy.oFaceAnglePitch = 0
        cappy.oFaceAngleYaw = cappy.oFaceAngleYaw + OMM_CAPPY_GFX_ANGLE_VEL
        cappy.oFaceAngleRoll = 0
        cappy.oOpacity = if_then_else((m.flags & MARIO_VANISH_CAP) ~= 0, 0x80, 0xFF)
        cappy.header.gfx.scale.x = OMM_CAPPY_GFX_SCALE_X
        cappy.header.gfx.scale.y = OMM_CAPPY_GFX_SCALE_Y
        cappy.header.gfx.scale.z = OMM_CAPPY_GFX_SCALE_Z
        cappy.header.gfx.node.flags = cappy.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
        spawn_non_sync_object(id_bhvSparkleSpawn, E_MODEL_NONE, cappy.oPosX, cappy.oPosY, cappy.oPosZ, nil)
    else
        cappy.header.gfx.node.flags = cappy.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
    end
end
