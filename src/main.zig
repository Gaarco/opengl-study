const std = @import("std");
const c = @cImport({
    @cInclude("glad/glad.h");
    @cInclude("GLFW/glfw3.h");
});

pub fn main() anyerror!void {
    _ = c.glfwInit();
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(800, 600, "Learn OpenGL", null, null);
    if (window == null) {
        c.glfwTerminate();
        @panic("Failed to create GLFW window");
    }
    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@ptrCast(c.GLADloadproc, c.glfwGetProcAddress)) != 1) {
        @panic("Failed to initialize GLAD");
    }

    c.glViewport(0, 0, 800, 600);

    while(c.glfwWindowShouldClose(window) != 1) {
        c.glfwSwapBuffers(window);
        c.glfwPollEvents();
    }

    c.glfwTerminate();
}
