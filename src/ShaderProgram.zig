const std = @import("std");
const c = @import("c.zig");
const za = @import("zalgebra");
const panic = std.debug.panic;
const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

id: c_uint,

const Self = @This();

// TODO doesn't work, shader compilation fails
pub fn fromPath(allocator: *std.mem.Allocator, vertex_path: []const u8, fragment_path: []const u8) !Self {
    const vertex_file = try std.fs.cwd().openFile(vertex_path, .{ .read = true });
    defer vertex_file.close();
    var vert_buf_reader = std.io.bufferedReader(vertex_file.reader());
    var vert_in_stream = vert_buf_reader.reader();
    const vertex_shader = vert_in_stream.readAllAlloc(allocator, 1024) catch unreachable;

    const fragment_file = try std.fs.cwd().openFile(fragment_path, .{ .read = true });
    defer fragment_file.close();
    var frag_buf_reader = std.io.bufferedReader(fragment_file.reader());
    var frag_in_stream = frag_buf_reader.reader();
    const fragment_shader = frag_in_stream.readAllAlloc(allocator, 1024) catch unreachable;

    return fromSource(vertex_shader, fragment_shader);
}

pub fn fromSource(vertex_shader: []const u8, fragment_shader: []const u8) Self {
    var success: c_int = undefined;

    const vertex_id = c.glCreateShader(c.GL_VERTEX_SHADER);
    defer c.glDeleteShader(vertex_id);
    c.glShaderSource(vertex_id, 1, &[_][*]const u8{vertex_shader.ptr}, null);
    c.glCompileShader(vertex_id);
    c.glGetShaderiv(vertex_id, c.GL_COMPILE_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        c.glGetShaderInfoLog(vertex_id, info_log.len, null, &info_log);
        panic("ERROR: Vertex shader compilation failed\n{s}", .{info_log});
    }

    const fragment_id = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    defer c.glDeleteShader(fragment_id);
    c.glShaderSource(fragment_id, 1, &[_][*]const u8{fragment_shader.ptr}, null);
    c.glCompileShader(fragment_id);
    c.glGetShaderiv(fragment_id, c.GL_COMPILE_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        c.glGetShaderInfoLog(fragment_id, info_log.len, null, &info_log);
        panic("ERROR: Fragment shader compilation failed\n{s}", .{info_log});
    }

    const id: c_uint = c.glCreateProgram();
    c.glAttachShader(id, vertex_id);
    c.glAttachShader(id, fragment_id);
    c.glLinkProgram(id);

    c.glGetProgramiv(id, c.GL_LINK_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        c.glGetProgramInfoLog(id, info_log.len, null, &info_log);
        panic("ERROR: Shader linking failed\n{s}", .{info_log});
    }

    return .{ .id = id };
}

pub fn use(self: Self) void {
    c.glUseProgram(self.id);
}

pub fn setValue(self: Self, name: [*]const u8, value: anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .Int, .ComptimeInt => {
            c.glUniform1i(c.glGetUniformLocation(self.id, name), value);
        },
        .Float, .ComptimeFloat => {
            c.glUniform1f(c.glGetUniformLocation(self.id, name), value);
        },
        .Bool => {
            c.glUniform1i(c.glGetUniformLocation(self.id, name), @boolToInt(value));
        },
        .Struct => {
            switch (@TypeOf(value)) {
                Mat4 => {
                    c.glUniformMatrix4fv(c.glGetUniformLocation(self.id, name), 1, c.GL_FALSE, value.getData());
                },
                Vec3 => {
                    c.glUniform3f(c.glGetUniformLocation(self.id, name), value.x, value.y, value.z);
                },
                else => {
                    panic("Not implemented for type: {}", .{@TypeOf(value)});
                },
            }
        },
        else => {
            panic("Not implemented for type: {}", .{@TypeOf(value)});
        },
    }
}
