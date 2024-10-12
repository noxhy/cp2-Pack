#version 150
#if defined(RENDERTYPE_TEXT) || defined(RENDERTYPE_TEXT_INTENSITY)

struct TextData {
    vec4 color;
    vec4 topColor;
    vec4 backColor;
    vec2 position;
    vec2 characterPosition;
    vec2 localPosition;
    vec2 uv;
    vec2 uvMin;
    vec2 uvMax;
    vec2 uvCenter;
    bool isShadow;
    bool doTextureLookup;
    bool shouldScale;
};

TextData textData;

bool uvBoundsCheck(vec2 uv, vec2 uvMin, vec2 uvMax) {
    if(isnan(uv.x) || isnan(uv.y)) return true;
    const float error = 0.0001;
    return uv.x < textData.uvMin.x + error || uv.y < textData.uvMin.y + error || uv.x > textData.uvMax.x - error || uv.y > textData.uvMax.y - error;
}

vec3 textSdf() {
    vec3 value = vec3(0.0, 0.0, 1.0);

    vec2 texelSize = 1.0 / vec2(256.0);
    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) {
                vec3 v = vec3(fract(uv * 256.0), 0.0);

                if(x == 0) v.x = 0.0;
                if(y == 0) v.y = 0.0;
                if(x > 0) v.x = 1.0-v.x;
                if(y > 0) v.y = 1.0-v.y;

                v.z = length(v.xy);

                if(v.z < value.z) value = v;
            }
        }
    }
    return value;
}

void override_text_color(vec4 color) {
    textData.color = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_text_color(vec3 color) {
    textData.color.rgb = color;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void override_shadow_color(vec4 color) {
    if(textData.isShadow) {
        textData.color = color;
        textData.topColor.rgb = color.rgb;
        textData.topColor.a *= color.a;
        textData.backColor.rgb = color.rgb;
        textData.backColor.a *= color.a;
    }
}

void override_shadow_color(vec3 color) {
    override_shadow_color(vec4(color, 1.0));
}

void remove_text_shadow() {
    if(textData.isShadow) textData.color.a = 0.0;
}

void apply_vertical_shadow() {
    if(textData.isShadow) {
        textData.uv.x += 1.0 / 256.0;
        textData.shouldScale = true;
    }
}

void apply_vertical_shift(float shift) {
    textData.uv.y += shift/256.0;
    textData.shouldScale = true;
}
void apply_horizontal_shift(float shift) {
    textData.uv.x += shift/256.0;
    textData.shouldScale = true;
}

void apply_waving_movement(float speed, float frequency) {
    textData.uv.y += sin(textData.characterPosition.x * 0.1 * frequency - GameTime * 7500.0 * speed) / 256.0;
    textData.shouldScale = true;
}

void apply_waving_movement(float speed) {
    apply_waving_movement(speed, 1.0);
}

void apply_waving_movement() {
    apply_waving_movement(1.0, 1.0);
}

void apply_shaking_movement(float multiplier) {
    float noiseX = noise(textData.characterPosition.x + textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    float noiseY = noise(textData.characterPosition.x - textData.characterPosition.y + GameTime * 32000.0) - 0.5;
    textData.shouldScale = true;

    textData.uv += vec2(noiseX, noiseY) *multiplier / 256.0;
}

void apply_shaking_movement() {
    apply_shaking_movement(1.0);
}

void apply_iterating_movement(float speed, float space) {
    float x = mod(textData.characterPosition.x * 0.4 - GameTime * 18000.0 * speed, (5.0 * space) * TAU);
    if(x > TAU) x = TAU;
    textData.uv.y += (-cos(x) * 0.5 + 0.5) / 256.0;
    textData.shouldScale = true;
}

void apply_iterating_movement() {
    apply_iterating_movement(1.0, 1.0);
}

void apply_flipping_movement(float speed, float space, float shift) {
    float t = mod((textData.characterPosition.x * 0.4 - GameTime  * 18000.0 * speed) / TAU, 5.0 * space);
    textData.uv.x = textData.uvCenter.x + shift + (textData.uv.x - textData.uvCenter.x - shift) / (cos(TAU * min(t, 1.0)));
    textData.uv.y = textData.uvCenter.y + (textData.uv.y - textData.uvCenter.y) / (1.0 + 0.1 * sin(TAU * min(t, 1.0)));
    textData.shouldScale = true;
}

void apply_flipping_movement() {
    apply_flipping_movement(1.0, 1.0, 0.0);
}

void apply_skewing_movement(float speed) {
    float t = GameTime * 1600.0 * speed;

    textData.uv.x = mix(textData.uv.x, textData.uv.x + sin(TAU * t * 0.5) / 256.0, 1.0 - textData.localPosition.y);
    textData.uv.y = mix(textData.uv.y, textData.uvMax.y, -(0.3 + 0.5 * cos(TAU * t)));
    textData.shouldScale = true;
}

void apply_skewing_movement() { 
    apply_skewing_movement(1.0);
}

void apply_growing_movement(float speed, vec2 offset) {
    textData.uv = (textData.uv - textData.uvCenter - offset) * (sin(GameTime * 12800.0 * speed) * 0.15 + 0.85) + textData.uvCenter + offset;
    textData.shouldScale = true;
}

void apply_growing_movement() {
    apply_growing_movement(1.0, vec2(0.0, 5.0 / 256.0));
}

void apply_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 

    vec2 texelSize = 1.0 / vec2(256.0);
    bool outline = false;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}

void apply_thin_outline(vec3 color) {
    textData.shouldScale = true;

    if(textData.isShadow) {
        color *= 0.25;
        textData.color.rgb = color;
    } 
    
    vec2 texelSize = 0.5 / vec2(256.0);
    bool outline = false;

    for(int x = -1; x <= 1; x++) {
        for(int y = -1; y <= 1; y++) {
            if(x == 0 && y == 0) continue;

            vec2 uv = textData.uv + vec2(x, y) * texelSize;
            if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) continue;

            vec4 s = texture(Sampler0, uv);
            if(s.a >= 0.1) { textData.backColor = vec4(color, 1.0); return; }
        }
    }
}


void apply_gradient(vec3 color1, vec3 color2) {
    textData.color.rgb = mix(color1, color2, (textData.uv.y - textData.uvMin.y) / (textData.uvMax.y - textData.uvMin.y));
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_rainbow(float intensity) {
    textData.color.rgb = hsvToRgb(vec3(0.005 * (textData.position.x + textData.position.y) - GameTime * 300.0, 0.7, 1.0))*intensity;
    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_rainbow() {
    apply_rainbow(1.0);
}

void apply_shimmer(float speed, float intensity, vec3 shimmer_color) {
    if(textData.isShadow) return;
    float f = textData.localPosition.x + textData.localPosition.y - GameTime * 6400.0 * speed;
    
    if(mod(f, 5) < 0.75) textData.topColor = vec4(shimmer_color, intensity);
}

void apply_shimmer(){
    apply_shimmer(1.0, 0.5, rgb(255,255,255));
}

void apply_chromatic_abberation() {
    textData.shouldScale = true;
    float noiseX = noise(GameTime * 12000.0) - 0.5;
    float noiseY = noise(GameTime * 12000.0 + 19732.134) - 0.5;
    vec2 offset = vec2(0.5 / 256, 0.0) + vec2(0.5, 1.0) *4* vec2(noiseX, noiseY) / 256;

    vec2 uv = textData.uv + offset;
    vec4 s1 = texture(Sampler0, uv);
    s1.rgb *= s1.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s1 = vec4(0.0);

    uv = textData.uv - offset;
    vec4 s2 = texture(Sampler0, uv);
    s2.rgb *= s2.a;
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) s2 = vec4(0.0);

    textData.backColor = (s1 * vec4(1.0, 0.25, 0.0, 1.0)) + (s2 * vec4(0.0, 0.75, 1.0, 1.0));
    textData.backColor.rgb *= textData.color.rgb;
}

void apply_metalic(vec3 lightColor, vec3 darkColor) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));
    
    if(y > 3) textData.color.rgb = darkColor;
    if(y == 3) textData.color.rgb = lightColor + 0.25;
    if(y < 3) textData.color.rgb = lightColor;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_metalic(vec3 color) {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));
    
    if(y > 3) textData.color.rgb = color * 0.7;
    if(y == 3) textData.color.rgb = color + 0.25;
    if(y < 3) textData.color.rgb = color;

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_fire() {
    textData.shouldScale = true;
    if(textData.isShadow) return;

    float h = fract(textData.uv.y * 256.0);
    vec2 uv = textData.uv + vec2(0.0, 1.0 / 256);
    if(uvBoundsCheck(uv, textData.uvMin, textData.uvMax)) return;
    vec4 s = texture(Sampler0, uv);
    if(s.a > 0.1) {
        float f = noise(textData.localPosition * 32.0 + vec2(0.0, GameTime * 6400.0)) * 0.5 + 0.5;
        f -= (1.0 - sqrt(h)) * 0.8;

        if(f > 0.5)
        textData.backColor = vec4(mix(vec3(1.0, 0.2, 0.2), vec3(1.0, 0.7, 0.3), (f - 0.5) / 0.5), 1.0);
    }
}

void apply_fade(float speed) {
    textData.color.a = mix(textData.color.a, 0.0, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade() {
    apply_fade(1.0);
}

void apply_fade(vec3 color, float speed) {
    if(textData.isShadow) color *= 0.25;

    textData.color.rgb = mix(textData.color.rgb, color, sin(GameTime * 1200 * speed * PI) * 0.5 + 0.5);
}

void apply_fade(vec3 color) {
    apply_fade(color, 1.0);
}

void apply_blinking(float speed){
    if(sin(GameTime * 3200 * speed * PI) < 0.0) { textData.color.a = 0.0; textData.backColor.a = 0.0; textData.topColor.a = 0.0; }
}

void apply_blinking() {
    apply_blinking(1.0);
}

void apply_glowing() {
    if(textData.isShadow) textData.color = vec4(0.0);
    vec3 d = textSdf();
    textData.backColor = vec4(0.0, 0.0, 0.0, (1.0 - d.z) * (1.0 - d.z));
}

void apply_lesbian_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.839, 0.161, 0.000);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.608, 0.333);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.831, 0.384, 0.647);
    if(y >  5) textData.color.rgb = vec3(0.647, 0.000, 0.384);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_mlm_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.000, 0.584, 0.525);
    if(y == 3) textData.color.rgb = vec3(0.412, 0.941, 0.686);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.510, 0.698, 1.000);
    if(y >  5) textData.color.rgb = vec3(0.271, 0.153, 0.627);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_bisexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  4) textData.color.rgb = vec3(0.843, 0.000, 0.443);
    if(y == 4) textData.color.rgb = vec3(0.612, 0.306, 0.592);
    if(y >  4) textData.color.rgb = vec3(0.000, 0.208, 0.663);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_transgender_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.357, 0.812, 0.980);
    if(y == 3) textData.color.rgb = vec3(0.961, 0.671, 0.725);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.961, 0.671, 0.725);
    if(y >  5) textData.color.rgb = vec3(0.357, 0.812, 0.980);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  2) textData.color.rgb = vec3(1.000, 0.012, 0.012);
    if(y == 2) textData.color.rgb = vec3(1.000, 0.549, 0.000);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.929, 0.000);
    if(y == 4) textData.color.rgb = vec3(0.000, 0.502, 0.149);
    if(y == 5) textData.color.rgb = vec3(0.000, 0.302, 1.000);
    if(y >  5) textData.color.rgb = vec3(0.459, 0.027, 0.529);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_pansexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(1.000, 0.129, 0.549);
    if(y == 3) textData.color.rgb = vec3(1.000, 0.847, 0.000);
    if(y == 4) textData.color.rgb = vec3(1.000, 0.847, 0.000);
    if(y >  4) textData.color.rgb = vec3(0.129, 0.694, 1.000);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_asexual_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.100, 0.100, 0.100);
    if(y == 3) textData.color.rgb = vec3(0.639, 0.639, 0.639);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y >  4) textData.color.rgb = vec3(0.502, 0.000, 0.502);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_aromantic_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.047, 0.655, 0.294);
    if(y == 3) textData.color.rgb = vec3(0.584, 0.796, 0.451);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.639, 0.639, 0.639);
    if(y >  5) textData.color.rgb = vec3(0.100, 0.100, 0.100);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_aroace_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(0.890, 0.553, 0.000);
    if(y == 3) textData.color.rgb = vec3(0.929, 0.808, 0.000);
    if(y == 4) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 5) textData.color.rgb = vec3(0.384, 0.690, 0.867);
    if(y >  5) textData.color.rgb = vec3(0.102, 0.208, 0.333);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

void apply_non_binary_pride() {
    int y = int(floor((textData.uv.y - textData.uvMin.y) * 256.0));

    if(y <  3) textData.color.rgb = vec3(1.000, 0.957, 0.173);
    if(y == 3) textData.color.rgb = vec3(1.000, 1.000, 1.000);
    if(y == 4) textData.color.rgb = vec3(0.616, 0.349, 0.824);
    if(y >  4) textData.color.rgb = vec3(0.100, 0.100, 0.100);

    if(textData.isShadow) textData.color.rgb *= 0.25;
}

#define TEXT_EFFECT(r, g, b) return true; case ((uint(r/4) << 16) | (uint(g/4) << 8) | (uint(b/4))):

bool applyTextEffects() { 
    uint vertexColorId = colorId(floor(round(textData.color.rgb * 255.0) / 4.0) / 255.0); 
    if(textData.isShadow) { vertexColorId = colorId(textData.color.rgb);} 
    switch(vertexColorId >> 8) { 
        case 0xFFFFFFFFu:

        //#####
        //INSERT TEXT EFFECTS HERE!
        //#####

        //no shadow
        TEXT_EFFECT(250,254,250) { remove_text_shadow(); }

        //boss bar underline
        TEXT_EFFECT(248,250,254) {
            apply_shimmer(0.5,0.5,rgb(255,255,255));
            apply_outline(rgb(42,42,71));
        }

        //blinking hearts
        TEXT_EFFECT(250,250,250) {
            remove_text_shadow();
            apply_shaking_movement();
        }

        //==================================================================================================================
        //ROLE COLOR EFFECTS. These are matched with color variations in items
        //==================================================================================================================

        //Survivor
        TEXT_EFFECT(4,0,0) {apply_gradient(rgb(175,253,205), rgb(23, 221, 98));}
        //Chorus
        TEXT_EFFECT(8,0,0) {apply_gradient(rgb(186,155,186), rgb(94,46,92));}
        //Sculk
        TEXT_EFFECT(0,4,0) {apply_gradient(rgb(0,146,149), rgb(10,80,96));}
        //Fungus 1: Crimson
        TEXT_EFFECT(4,4,0) {apply_gradient(rgb(255,101,0), rgb(115,4,8));}
        //Fungus 2: Warped
        TEXT_EFFECT(8,4,0) {apply_gradient(rgb(255,101,0), rgb(22,126,134));}
        //Fungus 3: Vanta
        TEXT_EFFECT(0,8,0) {apply_gradient(rgb(70,75,103),rgb(255,101,0));}
        //Fungus 4: Asimi
        TEXT_EFFECT(4,8,0) {apply_gradient(rgb(255,255,255),rgb(114,126,134));}
        //Fungus 5: Zelen
        TEXT_EFFECT(8,8,0) {apply_gradient(rgb(0,255,101),rgb(8,115,4));}
        //Fungus 6: Chiro
        TEXT_EFFECT(0,0,4) {apply_gradient(rgb(255,255,255),rgb(171,105,0));}
        //Fungus 7: Parin
        TEXT_EFFECT(4,0,4) {apply_gradient(rgb(15,188,255),rgb(149,149,149));}
        //Fungus 8: Morea
        TEXT_EFFECT(8,0,4) {apply_gradient(rgb(230,204,204),rgb(115,17,39));}

        //==================================================================================================================

        //gui interaction allowed (buy, etc)
        TEXT_EFFECT(0,4,4) {
            override_text_color(rgb(23,218,97));
            apply_shimmer();
        }

        //bossbar
        TEXT_EFFECT(250,254,254) {
            apply_iterating_movement(1.0,2.0);
            apply_vertical_shift(-8.0);
            apply_gradient(rgb(255, 255, 255), rgb(150, 163, 177) * 0.95);
            apply_outline(rgb(42,42,71));
        }

        //moon
        TEXT_EFFECT(8,0,8) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(62,7,53));
            apply_shimmer();
        }

        //bossbar purple/gold
        TEXT_EFFECT(246,246,250) {
            apply_iterating_movement(1.0,2.0);
            apply_vertical_shift(-8.0);
            apply_gradient(rgb(255, 200, 0), rgb(255, 200, 0) * 0.8);
            apply_outline(rgb(62,7,53));
        }

        //bossbar turquoise
        TEXT_EFFECT(242,246,246) {
            apply_iterating_movement(1.0,2.0);
            apply_vertical_shift(-8.0);
            apply_gradient(rgb(60,177,200), rgb(29,170,69));
            apply_outline(rgb(42,42,71));
        }

        //game over (1)
        TEXT_EFFECT(246,242,242) {
            float progress = sin(textData.color.a*PI*0.5)*256.0-256.0;
            apply_horizontal_shift(progress);
        }

        //win (1)
        TEXT_EFFECT(242,242,246) {
            float progress = sin(textData.color.a*PI*0.5)*-64.0+64.0;
            apply_horizontal_shift(progress);
            apply_gradient(rgb(60,177,200), rgb(29,170,69));
            apply_outline(rgb(42,42,71));
        }

        //undecided (1)
        TEXT_EFFECT(246,242,246) {
            float progress = sin(textData.color.a*PI*0.5)*-64.0+64.0;
            apply_horizontal_shift(progress);
            apply_gradient(rgb(255,162,0), rgb(209,105,10));
            apply_outline(rgb(42,42,71));
        }

        //lose (1)
        TEXT_EFFECT(242,246,242) {
            float progress = sin(textData.color.a*PI*0.5)*-64.0+64.0;
            apply_horizontal_shift(progress);
            apply_gradient(rgb(228,45,56), rgb(144,52,102));
            apply_outline(rgb(42,42,71));
        }

        //normal subtext
        TEXT_EFFECT(238,242,246) {
            apply_gradient(rgb(255, 255, 255), rgb(150, 163, 177) * 0.95);
        }

        //waving 
        TEXT_EFFECT(238,238,246) {
            override_text_color(rgb(255,255,255));
            apply_waving_movement();
        }

        //cooking
        TEXT_EFFECT(246,238,238) {
            apply_skewing_movement();
            apply_gradient(vec3(1.0, 0.2, 0.2), vec3(1.0, 0.7, 0.3));
            apply_outline(rgb(98,52,54));
        }

        //book ingredient/meal

        TEXT_EFFECT(246,238,246) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(42,42,71));
            apply_glowing();
        }

        //book outline 1: blue

        TEXT_EFFECT(32,0,0) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(42,42,71));
        }

        //book outline 2: red

        TEXT_EFFECT(0,32,0) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(228,45,56));
        }

        //book outline 3: green

        TEXT_EFFECT(0,0,32) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(31,83,71));
        }

        //book outline 4: purple

        TEXT_EFFECT(32,32,0) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(144,42,102));
        }

        //book outline 5: orange

        TEXT_EFFECT(32,0,32) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(209,105,10));
        }

        //book outline 6: black

        TEXT_EFFECT(0,32,32) {
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(19,19,39));
        }

        //rainbow

        TEXT_EFFECT(64,0,0){
            apply_rainbow();
        }

        //tramsgendar!

        TEXT_EFFECT(64,32,0){
            apply_transgender_pride();
        }

        //lesbian

        TEXT_EFFECT(64,0,32){
            apply_lesbian_pride();
        }

        //gay

        TEXT_EFFECT(64,32,16){
            apply_mlm_pride();
        }

        //bi

        TEXT_EFFECT(64,32,32){
            apply_bisexual_pride();
        }

        //aroace

        TEXT_EFFECT(64,16,32){
            apply_aroace_pride();
        }

        //gold

        TEXT_EFFECT(64,16,16){
            apply_gradient(vec3(1.000, 0.635, 0.000),vec3(0.820, 0.412, 0.039));
        }

        //cosmetics

        TEXT_EFFECT(0,32,64) {
            apply_gradient(rgb(137, 219, 164), rgb(254, 112, 157));
            apply_outline(rgb(3,23,66));
        }

        //missions

        TEXT_EFFECT(64,32,64) {
            apply_gradient(rgb(244,255,155), rgb(137,221,71));
            apply_shimmer();
            apply_outline(rgb(19,19,39));
        }

        //missions time

        TEXT_EFFECT(60,32,64) {
            apply_iterating_movement();
            override_text_color(rgb(255,255,255));
            apply_outline(rgb(19,19,39));
        }

        //missions low time

        TEXT_EFFECT(56,32,64) {
            apply_iterating_movement();
            override_text_color(rgb(255,255,255));
            apply_fade(rgb(255,0,0));
            apply_outline(rgb(19,19,39));
        }

        //seasonal: halloween

        TEXT_EFFECT(16,0,0) {
            apply_shaking_movement();
            apply_gradient(rgb(255,162,0), rgb(51,103,91));
            apply_outline(rgb(19,19,39));
        }

        //seasonal: christmas

        TEXT_EFFECT(0,16,0) {
            apply_waving_movement();
            apply_gradient(rgb(244,255,155), rgb(255,80,40));
            apply_outline(rgb(19,19,39));
        }

        //seasonal: easter

        TEXT_EFFECT(0,0,16) {
            apply_iterating_movement();
            apply_gradient(rgb(60,177,200), rgb(244,255,155));
            apply_outline(rgb(19,19,39));
        }

        //seasonal: summer

        TEXT_EFFECT(16,16,0) {
            apply_waving_movement();
            apply_gradient(rgb(60,177,200), rgb(255,200,157));
            apply_outline(rgb(19,19,39));
        }

        //weekend deals

        TEXT_EFFECT(128,0,64) {
            apply_waving_movement();
            apply_metalic(rgb(255,162,0), rgb(255,162,0)*0.8);
            apply_outline(rgb(19,19,39));
            apply_shimmer();
        }

        //shimmer

        TEXT_EFFECT(0,132,0) {
            override_text_color(rgb(255,255,255));
            apply_shimmer(0.5,0.2,rgb(255,255,255));
        }

        //update (shifted bossbar)
        TEXT_EFFECT(64,0,128) {
            apply_iterating_movement(1.0,2.0);
            apply_vertical_shift(-24.0);
            apply_gradient(rgb(255, 255, 255), rgb(150, 163, 177) * 0.95);
            apply_outline(rgb(42,42,71));
        }

        //GLYPHS: chroma
        TEXT_EFFECT(124,0,0) {
            override_text_color(rgb(255,255,255));
            apply_chromatic_abberation();
        }

        //GLYPHS: chroma (blacked out)
        TEXT_EFFECT(120,0,0) {
            override_text_color(rgb(64,64,32));
            apply_chromatic_abberation();
        }

        //GLYPHS: shimmer
        TEXT_EFFECT(0,124,0) {
            override_text_color(rgb(255,255,255));
            apply_shimmer();
        }

        //GLYPHS: shimmer (blacked out)
        TEXT_EFFECT(0,120,0) {
            override_text_color(rgb(64,64,32));
            apply_shimmer();
        }

        //GLYPHS: shaking
        TEXT_EFFECT(0,0,124) {
            override_text_color(rgb(255,255,255));
            apply_shaking_movement(2.0);
        }

        //GLYPHS: shaking (blacked out)
        TEXT_EFFECT(0,0,120) {
            override_text_color(rgb(64,64,32));
            apply_shaking_movement(2.0);
        }

        //GLYPHS: flipping
        TEXT_EFFECT(124,124,0) {
            override_text_color(rgb(255,255,255));
            apply_flipping_movement(1.0,0.5,8.0/256.0);
        }

        //GLYPHS: flipping (blacked out)
        TEXT_EFFECT(120,120,0) {
            override_text_color(rgb(64,64,32));
            apply_flipping_movement(1.0,0.5,8.0/256.0);
        }

        //GLYPHS: growing
        TEXT_EFFECT(0,124,124) {
            override_text_color(rgb(255,255,255));
            apply_growing_movement(1.0,vec2(8.0/256.0,8.0/256.0));
        }

        //GLYPHS: growing (blacked out)
        TEXT_EFFECT(0,120,120) {
            override_text_color(rgb(64,64,32));
            apply_growing_movement(1.0,vec2(8.0/256.0,8.0/256.0));
        }

        //GLYPHS: rainbow
        TEXT_EFFECT(124,0,124) {
            apply_rainbow();
        }

        //GLYPHS: rainbow (blacked out)
        TEXT_EFFECT(120,0,120) {
            apply_rainbow(0.25);
        }

        //Fake Button
        TEXT_EFFECT(116,0,0) {
            apply_iterating_movement();
            apply_metalic(rgb(255,255,255),rgb(166,192,230));
            apply_outline(rgb(47,54,67));
            
        }
    
        return true; 
    } 
    return false;
}

#define SPHEYA_PACK_9

#ifdef FSH
in vec4 vctfx_screenPos;
flat in float vctfx_applyTextEffect;
flat in float vctfx_isShadow;
flat in float vctfx_changedScale;

in vec3 vctfx_ipos1;
in vec3 vctfx_ipos2;
in vec3 vctfx_ipos3;
in vec3 vctfx_ipos4;

in vec3 vctfx_uvpos1;
in vec3 vctfx_uvpos2;
in vec3 vctfx_uvpos3;
in vec3 vctfx_uvpos4;

bool applySpheyaPack9() {
    if(vctfx_applyTextEffect < 0.5) return false;

    textData.isShadow = vctfx_isShadow > 0.5;
    textData.backColor = vec4(0.0);
    textData.topColor = vec4(0.0);
    textData.doTextureLookup = true;
    textData.color = baseColor;
    
    vec2 ip1 = vctfx_ipos1.xy / vctfx_ipos1.z;
    vec2 ip2 = vctfx_ipos2.xy / vctfx_ipos2.z;
    vec2 ip3 = vctfx_ipos3.xy / vctfx_ipos3.z;
    vec2 ip4 = vctfx_ipos4.xy / vctfx_ipos4.z;
    vec2 innerMin = min(ip1.xy,min(ip2.xy,min(ip3.xy,ip4.xy)));
    vec2 innerMax = max(ip1.xy,max(ip2.xy,min(ip3.xy,ip4.xy)));
    vec2 innerSize = innerMax - innerMin;
    
    vec2 uvp1 = vctfx_uvpos1.xy / vctfx_uvpos1.z;
    vec2 uvp2 = vctfx_uvpos2.xy / vctfx_uvpos2.z;
    vec2 uvp3 = vctfx_uvpos3.xy / vctfx_uvpos3.z;
    vec2 uvp4 = vctfx_uvpos4.xy / vctfx_uvpos4.z;
    vec2 uvMin = min(uvp1.xy,min(uvp2.xy,min(uvp3.xy, uvp4.xy)));
    vec2 uvMax = max(uvp1.xy,max(uvp2.xy,max(uvp3.xy, uvp4.xy)));
    vec2 uvSize = uvMax - uvMin;
    textData.uvMin = uvMin;
    textData.uvMax = uvMax;
    textData.uvCenter = uvMin + 0.25 * uvSize;
    textData.localPosition = ((vctfx_screenPos.xy - innerMin) / innerSize);
    textData.localPosition.y = 1.0 - textData.localPosition.y;
    textData.uv = textData.localPosition * uvSize + uvMin;
    if(vctfx_changedScale < 0.5) {
        textData.uv = texCoord0;
    }
    textData.position = vctfx_screenPos.xy * uvSize * 256.0 / innerSize;
    textData.characterPosition = 0.5 * (innerMin + innerMax) * uvSize * 256.0 / innerSize;
    if(textData.isShadow) { 
        textData.characterPosition += vec2(-1.0, 1.0);
        textData.position += vec2(-1.0, 1.0);
    }
    applyTextEffects();
    if(uvBoundsCheck(textData.uv, uvMin, uvMax)) textData.doTextureLookup = false;
    
    vec4 textureSample = texture(Sampler0, textData.uv);

#ifdef RENDERTYPE_TEXT_INTENSITY
    textureSample = textureSample.rrrr;
    textureSample = vec4(0.0);
#endif

    if(!textData.doTextureLookup) textureSample = vec4(0.0);
    textData.topColor.a *= textureSample.a;

    fragColor = mix(vec4(textData.backColor.rgb, textData.backColor.a * textData.color.a), textureSample * textData.color, textureSample.a);
    fragColor.rgb = mix(fragColor.rgb, textData.topColor.rgb, textData.topColor.a);
    fragColor *= lightColor * ColorModulator;

    if (fragColor.a < 0.1) {
        discard;
    }

    fragColor = linear_fog(fragColor, vertexDistance, FogStart, FogEnd, FogColor);
    return true;
}
#endif

#ifdef VSH
out vec4 vctfx_screenPos;
flat out float vctfx_applyTextEffect;
flat out float vctfx_isShadow;
flat out float vctfx_changedScale;

out vec3 vctfx_ipos1;
out vec3 vctfx_ipos2;
out vec3 vctfx_ipos3;
out vec3 vctfx_ipos4;

out vec3 vctfx_uvpos1;
out vec3 vctfx_uvpos2;
out vec3 vctfx_uvpos3;
out vec3 vctfx_uvpos4;

bool applySpheyaPack9() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vctfx_isShadow = fract(Position.z) < 0.01 ? 1.0 : 0.0;
    vctfx_applyTextEffect = 1.0;
    vctfx_changedScale = 0.0;

    textData.isShadow = vctfx_isShadow > 0.5;
    textData.color = Color;
    textData.shouldScale = false;

    if(!applyTextEffects()) {
        vctfx_isShadow = 0.0;
        if(Position.z == 0.0 && textData.isShadow) {
            textData.isShadow = false;
            if(applyTextEffects()) {
                vctfx_isShadow = 0.0;
            }else {
                vctfx_applyTextEffect = 0.0;
                return false;
            }
        }else{
            vctfx_applyTextEffect = 0.0;
            return false;
        }
    }

    vec2 corner = vec2[](vec2(-1.0, +1.0), vec2(-1.0, -1.0), vec2(+1.0, -1.0), vec2(+1.0, +1.0))[gl_VertexID % 4];

    if(textureSize(Sampler0, 0) != ivec2(256, 256)) {
        vctfx_applyTextEffect = 0.0;
        return false;
    }

    vctfx_uvpos1 = vctfx_uvpos2 = vctfx_uvpos3 = vctfx_uvpos4 = vctfx_ipos1 = vctfx_ipos2 = vctfx_ipos3 = vctfx_ipos4 = vec3(0.0);
    switch (gl_VertexID % 4) {
        case 0: vctfx_ipos1 = vec3(gl_Position.xy, 1.0); vctfx_uvpos1 = vec3(UV0.xy, 1.0); break;
        case 1: vctfx_ipos2 = vec3(gl_Position.xy, 1.0); vctfx_uvpos2 = vec3(UV0.xy, 1.0); break;
        case 2: vctfx_ipos3 = vec3(gl_Position.xy, 1.0); vctfx_uvpos3 = vec3(UV0.xy, 1.0); break;
        case 3: vctfx_ipos4 = vec3(gl_Position.xy, 1.0); vctfx_uvpos4 = vec3(UV0.xy, 1.0); break;
    } 
    if(textData.shouldScale) {
        gl_Position.xy += corner * 0.2;
        vctfx_changedScale = 1.0;
    }

    vctfx_screenPos = gl_Position;
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    vertexColor = baseColor * lightColor;
    texCoord0 = UV0;
    return true;
}
#endif

#endif