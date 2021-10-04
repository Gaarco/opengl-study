const std = @import("std");
const zalgebra = @import("zalgebra");
const c = @import("c.zig");
const panic = std.debug.panic;
const Vec3 = zalgebra.Vec3;
const Mat4 = zalgebra.Mat4;
const ShaderProgram = @import("ShaderProgram.zig");
const Camera = @import("Camera.zig");
const Direction = @import("Camera.zig").Direction;

const window_width = 800;
const window_height = 600;

const vertices = [_]f32{
    -0.5, -0.5, -0.5, 0.0, 0.0,
    0.5,  -0.5, -0.5, 1.0, 0.0,
    0.5,  0.5,  -0.5, 1.0, 1.0,
    0.5,  0.5,  -0.5, 1.0, 1.0,
    -0.5, 0.5,  -0.5, 0.0, 1.0,
    -0.5, -0.5, -0.5, 0.0, 0.0,

    -0.5, -0.5, 0.5,  0.0, 0.0,
    0.5,  -0.5, 0.5,  1.0, 0.0,
    0.5,  0.5,  0.5,  1.0, 1.0,
    0.5,  0.5,  0.5,  1.0, 1.0,
    -0.5, 0.5,  0.5,  0.0, 1.0,
    -0.5, -0.5, 0.5,  0.0, 0.0,

    -0.5, 0.5,  0.5,  1.0, 0.0,
    -0.5, 0.5,  -0.5, 1.0, 1.0,
    -0.5, -0.5, -0.5, 0.0, 1.0,
    -0.5, -0.5, -0.5, 0.0, 1.0,
    -0.5, -0.5, 0.5,  0.0, 0.0,
    -0.5, 0.5,  0.5,  1.0, 0.0,

    0.5,  0.5,  0.5,  1.0, 0.0,
    0.5,  0.5,  -0.5, 1.0, 1.0,
    0.5,  -0.5, -0.5, 0.0, 1.0,
    0.5,  -0.5, -0.5, 0.0, 1.0,
    0.5,  -0.5, 0.5,  0.0, 0.0,
    0.5,  0.5,  0.5,  1.0, 0.0,

    -0.5, -0.5, -0.5, 0.0, 1.0,
    0.5,  -0.5, -0.5, 1.0, 1.0,
    0.5,  -0.5, 0.5,  1.0, 0.0,
    0.5,  -0.5, 0.5,  1.0, 0.0,
    -0.5, -0.5, 0.5,  0.0, 0.0,
    -0.5, -0.5, -0.5, 0.0, 1.0,

    -0.5, 0.5,  -0.5, 0.0, 1.0,
    0.5,  0.5,  -0.5, 1.0, 1.0,
    0.5,  0.5,  0.5,  1.0, 0.0,
    0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5, 0.5,  0.5,  0.0, 0.0,
    -0.5, 0.5,  -0.5, 0.0, 1.0,
};

const cube_positions = [_]Vec3{
    Vec3.new(0.0, 0.0, 0.0),
    Vec3.new(2.0, 5.0, -15.0),
    Vec3.new(-1.5, -2.2, -2.5),
    Vec3.new(-3.8, -2.0, -12.3),
    Vec3.new(2.4, -0.4, -3.5),
    Vec3.new(-1.7, 3.0, -7.5),
    Vec3.new(1.3, -2.0, -2.5),
    Vec3.new(1.5, 2.0, -2.5),
    Vec3.new(1.5, 0.2, -1.5),
    Vec3.new(-1.3, 1.0, -1.5),
};

var camera = Camera.init(Vec3.new(0.0, 0.0, 3.0), Vec3.up(), -90.0, 0.0);
var last_x: f64 = 400.0;
var last_y: f64 = 300.0;

const vertex_shader = @embedFile("shaders/shader.vert");
const fragment_shader = @embedFile("shaders/shader.frag");

pub fn main() anyerror!void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(window_width, window_height, "Learn OpenGL", null, null) orelse {
        c.glfwTerminate();
        panic("Failed to create GLFW window", .{});
    };
    defer c.glfwTerminate();
    c.glfwMakeContextCurrent(window);

    c.glEnable(c.GL_DEPTH_TEST);
    c.glViewport(0, 0, window_width, window_height);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);
    c.glfwSetInputMode(window, c.GLFW_CURSOR, c.GLFW_CURSOR_DISABLED);
    _ = c.glfwSetCursorPosCallback(window, mouseCallback);
    _ = c.glfwSetScrollCallback(window, scrollCallback);

    var vbo: c_uint = undefined;
    var vao: c_uint = undefined;
    c.glGenBuffers(1, &vbo);
    c.glGenVertexArrays(1, &vao);

    c.glBindVertexArray(vao);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), @intToPtr(?*c_void, 0));
    c.glEnableVertexAttribArray(0);
    c.glVertexAttribPointer(1, 2, c.GL_FLOAT, c.GL_FALSE, 5 * @sizeOf(f32), @intToPtr(?*c_void, 3 * @sizeOf(f32)));
    c.glEnableVertexAttribArray(1);

    const shader = ShaderProgram.fromSource(vertex_shader, fragment_shader);

    const container = @embedFile("res/container.jpg");
    const awesomeface = @embedFile("res/awesomeface.png");
    var width: c_int = undefined;
    var height: c_int = undefined;
    var nr_channels: c_int = undefined;

    c.stbi_set_flip_vertically_on_load(@boolToInt(true));

    var texture1: c_uint = undefined;
    c.glGenTextures(1, &texture1);
    c.glBindTexture(c.GL_TEXTURE_2D, texture1);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
    var data: ?*u8 = c.stbi_load_from_memory(container, container.len, &width, &height, &nr_channels, 0);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGB, width, height, 0, c.GL_RGB, c.GL_UNSIGNED_BYTE, data);
    c.glGenerateMipmap(c.GL_TEXTURE_2D);
    c.stbi_image_free(data);

    var texture2: c_uint = undefined;
    c.glGenTextures(1, &texture2);
    c.glBindTexture(c.GL_TEXTURE_2D, texture2);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
    data = c.stbi_load_from_memory(awesomeface, awesomeface.len, &width, &height, &nr_channels, 0);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGB, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, data);
    c.glGenerateMipmap(c.GL_TEXTURE_2D);
    c.stbi_image_free(data);

    shader.use();
    shader.setValue("inTexture1", 0);
    shader.setValue("inTexture2", 1);

    var delta_time: f32 = 0.0;
    var last_frame_time: f32 = 0.0;

    while (c.glfwWindowShouldClose(window) != 1) {
        const current_frame_time = @floatCast(f32, c.glfwGetTime());

        delta_time = current_frame_time - last_frame_time;
        last_frame_time = current_frame_time;

        processInput(window, delta_time);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        c.glActiveTexture(c.GL_TEXTURE0);
        c.glBindTexture(c.GL_TEXTURE_2D, texture1);
        c.glActiveTexture(c.GL_TEXTURE1);
        c.glBindTexture(c.GL_TEXTURE_2D, texture2);

        const view = camera.getViewMatrix();
        const projection = Mat4.perspective(camera.fov, window_width / window_height, 0.1, 100.0);

        shader.use();
        shader.setValue("view", view);
        shader.setValue("projection", projection);
        c.glBindVertexArray(vao);
        for (cube_positions) |pos, index| {
            const model = Mat4.fromTranslate(pos)
                .rotate(@intToFloat(f32, index) * 20.0, Vec3.new(0.5, 1.0, 0.0));

            shader.setValue("model", model);
            c.glDrawArrays(c.GL_TRIANGLES, 0, 36);
        }

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    c.glViewport(0, 0, width, height);
}

fn mouseCallback(window: ?*c.GLFWwindow, pos_x: f64, pos_y: f64) callconv(.C) void {
    _ = window;
    var offset_x = pos_x - last_x;
    var offset_y = last_y - pos_y;
    last_x = pos_x;
    last_y = pos_y;

    camera.processMouseMovement(@floatCast(f32, offset_x), @floatCast(f32, offset_y));
}

fn scrollCallback(window: ?*c.GLFWwindow, offset_x: f64, offset_y: f64) callconv(.C) void {
    _ = window;
    _ = offset_x;
    camera.processMouseScroll(@floatCast(f32, offset_y));
}

fn processInput(window: ?*c.GLFWwindow, delta_time: f32) void {
    if (c.glfwGetKey(window, c.GLFW_KEY_ESCAPE) == c.GLFW_PRESS) {
        c.glfwSetWindowShouldClose(window, 1);
    }

    if (c.glfwGetKey(window, c.GLFW_KEY_W) == c.GLFW_PRESS) {
        camera.processKeyboard(Direction.forward, delta_time);
    }
    if (c.glfwGetKey(window, c.GLFW_KEY_S) == c.GLFW_PRESS) {
        camera.processKeyboard(Direction.backward, delta_time);
    }
    if (c.glfwGetKey(window, c.GLFW_KEY_A) == c.GLFW_PRESS) {
        camera.processKeyboard(Direction.left, delta_time);
    }
    if (c.glfwGetKey(window, c.GLFW_KEY_D) == c.GLFW_PRESS) {
        camera.processKeyboard(Direction.right, delta_time);
    }
}
