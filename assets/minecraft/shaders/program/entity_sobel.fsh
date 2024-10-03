#version 150

#define FLASH vec3(212., 212., 212.) // #D4D4D4
#define VEIL vec3(69., 67., 38.) // #454326

#define TEAM_DM vec3(255., 205., 40.)// #ffcd28
#define TEAM_T vec3(237., 76., 103.) // #ed4c67
#define TEAM_CT vec3(38., 222., 129.) // #26de81

#define LIGHT_PURPLE vec3(255., 85., 255.)
#define DARK_PURPLE vec3(170., 0., 170.)
#define WHITE vec3(255., 255., 255.)

uniform sampler2D DiffuseSampler;
uniform float Time;
uniform vec2 ScreenSize;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

bool isColor(vec4 originColor, vec3 color) {
    return (originColor*255.).xyz == color;
}

void main(){
    fragColor = texture(DiffuseSampler, texCoord);

    if (isColor(fragColor, LIGHT_PURPLE)) {fragColor.a = 0.2;}
    if (isColor(fragColor, DARK_PURPLE)) {fragColor.rgba = vec4(0.6, 0.0, 0.4, 0.7);}
    if (isColor(fragColor, WHITE)) {fragColor.a = 0.2;}

    if (isColor(fragColor, FLASH)) {fragColor.rgb = vec3(1.,1.,1.);}
    if (isColor(fragColor, VEIL)) {

            float trans = length((vec2(gl_FragCoord.x - ScreenSize.x / 2, gl_FragCoord.y - ScreenSize.y / 2)) / ScreenSize.x)/6;
            trans += 0.1;

            fragColor.rgba = vec4(0.137,0.35,0.91,trans);
        }
    // DO NOT UNCOMMENT ITS THE SEIZURE ANTI F1
    // if (isColor(fragColor, FLASH)) {fragColor.rgb *= mod(Time*1000, 2);}

    if (isColor(fragColor,TEAM_CT) || isColor(fragColor,TEAM_T) || isColor(fragColor,TEAM_DM)) {fragColor.a = 0.3;}
    
}