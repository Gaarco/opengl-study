const std = @import("std");
const Mesh = @import("mesh.zig").Mesh;

const Model = struct {
    meshes: []Mesh,

    const Self = @This();

    pub fn init() Self {}
};
