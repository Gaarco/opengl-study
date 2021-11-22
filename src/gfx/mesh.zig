const std = @import("std");
const gl = @import("gl33");
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

        gl.genVertexArrays(1, vao);
        gl.genBuffers(1, vbo);
        gl.genBuffers(1, ebo);

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
            gl.activeTexture(gl.TEXTURE0 + i);
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
        gl.bindVertexArray(self.vao);
        gl.bindBuffer(gl.ARRAY_BUFFER, self.vbo);

        gl.bufferData(gl.ARRAY_BUFFER, self.vertices.len * @sizeOf(Vertex), &self.vertices, gl.STATIC_DRAW);

        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, self.indices.len * @sizeOf(u32), &self.indices, gl.STATIC_DRAW);

        gl.enableVertexAttribArray(0);
        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @intToPtr(?*c_void, 0));
        gl.enableVertexAttribArray(1);
        gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "normal"));
        gl.enableVertexAttribArray(2);
        gl.vertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, @sizeOf(Vertex), @offsetOf(Vertex, "texture_coords"));

        gl.bindVertexArray(0);
    }
};
