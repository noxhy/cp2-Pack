#define AMMO vec3( 230., 211., 255. ) // #e6d3ff

#define HEALTH vec3( 77., 102., 21. ) // #4d6615
#define HEALTH_BG vec3( 77., 102., 22. ) // #4d6616
#define HEALTH_NUMBERS vec3( 77., 102., 23. ) // #4d6617

#define ARMOR vec3( 51., 22., 6. ) // #331606
#define ARMOR_BG vec3( 51., 22., 7. ) // #331607
#define ARMOR_NUMBERS vec3( 51., 22., 8. ) // #331608

#define GRAY vec3( 64., 64., 64. ) // #404040

#define CROSSHAIR vec3( 51., 4., 51. ) // #330433
#define TIMER_BACKGROUND vec3( 51., 43., 30. ) // #332b1e
#define TIMER vec3( 51., 31.,  42. ) // #331f2a

#define KILL_COUNT vec3( 112., 94., 48. ) // #705e30

#define TERRORIST_SCORE vec3( 51., 35., 42. ) // #33232a
#define TERRORIST_ICONS vec3( 51., 35., 46. ) // #33232e

#define COUNTER_TERRORIST_SCORE vec3( 48., 35., 51. ) // #302333
#define COUNTER_TERRORIST_ICONS vec3( 48., 35., 52. ) // #302334

#define SCOPE vec3( 51., 51., 51. ) // #333333

#define SKYBOX vec3(76., 64., 22.) // #4C4016

bool isColor(vec4 originColor, vec3 color) {
    return (originColor*255.).xyz == color;
}

vec4 getShadow(vec3 color) {
    return vec4(floor(color / 4.) / 255., 1);
}

vec4 getShadowAlt(vec3 color) {
    return vec4(ceil(color / 4.) / 255., 1);
}

bool isShadow(vec4 originColor, vec3 color) {
    return round(originColor.xyz*255.) == round(getShadow(color).xyz*255.) || round(originColor.xyz*255.) == round(getShadowAlt(color).xyz*255.);
}

bool isEither(vec4 originColor, vec3 color) {
    return isShadow(originColor, color) || isColor(originColor, color);
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}