#version 150

#moj_import <fog.glsl>
#moj_import <colours.glsl>
#moj_import <util.glsl>

#define PI 3.14159265


uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float GameTime;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;
in vec4 Color;
in boolean is_shadow;

out vec4 fragColor;

float GameTimeSeconds = GameTime * 1200;

void main() {

    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;

    if (color.a < 0.1)
    {
        discard;
    }

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if ( is_shadow )
    {

        float outlineThickness = 20.;
        vec4 outlineColor = vec4( 1., 0., 0., 1. );

        fragColor = outlineColor;
        return;

        for ( float x = -outlineThickness; x <= outlineThickness; x++)
        {

            for ( float y = -outlineThickness; y <= outlineThickness; y++ )
            {

                // Calculate the neighbor coordinates
                vec2 offset = vec2(x, y) / textureSize( Sampler0, 0 ); // Normalize by texture size
                vec4 neighborColor = texture( Sampler0, texCoord0 + offset ) * vertexColor * ColorModulator;
                
                // If any neighbor pixel is part of the text, apply the outline color
                if (neighborColor.a > 0.0)
                {
                    fragColor = outlineColor; // Set to outline color
                    break; // Exit loop if outline is found
                }

            }

            if (fragColor.a > 0.0) break; // Exit outer loop if outline is already found
        }

    }

}
