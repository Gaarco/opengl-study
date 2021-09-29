#version 330 core
in vec3 color;
in vec2 texCoord;

out vec4 FragColor;

uniform sampler2D inTexture1;
uniform sampler2D inTexture2;

void main() {
    FragColor = mix(texture(inTexture1, texCoord), texture(inTexture2, texCoord), 0.2);
}
