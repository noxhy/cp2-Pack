#version 150

#moj_import <fog.glsl>
#moj_import <colours.glsl>
#moj_import <util.glsl>

#define PI 3.14159265

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform float GameTime;
uniform int FogShape;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

float GameTimeSeconds = GameTime * 1200;

void main()
{

    gl_Position = ProjMat * ModelViewMat * vec4( Position, 1.0 );

    vertexDistance = fog_distance( ModelViewMat, IViewRotMat * Position, FogShape );
    vertexColor = Color * texelFetch( Sampler2, UV2 / 16, 0 );
    texCoord0 = UV0;

    int gui_scale = guiScale( ProjMat, ScreenSize );
    int id = gl_VertexID % 4;

    if ( isEither( Color, HEALTH ) || isEither( Color, HEALTH_BG ) )
    {

        gl_Position.x -= ( gui_scale * 182 ) / ScreenSize.x;
        gl_Position.y -= ( gui_scale * 82 ) / ScreenSize.y;

        if ( isColor( Color, HEALTH ) ) vertexColor.rgb = hsv2rgb( vec3( ( sin( GameTimeSeconds * -2.5 + gl_Position.x * 30 ) -0.5 )/ 36., 0.73, 0.80 ) );

        if ( isColor( Color, HEALTH_BG ) ) vertexColor.rgb = vec3(1., 1., 1.);

        if ( isShadow( Color, HEALTH ) || isShadow( Color, HEALTH_BG ) ) vertexColor.a = 0.;

    }

    if ( isEither( Color, HEALTH_NUMBERS ) )
    {

        gl_Position.x -= ( gui_scale * 134 ) / ScreenSize.x;
        gl_Position.y -= ( gui_scale * 78 ) / ScreenSize.y;

        if ( isColor( Color, HEALTH_NUMBERS ) ) vertexColor = vec4( 1., 0.9, 0.9, 0.65 );

        if ( isShadow( Color, HEALTH_NUMBERS ) ) vertexColor.a = 0.;

    }


    if ( isEither( Color, ARMOR ) || isEither( Color, ARMOR_BG ) )
    {

        gl_Position.x += ( gui_scale * 22 ) / ScreenSize.x;
        gl_Position.y -= ( gui_scale * 82 ) / ScreenSize.y;

        if ( isColor( Color, ARMOR ) ) vertexColor.rgb = hsv2rgb( vec3( ( sin( GameTimeSeconds * -2.5 + gl_Position.x * 30 ) -15. ) / 36., 0.73, 0.80 ) );

        if ( isColor( Color, ARMOR_BG ) ) vertexColor.rgb = vec3( 1., 1., 1. );

        if ( isShadow( Color, ARMOR ) || isShadow( Color, ARMOR_BG ) ) vertexColor.a = 0.;

    }

    if ( isEither( Color, ARMOR_NUMBERS ) )
    {

        gl_Position.x += ( gui_scale * 70 ) / ScreenSize.x;
        gl_Position.y -= ( gui_scale * 78 ) / ScreenSize.y;

        if ( isColor( Color, ARMOR_NUMBERS ) ) vertexColor = vec4( 0.9, 0.9, 1., 0.65 );

        if ( isShadow( Color, ARMOR_NUMBERS ) ) vertexColor.a = 0.;

    }

    if( isEither( Color, KILL_COUNT ) )
    {

        gl_Position.x -= ( gui_scale * 18 ) / ScreenSize.x;

        if ( isColor( Color, KILL_COUNT ) ) vertexColor.rgb = vec3( 1., 1., 1. );

        if ( isShadow( Color, KILL_COUNT ) ) vertexColor.a = 0.;

    }

    if ( isEither( Color, AMMO ) )
    {

        vec2 center = getCenter( Sampler2, id );
        center.y /= ScreenSize.y / gui_scale * 1.;

        gl_Position.x += ( gui_scale * 46. ) / ScreenSize.x;
        gl_Position.y = 0.-center.y-( gui_scale * 46.5 ) / ScreenSize.y;
        
        vertexColor = vec4( 1., 1., 1., 0.7 );

        if ( isShadow( Color, AMMO ) )
        {

            vertexColor = vec4( 0.2, 0.2, 0.2, 0.7 );
            gl_Position.y -= ( gui_scale * 2 ) / ScreenSize.y;

        }

    }

    if( isEither( Color, CROSSHAIR ) )
    {

        vec2 center = getCenter( Sampler2, id );
        center.y /= ScreenSize.y / gui_scale * 1.;

        gl_Position.y += ( gui_scale * 33 ) / ScreenSize.y;

        if ( isColor( Color, CROSSHAIR ) ) vertexColor.rgb = vec3( 1., 1., 1. );

        if ( isShadow( Color, CROSSHAIR ) ) vertexColor.a = 0.;

    }

    if( isEither( Color, TIMER_BACKGROUND ) )
    {

        if ( isColor( Color, TIMER_BACKGROUND ) ) vertexColor = vec4( 0., 0., 0., 0.4 );

        if ( isShadow( Color, TIMER_BACKGROUND ) ) vertexColor.a = 0.;

    }

    if( isEither( Color, TIMER ) )
    {

        if ( isColor( Color, TIMER ) ) vertexColor.rgb = vec3( 1., 1., 1. );

        if ( isShadow( Color, TIMER ) ) vertexColor.a = 0.;

    }

    if ( isColor( Color, GRAY ) && Position.z == 0 )
    {

        vertexColor.rgb = vec3(1., 1., 1.);

    }


    if ( isEither( Color, COUNTER_TERRORIST_SCORE ) )
    {

        gl_Position.x -= ( gui_scale * 8 ) / ScreenSize.x;
        gl_Position.x -= ( gui_scale * 6 ) / ScreenSize.x;
        gl_Position.y += ( gui_scale * 14 ) / ScreenSize.y;


        if ( isColor( Color, COUNTER_TERRORIST_SCORE ) ) vertexColor.rgb = vec3( 0.15, 0.87, 0.51 );

        if ( isShadow( Color, COUNTER_TERRORIST_SCORE ) ) vertexColor.a = 0.;

    }

    if ( isEither( Color, COUNTER_TERRORIST_ICONS ) )
    {

        if ( isColor( Color, COUNTER_TERRORIST_SCORE ) ) vertexColor.rgb = vec3( 0.15, 0.87, 0.51 );

        if ( isShadow( Color, COUNTER_TERRORIST_SCORE ) )
        {

            gl_Position.x -= ( gui_scale * 2 ) / ScreenSize.x;

            vertexColor = getShadow( vec3( 0.15, 0.87, 0.51 ) );


        }

    }


    if ( isEither( Color, TERRORIST_SCORE ) )
    {

        gl_Position.x += ( gui_scale * 8 ) / ScreenSize.x;
        gl_Position.x += ( gui_scale * 8 ) / ScreenSize.x;
        gl_Position.y += ( gui_scale * 14 ) / ScreenSize.y;


        if ( isColor( Color, TERRORIST_SCORE ) ) vertexColor.rgb = vec3( 0.92, 0.3, 0.4 );

        if ( isShadow( Color, TERRORIST_SCORE ) ) vertexColor.a = 0.;

    }

    if ( isEither( Color, TERRORIST_ICONS ) )
    {

        if ( isColor( Color, TERRORIST_ICONS ) ) vertexColor.rgb = vec3( 0.92, 0.3, 0.4 );

        if ( isShadow( Color, TERRORIST_ICONS ) )
        {

            gl_Position.x += ( gui_scale * 2 ) / ScreenSize.x;

            vertexColor = getShadow( vec3( 0.92, 0.3, 0.4 ) );

        }

    }

    if ( isEither( Color, SCOPE ) )
    {

        if ( isColor( Color, SCOPE ) )
        {

            gl_Position.x += ( gui_scale * 7 ) / ScreenSize.x;
            gl_Position.y += ( gui_scale * 7 ) / ScreenSize.y;

            vertexColor.rgb = vec3( 1., 1., 1. );

        }

        if ( isShadow( Color, SCOPE ) ) vertexColor.a = 0;

    }

}
