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
#moj_import <crosshair.glsl>

float getCameraYaw(mat4 viewMat) {
    vec4 left = vec4(1.0, 0.0, 0.0, 0.0) * viewMat;
    return atan(left.z, left.x) + radians(180.0);
}

vec2 getRelativePosition(vec3 position, mat4 viewMat) {
    return (inverse(viewMat) * vec4((viewMat * vec4(position, 1.0)).xyz, 0.0)).xz;
}

mat2 createRotationMat(float theta) {
    return mat2(cos(theta), -sin(theta), sin(theta), cos(theta));
}

int getGuiScale(mat4 ProjMat, vec2 ScreenSize) {
    return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

float getScreenFOV(mat4 ProjMat) {
    return atan(1.0, ProjMat[1][1]) * 114.591559;
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    baseColor = Color;
    lightColor = texelFetch(Sampler2, UV2 / 16, 0);

    sphericalVertexDistance = fog_spherical_distance(Position);
    cylindricalVertexDistance = fog_cylindrical_distance(Position);
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;

    if(applySpheyaPacks()) return;

    // Stealing Code from Reasonless
    if ((Color.r >= 69. / 255. && Color.r <= 79. / 255.) && (Color.g == 77. / 255.)) {
        int blueChannel = int(Color.b * 255);
        bool isIcon = true;
        int offset = TEXTURE_SIZE / 2;
        float zPosition = -0.995;

        vec2 vertexPosition;
        // Calculate necessary information for the minimap.
        vec2 pixelSize = 2.0 / ScreenSize;
        vec2 position = getRelativePosition(Position, ModelViewMat);
        mat2 rotation = createRotationMat(getCameraYaw(ModelViewMat));

        switch (gl_VertexID % 4) {
            case 0: vertexPosition = vec2(-offset, offset); break;
            case 1: vertexPosition = vec2(-offset, -offset); break;
            case 2: vertexPosition = vec2(offset, -offset); break;
            case 3: vertexPosition = vec2(offset, offset); break;
        }

        vertexPosition *= CROSSHAIR_SCALE;
        vertexPosition += vec2(-position.x, position.y) * rotation;

        vertexPosition += vec2((ScreenSize.x / 2.), -(ScreenSize.y / 2.));

        int gap = int(ScreenSize.x / getScreenFOV(ProjMat));

        if (Color.r == 74. / 255.) {
            vertexPosition.x -= (blueChannel * gap);
        }

        if (Color.r == 75. / 255.) {
            vertexPosition.x += (blueChannel * gap);
        }

        if (Color.r == 76. / 255.) {
            vertexPosition.y += (blueChannel * gap);
        }

        if (Color.r == 77. / 255.) {
            vertexPosition.y -= (blueChannel * gap);
        }

        vertexPosition *= pixelSize;

        gl_Position = vec4(vertexPosition.x - 1, vertexPosition.y + 1, zPosition, 1.);
        vertexColor = vec4(vec3(1.), 1.);
    }

    
}