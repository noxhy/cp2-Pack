bool cp2_apply_crosshair() {
    #define CROSSHAIR_SIZE 8
    #define CROSSHAIR_CORNER int(gl_VertexID % 4)
    #define CROSSHAIR_CORNER_TL 0
    #define CROSSHAIR_CORNER_BL 1
    #define CROSSHAIR_CORNER_BR 2
    #define CROSSHAIR_CORNER_TR 3
    #define CROSSHAIR_SIDE_TOP 1
    #define CROSSHAIR_SIDE_RIGHT 2
    #define CROSSHAIR_SIDE_BOTTOM 3
    #define CROSSHAIR_SIDE_LEFT 4

    #define CROSSHAIR_MAX_HORIZONTAL 16.0
    #define CROSSHAIR_MAX_VERTICAL 64.0
    #define CROSSHAIR_MAX_SPREAD 256.0

    // Discard if the foreground color is #637063 (cpc)
    if (Color.r == (99.0 / 255.0) &&
        Color.g == (112.0 / 255.0) &&
        Color.b == (99.0 / 255.0) &&
        Color.a == (255.0 / 255.0)) {
        vertexColor = vec4(0.0);
        return true;
    }

    vec4 cornerPixel = texture(Sampler0, UV0) * 255.0;
    // Checks for #637032 (cp2 - feel free to change it)
    if (cornerPixel.r != 99.0 || 
        cornerPixel.g != 112.0 ||
        cornerPixel.b != 50.0 || 
        cornerPixel.a == 255.0) {
        return false;
    }

    vec2 screenPixel = 2.0 / ScreenSize;
    vec2 texturePixel = 1.0 / textureSize(Sampler0, 0);

    gl_Position = vec4(
        -1 + (floor(ScreenSize.x / 2) * screenPixel.x), 
        -1 + (floor(ScreenSize.y / 2) * screenPixel.y), 
        -0.999, 
        1.0
    );
    
    switch (CROSSHAIR_CORNER) {
        case CROSSHAIR_CORNER_TL:
            gl_Position.x -= screenPixel.x * (CROSSHAIR_SIZE / 2);
            gl_Position.y += screenPixel.y * (CROSSHAIR_SIZE / 2);
            texCoord0 += texturePixel * vec2(1, 1);
            break;
        case CROSSHAIR_CORNER_BL:
            gl_Position.x -= screenPixel.x * (CROSSHAIR_SIZE / 2);
            gl_Position.y -= screenPixel.y * (CROSSHAIR_SIZE / 2);
            texCoord0 += texturePixel * vec2(1, -1); 
            break;
        case CROSSHAIR_CORNER_BR: 
            gl_Position.x += screenPixel.x * (CROSSHAIR_SIZE / 2);
            gl_Position.y -= screenPixel.y * (CROSSHAIR_SIZE / 2);
            texCoord0 += texturePixel * vec2(-1, -1); 
            break;
        case CROSSHAIR_CORNER_TR: 
            gl_Position.x += screenPixel.x * (CROSSHAIR_SIZE / 2);
            gl_Position.y += screenPixel.y * (CROSSHAIR_SIZE / 2);
            texCoord0 += texturePixel * vec2(-1, 1); 
            break;
    }
    
    // Extract dynamic data from color
    float spread = radians(Color.r * CROSSHAIR_MAX_SPREAD);
    float hAngle = radians((Color.g * CROSSHAIR_MAX_HORIZONTAL * 2) - CROSSHAIR_MAX_HORIZONTAL);
    float vAngle = radians(Color.b * CROSSHAIR_MAX_VERTICAL);
    int zIndex = int(cornerPixel.a) & 15;
    int colorIndex = int(cornerPixel.a) >> 4;

    // Calculate screen offset
    float verticalFov = atan(1.0, ProjMat[1][1]) * 2.0;
    float horizontalFov = atan(1.0, ProjMat[0][0]) * 2.0;
    float horizontalScale = tan(horizontalFov * 0.5);
    float verticalScale = tan(verticalFov * 0.5);
    float offsetX = tan(spread) / horizontalScale;
    float offsetY = offsetX * float(ScreenSize.x / ScreenSize.y);

    // Offset the crosshair based on spread, angle and zIndex
    int crosshairSide = int(round(cornerPixel.a / 10.0));
    switch (crosshairSide) {
        case CROSSHAIR_SIDE_TOP:
            gl_Position.y += offsetY;
            break;
        case CROSSHAIR_SIDE_BOTTOM:
            gl_Position.y -= offsetY;
            break;
        case CROSSHAIR_SIDE_LEFT:
            gl_Position.x -= offsetX;
            break;
        case CROSSHAIR_SIDE_RIGHT:
            gl_Position.x += offsetX;
            break;
    }
    gl_Position.x += tan(hAngle) / horizontalScale;
    gl_Position.y -= tan(vAngle) / verticalScale;
    gl_Position.z += 0.0001 * float(zIndex);

    // Apply the color from a predefined palette (4-bit)
    vec3 elementColor = vec3(255.0);
    switch (colorIndex) {
        case 0: 
            elementColor = vec3(255.0, 255.0, 255.0);
            break;
    }
    vertexColor = vec4(elementColor / 255.0, 1.0);
    return true;
}
