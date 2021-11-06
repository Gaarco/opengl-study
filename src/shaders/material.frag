#version 330 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light {
    vec3 position;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    float constant;
    float linear;
    float quadratic;
};

in vec2 TextureCoords;
in vec3 Normal;
in vec3 FragPosition;
out vec4 FragColor;

uniform Material material;
uniform Light light;
uniform vec3 viewPosition;

void main() {
    vec3 ambient = light.ambient * texture(material.diffuse, TextureCoords).rgb;

    vec3 norm = normalize(Normal);
    vec3 lightDirection = normalize(light.position - FragPosition);
    float diff = max(dot(norm, lightDirection), 0.0);
    vec3 diffuse = light.diffuse * diff * texture(material.diffuse, TextureCoords).rgb;

    vec3 viewDirection = normalize(viewPosition - FragPosition);
    vec3 reflectDirection = reflect(-lightDirection, norm);
    float spec = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);
    vec3 specular = light.specular * spec * texture(material.specular, TextureCoords).rgb;

    float distance = length(light.position - FragPosition);
    float attenuation = 1.0 / (light.constant + light.linear * distance + light.quadratic * distance * distance);

    ambient *= attenuation;
    diffuse *= attenuation;
    specular *= attenuation;

    FragColor = vec4(ambient + diffuse + specular, 1.0);
}
