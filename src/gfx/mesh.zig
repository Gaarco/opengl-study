const std = @import("std");
const c = @import("c.zig");
const Shader = @import("../Shader.zig");
const Vertex = @import("vertex.zig").Vertex;
const Texture = @import("texture.zig");

const Mesh = struct {
    vao: c_uint,
    vbo: c_uint,
    ebo: c_uint,

    vertices: []Vertex,
    indices: []u32,
    textures: []Texture,

    const Self = @This();

    pub fn init(vertices: []Vertex, indices: []u32, textures: Texture) Self {
        const vao: c_uint = undefined;
        const vbo: c_uint = undefined;
        const ebo: c_uint = undefined;

        c.glGenVertexArrays(1, vao);
        c.glGenBuffers(1, vbo);
        c.glGenBuffers(1, ebo);

        const mesh = Self{
            .vao = vao,
            .vbo = vbo,
            .ebo = ebo,
            .vertices = vertices,
            .indices = indices,
            .textures = textures,
        };
        mesh.setupMesh();
        return mesh;
    }

    pub fn draw(self: Self, shader: Shader) void {
        for (self.textures) |i, t| {
            c.glActiveTexture(c.GL_TEXTURE0 + i);
            switch (t.@"type") {
                .diffuse => {
                    diff_count += 1;
                },
                .specular => {
                    spec_count += 1;
                },
            }
        }
    }

    fn setupMesh(self: Self) void {
        c.glBindVertexArray(self.vao);
        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vbo);

        c.glBufferData(c.GL_ARRAY_BUFFER, self.vertices.len * @sizeOf(Vertex), &self.vertices, c.GL_STATIC_DRAW);

        c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, self.ebo);
        c.glBufferData(c.GL_ELEMENT_ARRAY_BUFFER, self.indices.len * @sizeOf(u32), &self.indices, c.GL_STATIC_DRAW);

        c.glEnableVertexAttribArray(0);
        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), @intToPtr(?*c_void, 0));
        c.glEnableVertexAttribArray(1);
        c.glVertexAttribPointer(1, 3, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "normal"));
        c.glEnableVertexAttribArray(2);
        c.glVertexAttribPointer(2, 2, c.GL_FLOAT, c.GL_FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "texture_coords"));

        c.glBindVertexArray(0);
    }
};
