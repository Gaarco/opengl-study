const std = @import("std");
const Vec3 = @import("zalgebra").Vec3;
const Vec2 = @import("zalgebra").Vec2;

pub const Vertex = packed struct {
    position: Vec3,
    normal: Vec3,
    texture_coords: Vec2,
};
