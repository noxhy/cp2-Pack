#version 150
#define FSH
#define RENDERTYPE_TEXT

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:globals.glsl>

uniform sampler2D Sampler0;

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 baseColor;
in vec4 lightColor;

out vec4 fragColor;

#moj_import <spheya_packs_impl.glsl>

void main() {
    if((!((vertexColor.x * 255.0) == 240.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0)) && applySpheyaPacks())
        return;
    if((!((vertexColor.x * 255.0) == 168.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0)) && applySpheyaPacks())
        return;
    if((!((vertexColor.x * 255.0) == 164.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0)) && applySpheyaPacks())
        return;

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if(color.a < 0.1) {
        if(!(((vertexColor.x * 255.0) == 240.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0) || ((vertexColor.x * 255.0) == 168.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0) || ((vertexColor.x * 255.0) == 164.0 && (vertexColor.y * 255.0) == 242.0 && (vertexColor.z * 255.0) == 242.0))) {
            discard;
        }
    }
    fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}