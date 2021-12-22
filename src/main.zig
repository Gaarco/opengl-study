const std = @import("std");
const gl = @import("gl33");
const za = @import("zalgebra");
const c = @import("c.zig");
const Shader = @import("Shader.zig");
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

const point_light_positions = [_]Vec3{
    Vec3.new(0.7, 0.2, 2.0),
    Vec3.new(2.3, -3.3, -4.0),
    Vec3.new(-4.0, 2.0, -12.0),
    Vec3.new(0.0, 0.0, -3.0),
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

const diffuse_map_raw = @embedFile("res/container2.png");
const specular_map_raw = @embedFile("res/container2_specular.png");

const obj_vs = @embedFile("shaders/material.vert");
const obj_fs = @embedFile("shaders/material.frag");
const light_vs = @embedFile("shaders/light_cube.vert");
const light_fs = @embedFile("shaders/light_cube.frag");

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

    try gl.load({}, getProcAddress);
    gl.enable(gl.DEPTH_TEST);
    gl.viewport(0, 0, window_width, window_height);
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);
    c.glfwSetInputMode(window, c.GLFW_CURSOR, c.GLFW_CURSOR_DISABLED);
    _ = c.glfwSetCursorPosCallback(window, mouseCallback);
    _ = c.glfwSetScrollCallback(window, scrollCallback);

    var vao: c_uint = undefined;
    var light_vao: c_uint = undefined;
    gl.genVertexArrays(1, &vao);
    gl.genVertexArrays(1, &light_vao);

    var vbo: c_uint = undefined;
    gl.genBuffers(1, &vbo);
    gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
    gl.bufferData(gl.ARRAY_BUFFER, vertices.len * @sizeOf(f32), &vertices, gl.STATIC_DRAW);

    gl.bindVertexArray(vao);
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @intToPtr(?*anyopaque, 0));
    gl.enableVertexAttribArray(0);
    gl.vertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @intToPtr(?*anyopaque, 3 * @sizeOf(f32)));
    gl.enableVertexAttribArray(1);
    gl.vertexAttribPointer(2, 2, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @intToPtr(?*anyopaque, 6 * @sizeOf(f32)));
    gl.enableVertexAttribArray(2);
    gl.bindVertexArray(light_vao);
    gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 8 * @sizeOf(f32), @intToPtr(?*anyopaque, 0));
    gl.enableVertexAttribArray(0);

    var width: c_int = undefined;
    var height: c_int = undefined;
    var nr_channels: c_int = undefined;

    var diffuse_map: c_uint = undefined;
    gl.genTextures(1, &diffuse_map);
    gl.bindTexture(gl.TEXTURE_2D, diffuse_map);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    var diffuse_data: ?*u8 = c.stbi_load_from_memory(diffuse_map_raw, diffuse_map_raw.len, &width, &height, &nr_channels, 0);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, diffuse_data);
    gl.generateMipmap(gl.TEXTURE_2D);

    c.stbi_image_free(diffuse_data);

    var specular_map: c_uint = undefined;
    gl.genTextures(1, &specular_map);
    gl.bindTexture(gl.TEXTURE_2D, specular_map);

    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
    gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

    var specular_data: ?*u8 = c.stbi_load_from_memory(specular_map_raw, diffuse_map_raw.len, &width, &height, &nr_channels, 0);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, specular_data);
    gl.generateMipmap(gl.TEXTURE_2D);

    c.stbi_image_free(specular_data);

    const obj_shader = Shader.fromMemory(obj_vs, obj_fs);
    const light_shader = Shader.fromMemory(light_vs, light_fs);

    var delta_time: f32 = 0.0;
    var last_frame_time: f32 = 0.0;

    obj_shader.use();
    gl.uniform1i(obj_shader.getUniformLocation("material.diffuse"), 0);
    gl.uniform1i(obj_shader.getUniformLocation("material.specular"), 1);

    while (c.glfwWindowShouldClose(window) != 1) {
        const current_frame_time = @floatCast(f32, c.glfwGetTime());

        delta_time = current_frame_time - last_frame_time;
        last_frame_time = current_frame_time;

        processInput(window, delta_time);

        gl.clearColor(0.2, 0.3, 0.3, 1.0);
        gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

        const view = camera.getViewMatrix();
        const projection = Mat4.perspective(camera.fov, window_width / window_height, 0.1, 100.0);

        gl.activeTexture(gl.TEXTURE0);
        gl.bindTexture(gl.TEXTURE_2D, diffuse_map);
        gl.activeTexture(gl.TEXTURE1);
        gl.bindTexture(gl.TEXTURE_2D, specular_map);

        obj_shader.use();
        inline for (point_light_positions) |p, _i| {
            const i = comptime std.fmt.comptimePrint("{}", .{_i});
            gl.uniform3f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].position"), p.x, p.y, p.z);
            gl.uniform3f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].ambient"), 0.05, 0.05, 0.05);
            gl.uniform3f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].diffuse"), 0.8, 0.8, 0.8);
            gl.uniform3f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].specular"), 1.0, 1.0, 1.0);
            gl.uniform1f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].constant"), 1.0);
            gl.uniform1f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].linear"), 0.09);
            gl.uniform1f(obj_shader.getUniformLocation("pointLights[" ++ i ++ "].quadratic"), 0.032);
        }
        gl.uniform3f(obj_shader.getUniformLocation("directionalLight.direction"), -0.2, -1.0, -0.3);
        gl.uniform3f(obj_shader.getUniformLocation("directionalLight.ambient"), 0.05, 0.05, 0.05);
        gl.uniform3f(obj_shader.getUniformLocation("directionalLight.diffuse"), 0.4, 0.4, 0.4);
        gl.uniform3f(obj_shader.getUniformLocation("directionalLight.specular"), 0.5, 0.5, 0.5);
        gl.uniform3f(obj_shader.getUniformLocation("spotLight.position"), camera.position.x, camera.position.y, camera.position.z);
        gl.uniform3f(obj_shader.getUniformLocation("spotLight.direction"), camera.front.x, camera.front.y, camera.front.z);
        gl.uniform3f(obj_shader.getUniformLocation("spotLight.ambient"), 0.0, 0.0, 0.0);
        gl.uniform3f(obj_shader.getUniformLocation("spotLight.diffuse"), 1.0, 1.0, 1.0);
        gl.uniform3f(obj_shader.getUniformLocation("spotLight.specular"), 1.0, 1.0, 1.0);
        gl.uniform1f(obj_shader.getUniformLocation("spotLight.constant"), 1.0);
        gl.uniform1f(obj_shader.getUniformLocation("spotLight.linear"), 0.09);
        gl.uniform1f(obj_shader.getUniformLocation("spotLight.quadratic"), 0.032);
        gl.uniform1f(obj_shader.getUniformLocation("spotLight.cutOff"), std.math.cos(za.toRadians(@as(f32, 12.5))));
        gl.uniform1f(obj_shader.getUniformLocation("spotLight.outerCutOff"), std.math.cos(za.toRadians(@as(f32, 15.0))));
        gl.uniform1f(obj_shader.getUniformLocation("material.shininess"), 32.0);
        gl.uniform3f(obj_shader.getUniformLocation("viewPosition"), camera.position.x, camera.position.y, camera.position.z);

        gl.uniformMatrix4fv(obj_shader.getUniformLocation("view"), 1, gl.FALSE, view.getData());
        gl.uniformMatrix4fv(obj_shader.getUniformLocation("projection"), 1, gl.FALSE, projection.getData());

        for (cube_positions) |p, i| {
            const model = Mat4.fromTranslate(p).rotate(20.0 * @intToFloat(f32, i), Vec3.new(1.0, 0.3, 0.5));
            gl.uniformMatrix4fv(obj_shader.getUniformLocation("model"), 1, gl.FALSE, model.getData());
            gl.bindVertexArray(vao);
            gl.drawArrays(gl.TRIANGLES, 0, 36);
        }

        light_shader.use();
        gl.uniformMatrix4fv(light_shader.getUniformLocation("view"), 1, gl.FALSE, view.getData());
        gl.uniformMatrix4fv(light_shader.getUniformLocation("projection"), 1, gl.FALSE, projection.getData());
        for (point_light_positions) |p| {
            const model = Mat4.fromScale(Vec3.set(0.2)).translate(p);
            gl.uniformMatrix4fv(light_shader.getUniformLocation("model"), 1, gl.FALSE, model.getData());
            gl.bindVertexArray(vao);
            gl.drawArrays(gl.TRIANGLES, 0, 36);
        }

        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }
}

fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.C) void {
    _ = window;
    gl.viewport(0, 0, width, height);
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

fn getProcAddress(ctx: void, entry_point: [:0]const u8) ?*const anyopaque {
    _ = ctx;
    return c.glfwGetProcAddress(entry_point);
}
