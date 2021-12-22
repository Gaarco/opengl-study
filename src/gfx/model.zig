const std = @import("std");
const Mesh = @import("mesh.zig").Mesh;
const Shader = @import("../shader.zig");
const gltf = @import("cgltf");

const Model = struct {
    meshes: []Mesh,
    directory: []const u8,

    const Self = @This();

    pub fn fromPath(path: []const u8) Self {
    }

    pub fn fromMemory(model: []const u8) Self {
        const opt: gltf.cgltf_options = .{0};
        var data: *gltf.cgltf_data = undefined;
        const result: gltf.cgltf_result = gltf.cgltf_parse(&opt, model.ptr, model.len, &data);

        if (result == gltf.cgltf_result_success) {
            gltf.cgltf_free(data);
        }
    }

    pub fn draw(self: Self, shader: Shader) void {
        for (self.meshes) |_, m| {
            m.draw(allocator, shader);
        }
    }
};
