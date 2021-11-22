const std = @import("std");
const gl = @import("gl33");
const c = @import("c.zig");
const za = @import("zalgebra");
const panic = std.debug.panic;
const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

id: c_uint,

const Self = @This();

pub fn fromPath(allocator: *std.mem.Allocator, vertex_path: []const u8, fragment_path: []const u8, max_size: usize) !Self {
    const vertex_file = try std.fs.cwd().openFile(vertex_path, .{ .read = true });
    defer vertex_file.close();
    var vert_buf_reader = std.io.bufferedReader(vertex_file.reader());
    var vert_in_stream = vert_buf_reader.reader();
    var vertex_shader = try vert_in_stream.readAllAlloc(allocator, max_size);
    vertex_shader = try std.mem.Allocator.dupeZ(allocator, u8, vertex_shader);

    const fragment_file = try std.fs.cwd().openFile(fragment_path, .{ .read = true });
    defer fragment_file.close();
    var frag_buf_reader = std.io.bufferedReader(fragment_file.reader());
    var frag_in_stream = frag_buf_reader.reader();
    var fragment_shader = try frag_in_stream.readAllAlloc(allocator, max_size);
    fragment_shader = try std.mem.Allocator.dupeZ(allocator, u8, fragment_shader);

    return fromSource(vertex_shader, fragment_shader);
}

pub fn fromSource(vertex_shader: []const u8, fragment_shader: []const u8) Self {
    var success: c_int = undefined;

    const vertex_id = gl.createShader(gl.VERTEX_SHADER);
    defer gl.deleteShader(vertex_id);
    gl.shaderSource(vertex_id, 1, &[_][*]const u8{vertex_shader.ptr}, null);
    gl.compileShader(vertex_id);
    gl.getShaderiv(vertex_id, gl.COMPILE_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        gl.getShaderInfoLog(vertex_id, info_log.len, null, &info_log);
        panic("ERROR: Vertex shader compilation failed\n{s}", .{info_log});
    }

    const fragment_id = gl.createShader(gl.FRAGMENT_SHADER);
    defer gl.deleteShader(fragment_id);
    gl.shaderSource(fragment_id, 1, &[_][*]const u8{fragment_shader.ptr}, null);
    gl.compileShader(fragment_id);
    gl.getShaderiv(fragment_id, gl.COMPILE_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        gl.getShaderInfoLog(fragment_id, info_log.len, null, &info_log);
        panic("ERROR: Fragment shader compilation failed\n{s}", .{info_log});
    }

    const id: c_uint = gl.createProgram();
    gl.attachShader(id, vertex_id);
    gl.attachShader(id, fragment_id);
    gl.linkProgram(id);

    gl.getProgramiv(id, gl.LINK_STATUS, &success);
    if (success == @boolToInt(false)) {
        var info_log: [512]u8 = undefined;
        gl.getProgramInfoLog(id, info_log.len, null, &info_log);
        panic("ERROR: Shader linking failed\n{s}", .{info_log});
    }

    return .{ .id = id };
}

pub fn use(self: Self) void {
    gl.useProgram(self.id);
}

pub fn setValue(self: Self, name: []const u8, value: anytype) void {
    switch (@typeInfo(@TypeOf(value))) {
        .Int, .ComptimeInt => {
            gl.uniform1i(gl.getUniformLocation(self.id, name.ptr), value);
        },
        .Float, .ComptimeFloat => {
            gl.uniform1f(gl.getUniformLocation(self.id, name.ptr), value);
        },
        .Bool => {
            gl.uniform1i(gl.getUniformLocation(self.id, name.ptr), @boolToInt(value));
        },
        .Struct => {
            switch (@TypeOf(value)) {
                Mat4 => {
                    gl.uniformMatrix4fv(gl.getUniformLocation(self.id, name.ptr), 1, gl.FALSE, value.getData());
                },
                Vec3 => {
                    gl.uniform3f(gl.getUniformLocation(self.id, name.ptr), value.x, value.y, value.z);
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
