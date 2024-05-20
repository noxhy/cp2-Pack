#version 150

#moj_import <fog.glsl>
#moj_import <colours.glsl>
#moj_import <util.glsl>

#define BLUR 1.2

uniform sampler2D Sampler0;

uniform mat4 ProjMat;
uniform mat3 IViewRotMat;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;
uniform float GameTime;

in float vertexDistance;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
in vec2 texCoord0;
in vec4 normal;

out vec4 fragColor;

float Time = GameTime * 1200.;

// ---------------------------------------------
// https://www.shadertoy.com/view/wslyWs

vec3 Sky(vec3 ro, vec3 rd){

    const float SC = 1e5;
    float t = Time * 0.03;

    // Calculate sky plane
    float dist = (SC - ro.y) / rd.y; 
    vec2 p = (ro + dist * rd).xz;
    p *= 1.2 / SC;
   
    // from iq's shader, https://www.shadertoy.com/view/MdX3Rr
    vec3 lightDir = normalize(vec3(0.5, -0.1, 0.));
    float sundot = clamp(dot(normalize(floor(rd*64)),lightDir), 0.0, 1.0);

    vec3 cloudCol = vec3(1.);
    vec3 sunCol = vec3(1.,.9,.8);
    vec3 skyCol = vec3(.5,.7,.85) - rd.y*rd.y*0.2;
    skyCol = mix( skyCol, 0.85 * vec3(0.7,0.75,0.85), pow( 1.0 + min(rd.y, 0.0), 4.0 ) );
    
    // sun
    skyCol = mix( skyCol, sunCol, smoothstep(0., 1., pow(sundot,256.)));
    skyCol += vec3(1.,1.,1.) * pow(sundot,1024.);
    
    // clouds
    float den = fbm(vec2(floor((p.x - t)*16)/16., floor((p.y - t*1.4)*16)/16));
    skyCol = mix( skyCol, cloudCol, smoothstep(.5, 1., den));

    den = fbm(vec2(floor((p.x/3 - t)*20)/20, floor((p.y/3 - t*.8)*20)/20));
    skyCol = mix( skyCol, cloudCol, smoothstep(.4, 1., den));
    
    // horizon
    skyCol = mix( skyCol, 0.68 * vec3(0.4, 0.5, 0.8), pow( 1.0 + min(rd.y, 0.0), 16.0 ) );
    
    return skyCol;
}

// ---------------------------------------------

#define MAX_ITER 4

vec3 Water(vec3 ro, vec3 rd){

    const float SC = 1e5;
    float t = Time * 0.3;

    // Calculate water plane
    float dist = (SC - ro.y) / rd.y;
    vec2 p = (ro + dist * rd).xz;
    p *= 1.2 / SC;
    
    //vec3 waterCol = vec3(28., 88., 150.)/255. + rd.y*rd.y*0.2;

    vec2 i = vec2(p);
	float c = 0.;
	float inten = .005;

	for (int n = 0; n < MAX_ITER; n++) {
		c += fbm(vec2(floor(p.x*10)/6 +t*cos(n), floor(p.y*10)/6 +t*sin(n)));
	}
	c /= float(MAX_ITER);
	//c = 1.17-pow(c, 1.4);
	c = pow(abs(c), 3.) + smoothstep(0., 0.3, pow(c,8.));
    vec3 waterCol = mix(vec3(0.1, 0.2, 0.4), vec3(0.4, 1., 1.), c);

    waterCol = mix(waterCol, 0.85 * vec3(0.7,0.75,0.85), pow( 1.0 - max(rd.y, 0.0), 4.0 ));

    // water

    //float height = fbm(vec2(p.x*5. - t, p.y*5. - t));
    //height += fbm(vec2(p.x*5. + t, p.y*5. - t*1.4));
    //height += fbm(vec2(p.x*5. - t, p.y*5. + t*1.4));

    //waterCol = mix( waterCol, vec3(1.,1.,1.),step(1.5,height));

    // horizon
    //waterCol = mix( waterCol, 0.68 * vec3(0.4, 0.5, 0.8), pow( 1.0 - max(rd.y, 0.0), 16.0 ) );
    
    return waterCol;
}

void main() {

    vec4 color = texture(Sampler0, texCoord0);
    if (color.a < 0.1) {
        discard;
    }

    if (isColor(color, SKYBOX)) {

        float fov = getFOV(ProjMat);

        vec2 loc = gl_FragCoord.xy;
        loc = floor(loc/4)*4;

        vec2 uv = (loc - .5 * ScreenSize.xy) / ScreenSize.y;
        vec3 ro = vec3(0.0, 0.0, 0.0);
        vec3 rd = normalize(IViewRotMat * vec3(-uv * (pow(1.012,fov) - .9), 1.0));

        vec3 sky = Sky(ro, rd);
        vec3 water = Water(ro, rd);

        vec3 col;
        col += water * max(0.5 + 0.5 * pow(rd.y, BLUR),0);
        col += water * max(0.5 - 0.5 * pow(-rd.y, BLUR),0);
        col += sky * max(0.5 - 0.5 * pow(rd.y, BLUR),0);
        col += sky * max(0.5 + 0.5 * pow(-rd.y, BLUR),0);
        
        fragColor = vec4(col,1.);

        return;
    }

    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}