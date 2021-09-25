const std = @import("std");
const c = @import("c.zig");
const panic = std.debug.panic;

pub const ShaderProgram = struct {
    id: c_uint,

    const Self = @This();

    // TODO
    pub fn fromPath(vertex_path: []const u8, fragment_path: []const u8) Self {
        _ = vertex_path;
        _ = fragment_path;
        unreachable;
    }

    pub fn fromSource(vertex_shader: []const u8, fragment_shader: []const u8) Self {
        var success: c_int = undefined;

        const vertex_id = c.glCreateShader(c.GL_VERTEX_SHADER);
        defer c.glDeleteShader(vertex_id);
        c.glShaderSource(vertex_id, 1, &[_][*c]const u8{vertex_shader.ptr}, null);
        c.glCompileShader(vertex_id);
        c.glGetShaderiv(vertex_id, c.GL_COMPILE_STATUS, &success);
        if (success == @boolToInt(false)) {
            panic("ERROR: Vertex shader compilation failed", .{});
        }

        const fragment_id = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        defer c.glDeleteShader(fragment_id);
        c.glShaderSource(fragment_id, 1, &[_][*c]const u8{fragment_shader.ptr}, null);
        c.glCompileShader(fragment_id);
        c.glGetShaderiv(fragment_id, c.GL_COMPILE_STATUS, &success);
        if (success == @boolToInt(false)) {
            panic("ERROR: Fragment shader compilation failed", .{});
        }
        const id: c_uint = c.glCreateProgram();
        c.glAttachShader(id, vertex_id);
        c.glAttachShader(id, fragment_id);
        c.glLinkProgram(id);

        c.glGetProgramiv(id, c.GL_LINK_STATUS, &success);
        if (success == @boolToInt(false)) {
            var info_log: [512]u8 = undefined;
            c.glGetProgramInfoLog(id, info_log.len, null, &info_log);
            panic("ERROR: Shader linking failed {s}", .{info_log});
        }

        return .{.id = id};
    }

    pub fn use(self: *Self) void {
        c.glUseProgram(self.id);
    }

    pub fn setValue(self: *Self, name: []const u8, value: anytype) void {
        switch (@typeInfo(@TypeOf(value))) {
            .Int => {
                c.glUniform1i(c.glGetUniformLocation(self.id, name), value);
            },
            .Float => {
                c.glUniform1f(c.glGetUniformLocation(self.id, name), value);
            },
            .Bool => {
                c.glUniform1i(c.glGetUniformLocation(self.id, name), @boolToInt(value));
            },
            else => {
                panic("Not implemented for type: {}", .{@TypeOf(value)});
            },
        }
    }

    // TODO doesn't work, causes shader program linking to fail
    fn compileShaders(vertex_shader: []const u8, fragment_shader: []const u8) []c_uint {
        var success: c_int = undefined;

        const vertex_id = c.glCreateShader(c.GL_VERTEX_SHADER);
        defer c.glDeleteShader(vertex_id);
        c.glShaderSource(vertex_id, 1, &[_][*c]const u8{vertex_shader.ptr}, null);
        c.glCompileShader(vertex_id);
        c.glGetShaderiv(vertex_id, c.GL_COMPILE_STATUS, &success);
        if (success == @boolToInt(false)) {
            panic("ERROR: Vertex shader compilation failed", .{});
        }

        const fragment_id = c.glCreateShader(c.GL_FRAGMENT_SHADER);
        defer c.glDeleteShader(fragment_id);
        c.glShaderSource(fragment_id, 1, &[_][*c]const u8{fragment_shader.ptr}, null);
        c.glCompileShader(fragment_id);
        c.glGetShaderiv(fragment_id, c.GL_COMPILE_STATUS, &success);
        if (success == @boolToInt(false)) {
            panic("ERROR: Fragment shader compilation failed", .{});
        }

        return &.{
            vertex_id,
            fragment_id,
        };
    }
};
