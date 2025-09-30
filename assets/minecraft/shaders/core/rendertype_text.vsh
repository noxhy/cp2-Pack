#version 150
#define VSH
#define RENDERTYPE_TEXT

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

out vec4 baseColor;
out vec4 lightColor;

#moj_import <spheya_packs_impl.glsl>

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    baseColor = Color;
    lightColor = texelFetch(Sampler2, UV2 / 16, 0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;

    if(applySpheyaPacks())
        return;
}