const std = @import("std");

const TextureType = enum {
    diffuse,
    specular,
};

const Texture = struct {
    handle: u32,
    @"type": TextureType,
};
