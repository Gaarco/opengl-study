const std = @import("std");
const c = @cImport({
    @cInclude("epoxy/gl.h");
    @cInclude("GLFW/glfw3.h");
});

const vertices = [_]f32{
    0.5, -0.5, 0.0, 1.0, 0.0, 0.0,
    -0.5, -0.5, 0.0, 0.0, 1.0, 0.0,
    0.0, 0.5, 0.0, 0.0, 0.0, 1.0,
};

pub fn main() anyerror!void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(800, 600, "Learn OpenGL", null, null) orelse {
        c.glfwTerminate();
        @panic("Failed to create GLFW window");
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

    const vertexShaderSource = @embedFile("shader.vert");
    const vertexShader = c.glCreateShader(c.GL_VERTEX_SHADER);
    defer c.glDeleteShader(vertexShader);
    c.glShaderSource(vertexShader, 1, @ptrCast([*c]const [*c]const u8, &vertexShaderSource), null);
    c.glCompileShader(vertexShader);
    var success: c_int = undefined;
    c.glGetShaderiv(vertexShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        @panic("Error: shader vertex compilation failedn");
    }

    const fragmentShaderSource = @embedFile("shader.frag");
    const fragmentShader = c.glCreateShader(c.GL_FRAGMENT_SHADER);
    defer c.glDeleteShader(fragmentShader);
    c.glShaderSource(fragmentShader, 1, @ptrCast([*c]const [*c]const u8, &fragmentShaderSource), null);
    c.glCompileShader(fragmentShader);
    c.glGetShaderiv(fragmentShader, c.GL_COMPILE_STATUS, &success);
    if (success == 0) {
        @panic("Error: shader fragment compilation failedn");
    }

    var shaderProgram: c_uint = c.glCreateProgram();
    c.glAttachShader(shaderProgram, vertexShader);
    c.glAttachShader(shaderProgram, fragmentShader);
    c.glLinkProgram(shaderProgram);

    c.glGetProgramiv(shaderProgram, c.GL_LINK_STATUS, &success);
    if (success == 0) {
        @panic("Error: shader program link failed");
    }

    while (c.glfwWindowShouldClose(window) != 1) {
        processInput(window);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT);

        c.glUseProgram(shaderProgram);
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
