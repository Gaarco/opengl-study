#version 330 core
in vec3 Normal;
in vec3 FragPosition;
out vec4 FragColor;

uniform vec3 viewPosition;
uniform vec3 lightPosition;
uniform vec3 objectColor;
uniform vec3 lightColor;

void main() {
    float ambientStrength = 0.05;
    vec3 ambient = ambientStrength * lightColor;

    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPosition - FragPosition);

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    float specularStrenght = 0.5;
    vec3 viewDirection = normalize(viewPosition - FragPosition);
    vec3 reflectDirection = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDirection, reflectDirection), 0.0), 32);
    vec3 specular = specularStrenght * spec * lightColor;

    FragColor = vec4((ambient + diffuse + specular) * objectColor, 1.0);
}
