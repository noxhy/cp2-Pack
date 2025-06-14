#version 150

#moj_import <light.glsl>
#moj_import <fog.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in vec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;

uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out vec2 texCoord1;
out vec2 texCoord2;
out vec4 normal;

out float blueGem;
out float blueGemOffset;
out vec2 pixelSize;

float GameTimeSeconds = GameTime * 1200;

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(IViewRotMat * Position, FogShape);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color) * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
    texCoord1 = UV1;
    texCoord2 = UV2;
    normal = ProjMat * ModelViewMat * vec4(Normal, 0.0);
    
    int id = gl_VertexID%4;

    blueGem = 0.;
    vec4 col = texture(Sampler0, UV0) * 255.;

    if((col.g == 69.) && (col.b == 101. || col.b == 102. || col.b == 103. || col.b == 104.)) {
        if (col.a == 254) {
            blueGem = 1.;

            pixelSize = vec2(1. / textureSize(Sampler0, 0));

            vec2 offset = pixelSize;
            if (col.b == 103. || col.b == 104.) {offset.x *= -1;}
            if (col.b == 102. || col.b == 103.) {offset.y *= -1;}

            texCoord0 += offset;

            blueGemOffset = mod(Color.r * 255., col.r);
        }
        if (col.a == 253) {
            blueGem = 2.;

            pixelSize = vec2(1. / textureSize(Sampler0, 0));

            vec2 offset = pixelSize;
            if (col.b == 103. || col.b == 104.) {offset.x *= -1;}
            if (col.b == 102. || col.b == 103.) {offset.y *= -1;}

            texCoord0 += offset;
            blueGemOffset = mod(Color.r * 255. + GameTimeSeconds * 10, col.r);
        }
    }
}