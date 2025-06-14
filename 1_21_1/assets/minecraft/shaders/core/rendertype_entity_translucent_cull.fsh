#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec2 texCoord1;
in vec4 normal;

in float blueGem;
in float blueGemOffset;
in vec2 pixelSize;

out vec4 fragColor;

void main() {

    vec2 coord = texCoord0;
    vec4 color = vertexColor;

    vec4 col = texture(Sampler0, texCoord0) * 255.;
    if ( blueGem > 0.5 && blueGem < 1.5 && col.b == 69.) {

        vec2 offset = pixelSize;

        offset.y *= (col.r - 128);
        offset.x *= (col.g - 128) + blueGemOffset;

        coord += offset;

        color = texture(Sampler0, coord) * ColorModulator;
        
    } else if ( blueGem > 1.5 && blueGem < 2.5 && col.b == 69.) {
        
        float transition = mod(blueGemOffset, 1.);
        float realOffset = blueGemOffset - transition;

        vec2 offset = pixelSize;

        offset.y *= (col.r - 128);
        offset.x *= (col.g - 128) + realOffset;

        coord += offset;

        vec4 c1 = texture(Sampler0, coord) * ColorModulator;
        vec4 c2 = texture(Sampler0, coord + vec2(pixelSize.x, 0.)) * ColorModulator;

        color = mix(c1, c2, transition);

    } else {
        color *= texture(Sampler0, coord) * ColorModulator;
    }

    if (color.a < 0.1) {
        discard;
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

}