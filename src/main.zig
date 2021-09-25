const std = @import("std");
const c = @import("c.zig");
const panic = std.debug.panic;
const ShaderProgram = @import("shader.zig").ShaderProgram;

const vertices = [_]f32{
    0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
    -0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
    0.0, 0.5, 0.0, 0.0, 0.0, 1.0,
};

const vertex_shader = @embedFile("shader.vert");
const fragment_shader = @embedFile("shader.frag");

pub fn main() anyerror!void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(800, 600, "Learn OpenGL", null, null) orelse {
        c.glfwTerminate();
        panic("Failed to create GLFW window", .{});
    };
    defer c.glfwTerminate();
    c.glfwMakeContextCurrent(window);

    c.glViewport(0, 0, 800, 600);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

    var vbo: c_uint = undefined;
    c.glGenBuffers(1, &vbo);
    var vao: c_uint = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glBindVertexArray(vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 6 * @sizeOf(f32), @intToPtr(?*c_void, 0));
    c.glEnableVertexAttribArray(0);
    c.glVertexAttribPointer(1, 3, c.GL_FLOAT, c.GL_FALSE, 6 * @sizeOf(f32), @intToPtr(?*c_void, 3 * @sizeOf(f32)));
    c.glEnableVertexAttribArray(1);

    const shader = ShaderProgram.fromSource(vertex_shader, fragment_shader);

    //const vertex_shader_source = @embedFile("shader.vert");
    //const vertex_shader = c.glCreateShader(c.GL_VERTEX_SHADER);
    //defer c.glDeleteShader(vertex_shader);
    //c.glShaderSource(vertex_shader, 1, &[_][*c]const u8{vertex_shader_source}, null);
    //c.glCompileShader(vertex_shader);
    //var success: c_int = undefined;
    //c.glGetShaderiv(vertex_shader, c.GL_COMPILE_STATUS, &success);
    //if (success == @boolToInt(false)) {
    //    panic("Error: shader vertex compilation failedn");
    //}

    //const fragment_shader_source = @embedFile("shader.frag");
    //const fragment_shader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    //defer c.glDeleteShader(fragment_shader);
    //c.glShaderSource(fragment_shader, 1, &[_][*c]const u8{fragment_shader_source}, null);
    //c.glCompileShader(fragment_shader);
    //c.glGetShaderiv(fragment_shader, c.GL_COMPILE_STATUS, &success);
    //if (success == @boolToInt(false)) {
    //    panic("Error: shader fragment compilation failedn");
    //}

    //var shader_program: c_uint = c.glCreateProgram();
    //c.glAttachShader(shader_program, vertex_shader);
    //c.glAttachShader(shader_program, fragment_shader);
    //c.glLinkProgram(shader_program);

    //c.glGetProgramiv(shader_program, c.GL_LINK_STATUS, &success);
    //if (success == @boolToInt(false)) {
    //    panic("Error: shader program link failed");
    //}

    while (c.glfwWindowShouldClose(window) != 1) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shader.id);
        c.glBindVertexArray(vao);
        c.glDrawArrays(c.GL_TRIANGLES, 0, 3);

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn processInput(window: ?*c.GLFWwindow) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }
}
