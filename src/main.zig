const std = @import("std");
const za = @import("zalgebra");
const c = @import("c.zig");
const ShaderProgram = @import("ShaderProgram.zig");
const Camera = @import("Camera.zig");
const Direction = @import("Camera.zig").Direction;
const Vec3 = za.Vec3;
const Mat4 = za.Mat4;

const window_width = 800;
const window_height = 600;

const vertices = [_]f32{
    -0.5, -0.5, -0.5, 0.0,  0.0,  -1.0, 0.0, 0.0,
    0.5,  -0.5, -0.5, 0.0,  0.0,  -1.0, 1.0, 0.0,
    0.5,  0.5,  -0.5, 0.0,  0.0,  -1.0, 1.0, 1.0,
    0.5,  0.5,  -0.5, 0.0,  0.0,  -1.0, 1.0, 1.0,
    -0.5, 0.5,  -0.5, 0.0,  0.0,  -1.0, 0.0, 1.0,
    -0.5, -0.5, -0.5, 0.0,  0.0,  -1.0, 0.0, 0.0,

    -0.5, -0.5, 0.5,  0.0,  0.0,  1.0,  0.0, 0.0,
    0.5,  -0.5, 0.5,  0.0,  0.0,  1.0,  1.0, 0.0,
    0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  1.0, 1.0,
    0.5,  0.5,  0.5,  0.0,  0.0,  1.0,  1.0, 1.0,
    -0.5, 0.5,  0.5,  0.0,  0.0,  1.0,  0.0, 1.0,
    -0.5, -0.5, 0.5,  0.0,  0.0,  1.0,  0.0, 0.0,

    -0.5, 0.5,  0.5,  -1.0, 0.0,  0.0,  1.0, 0.0,
    -0.5, 0.5,  -0.5, -1.0, 0.0,  0.0,  1.0, 1.0,
    -0.5, -0.5, -0.5, -1.0, 0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5, -0.5, -1.0, 0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5, 0.5,  -1.0, 0.0,  0.0,  0.0, 0.0,
    -0.5, 0.5,  0.5,  -1.0, 0.0,  0.0,  1.0, 0.0,

    0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
    0.5,  0.5,  -0.5, 1.0,  0.0,  0.0,  1.0, 1.0,
    0.5,  -0.5, -0.5, 1.0,  0.0,  0.0,  0.0, 1.0,
    0.5,  -0.5, -0.5, 1.0,  0.0,  0.0,  0.0, 1.0,
    0.5,  -0.5, 0.5,  1.0,  0.0,  0.0,  0.0, 0.0,
    0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,

    -0.5, -0.5, -0.5, 0.0,  -1.0, 0.0,  0.0, 1.0,
    0.5,  -0.5, -0.5, 0.0,  -1.0, 0.0,  1.0, 1.0,
    0.5,  -0.5, 0.5,  0.0,  -1.0, 0.0,  1.0, 0.0,
    0.5,  -0.5, 0.5,  0.0,  -1.0, 0.0,  1.0, 0.0,
    -0.5, -0.5, 0.5,  0.0,  -1.0, 0.0,  0.0, 0.0,
    -0.5, -0.5, -0.5, 0.0,  -1.0, 0.0,  0.0, 1.0,

    -0.5, 0.5,  -0.5, 0.0,  1.0,  0.0,  0.0, 1.0,
    0.5,  0.5,  -0.5, 0.0,  1.0,  0.0,  1.0, 1.0,
    0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
    0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
    -0.5, 0.5,  0.5,  0.0,  1.0,  0.0,  0.0, 0.0,
    -0.5, 0.5,  -0.5, 0.0,  1.0,  0.0,  0.0, 1.0,
};

var light_position = Vec3.new(0.0, 0.0, 5.0);
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

const diffuse_map_raw = @embedFile("res/container2.png");
const specular_map_raw = @embedFile("res/container2_specular.png");

const obj_vs = @embedFile("shaders/material.vert");
const obj_fs = @embedFile("shaders/material.frag");

pub fn main() anyerror!void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(window_width, window_height, "Learn OpenGL", null, null) orelse {
        c.glfwTerminate();
        std.debug.panic("Failed to create GLFW window", .{});
    };
    defer c.glfwTerminate();
    c.glfwMakeContextCurrent(window);

    c.glEnable(c.GL_DEPTH_TEST);
    c.glViewport(0, 0, window_width, window_height);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);
    c.glfwSetInputMode(window, c.GLFW_CURSOR, c.GLFW_CURSOR_DISABLED);
    _ = c.glfwSetCursorPosCallback(window, mouseCallback);
    _ = c.glfwSetScrollCallback(window, scrollCallback);

    var vao: c_uint = undefined;
    var light_vao: c_uint = undefined;
    c.glGenVertexArrays(1, &vao);
    c.glGenVertexArrays(1, &light_vao);

    var vbo: c_uint = undefined;
    c.glGenBuffers(1, &vbo);
    c.glBindBuffer(c.GL_ARRAY_BUFFER, vbo);
    c.glBufferData(c.GL_ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, c.GL_STATIC_DRAW);

    c.glBindVertexArray(vao);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 8 * @sizeOf(f32), @intToPtr(?*c_void, 0));
    c.glEnableVertexAttribArray(0);
    c.glVertexAttribPointer(1, 3, c.GL_FLOAT, c.GL_FALSE, 8 * @sizeOf(f32), @intToPtr(?*c_void, 3 * @sizeOf(f32)));
    c.glEnableVertexAttribArray(1);
    c.glVertexAttribPointer(2, 2, c.GL_FLOAT, c.GL_FALSE, 8 * @sizeOf(f32), @intToPtr(?*c_void, 6 * @sizeOf(f32)));
    c.glEnableVertexAttribArray(2);
    c.glBindVertexArray(light_vao);
    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 8 * @sizeOf(f32), @intToPtr(?*c_void, 0));
    c.glEnableVertexAttribArray(0);

    var width: c_int = undefined;
    var height: c_int = undefined;
    var nr_channels: c_int = undefined;

    var diffuse_map: c_uint = undefined;
    c.glGenTextures(1, &diffuse_map);
    c.glBindTexture(c.GL_TEXTURE_2D, diffuse_map);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR_MIPMAP_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

    var diffuse_data: ?*u8 = c.stbi_load_from_memory(diffuse_map_raw, diffuse_map_raw.len, &width, &height, &nr_channels, 0);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, diffuse_data);
    c.glGenerateMipmap(c.GL_TEXTURE_2D);

    c.stbi_image_free(diffuse_data);

    var specular_map: c_uint = undefined;
    c.glGenTextures(1, &specular_map);
    c.glBindTexture(c.GL_TEXTURE_2D, specular_map);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR_MIPMAP_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

    var specular_data: ?*u8 = c.stbi_load_from_memory(specular_map_raw, diffuse_map_raw.len, &width, &height, &nr_channels, 0);
    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, specular_data);
    c.glGenerateMipmap(c.GL_TEXTURE_2D);

    c.stbi_image_free(specular_data);

    const obj_shader = ShaderProgram.fromSource(obj_vs, obj_fs);

    var delta_time: f32 = 0.0;
    var last_frame_time: f32 = 0.0;

    while (c.glfwWindowShouldClose(window) != 1) {
        const current_frame_time = @floatCast(f32, c.glfwGetTime());

        delta_time = current_frame_time - last_frame_time;
        last_frame_time = current_frame_time;

        processInput(window, delta_time);

        c.glClearColor(0.2, 0.3, 0.3, 1.0);
        c.glClear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);

        const view = camera.getViewMatrix();
        const projection = Mat4.perspective(camera.fov, window_width / window_height, 0.1, 100.0);

        c.glActiveTexture(c.GL_TEXTURE0);
        c.glBindTexture(c.GL_TEXTURE_2D, diffuse_map);
        c.glActiveTexture(c.GL_TEXTURE1);
        c.glBindTexture(c.GL_TEXTURE_2D, specular_map);

        obj_shader.use();
        obj_shader.setValue("light.position", camera.position);
        obj_shader.setValue("light.direction", camera.front);
        obj_shader.setValue("light.cutOff", std.math.cos(za.toRadians(@as(f32, 12.5))));
        obj_shader.setValue("viewPosition", camera.position);

        obj_shader.setValue("light.ambient", Vec3.new(0.1, 0.1, 0.1));
        obj_shader.setValue("light.diffuse", Vec3.new(0.8, 0.8, 0.8));
        obj_shader.setValue("light.specular", Vec3.new(1.0, 1.0, 1.0));

        obj_shader.setValue("light.constant", 1.0);
        obj_shader.setValue("light.linear", 0.09);
        obj_shader.setValue("light.quadratic", 0.032);

        obj_shader.setValue("material.diffuse", 0);
        obj_shader.setValue("material.specular", 1);
        obj_shader.setValue("material.shininess", 32.0);

        obj_shader.setValue("view", view);
        obj_shader.setValue("projection", projection);

        for (cube_positions) |p, i| {
            const cube_model = Mat4.fromTranslate(p).rotate(20.0 * @intToFloat(f32, i), Vec3.new(1.0, 0.3, 0.5));
            obj_shader.setValue("model", cube_model);
            c.glBindVertexArray(vao);
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
