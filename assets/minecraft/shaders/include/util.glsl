vec2 guiPixel(mat4 ProjMat) {
    return vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
}

int guiScale(mat4 ProjMat, vec2 ScreenSize) {
    return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

float getFOV(mat4 ProjMat) {
    return atan(1.0, ProjMat[1][1]) * 114.591559;
}

float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

vec2 getCenter(sampler2D sampler, int id){
    vec2 shift = textureSize(sampler, 0)/2.;

    shift.x *= ((id >> 1) - 0.5) * -2;
    shift.y *= (((id+1) >> 1 & 1) - 0.5 ) * 2;

    return shift;
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}