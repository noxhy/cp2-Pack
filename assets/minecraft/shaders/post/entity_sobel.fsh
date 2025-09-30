#version 150

#define FLASH vec3(212., 212., 212.) // #D4D4D4
#define VEIL vec3(69., 67., 38.) // #454326

#define TEAM_DM vec3(255., 205., 40.)// #ffcd28
#define TEAM_T vec3(237., 76., 103.) // #ed4c67
#define TEAM_CT vec3(38., 222., 129.) // #26de81

#define LIME vec3(85., 255., 85.) // #55FF55
#define RED vec3(255., 85., 85.) // #FF5555
#define GOLD vec3( 255., 170., 0. ) // #FFAA00
#define LIGHT_PURPLE vec3(255., 85., 255.)
#define DARK_PURPLE vec3(170., 0., 170.)
#define WHITE vec3(255., 255., 255.)

#moj_import <minecraft:globals.glsl>

uniform sampler2D InSampler;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

bool isColor(vec4 originColor, vec3 color) {
    return (originColor * 255.).xyz == color;
}

void main(){
    fragColor = texture(InSampler, texCoord);

    if (isColor(fragColor, LIGHT_PURPLE)) {fragColor.a = 0.2;}
    if (isColor(fragColor, DARK_PURPLE)) {fragColor.rgba = vec4(0.6, 0.0, 0.4, 0.7);}
    if (isColor(fragColor, WHITE)) {fragColor.a = 0.2;}

    if (isColor(fragColor, FLASH)) {fragColor.rgb = vec3(1.,1.,1.);}
    if (isColor(fragColor, VEIL))
    {

            float trans = length((vec2(gl_FragCoord.x - ScreenSize.x / 2, gl_FragCoord.y - ScreenSize.y / 2)) / ScreenSize.x)/6;
            trans += 0.1;

            fragColor.rgba = vec4(0.137,0.35,0.91,trans);
    }
    
    // DO NOT UNCOMMENT ITS THE SEIZURE ANTI F1
    // if (isColor(fragColor, FLASH)) {fragColor.rgb *= mod(GameTime * 1000., 2);}

    if (isColor(fragColor,TEAM_CT) || isColor(fragColor,TEAM_T) || isColor(fragColor,TEAM_DM) || isColor(fragColor, GOLD) || isColor(fragColor, LIME) || isColor(fragColor, RED))
    {

        vec4 center = texture(InSampler, texCoord);
        vec4 left = texture(InSampler, texCoord - vec2(oneTexel.x, 0.0));
        vec4 right = texture(InSampler, texCoord + vec2(oneTexel.x, 0.0));
        vec4 up = texture(InSampler, texCoord - vec2(0.0, oneTexel.y));
        vec4 down = texture(InSampler, texCoord + vec2(0.0, oneTexel.y));
        float leftDiff  = abs(center.a - left.a);
        float rightDiff = abs(center.a - right.a);
        float upDiff    = abs(center.a - up.a);
        float downDiff  = abs(center.a - down.a);
        float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
        vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;

        if (total == 0.) {fragColor.a = 0.3;}
        else {fragColor = vec4(outColor * 0.5, total);}

    }
    
}