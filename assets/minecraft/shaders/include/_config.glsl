// ============================================================
// TEXT EFFECTS CONFIGURATION
// ============================================================
// Define color-to-effect mappings here.
// Usage: TEXT_EFFECT(rgb(R, G, B)) { apply_effect(); }   // or rgb(0xRRGGBB)
// ============================================================

// Shake (#F8F854) - Red
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 84)) {
    apply_shake();
    apply_color(rgb(255, 80, 80));
}

// Wavy (#F8F858) - Green
TEXT_EFFECT_WITH_SHADOW(rgb(0xF8F858)) {
    apply_wavy();
    apply_color(rgb(80, 255, 80));
}

// Rainbow (#F8F85C)
TEXT_EFFECT(rgb(0xF8F85C)) {
    apply_rainbow();
}

// Bouncy (#F8F860) - Orange
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 96)) {
    apply_bouncy();
    apply_color(rgb(255, 170, 0));
}

// Blinking (#F8F864) - Blue
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 100)) {
    apply_blinking();
    apply_color(rgb(80, 80, 255));
}

// Pulse (#F8F868) - Cyan
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 104)) {
    apply_pulse();
    apply_color(rgb(80, 255, 255));
}

// Spin (#F8F86C) - Pink
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 108)) {
    apply_spin();
    apply_color(rgb(255, 80, 255));
}

// Sequential Spin (#F8F870) - White
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 112)) {
    apply_sequential_spin();
    apply_color(rgb(255, 255, 255));
}

// Fade (#F8F874) - Yellow
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 116)) {
    apply_fade();
    apply_color(rgb(255, 255, 80));
}

// Iterating Jump (#F8F878) - Purple
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 120)) {
    apply_iterating();
    apply_color(rgb(170, 0, 255));
}

// Glitch (#F8F87C) - Red
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 124)) {
    apply_glitch();
    apply_color(rgb(255, 80, 80));
}

// Scale x1.5 (#F8F880) - Cyan
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 128)) {
    apply_scale(1.5);
    apply_color(rgb(80, 255, 255));
}

// Offset up (#F8F884) - Orange
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 132)) {
    apply_offset(0.0, 40.0);
    apply_color(rgb(255, 170, 0));
}

// Gradient: Green → Yellow, Down (#F8F888)
TEXT_EFFECT(rgb(248, 248, 136)) {
    apply_gradient(rgb(0, 200, 0), rgb(255, 255, 0), 4.0);
}

// Dynamic Gradient: Red → Blue, Right (#F8F88C)
TEXT_EFFECT(rgb(248, 248, 140)) {
    apply_dynamic_gradient(rgb(255, 0, 0), rgb(0, 0, 255), 2.0, 500.0);
}

// Dynamic Gradient: Green → Yellow, Down (#F8F890)
TEXT_EFFECT(rgb(248, 248, 144)) {
    apply_dynamic_gradient(rgb(0, 200, 0), rgb(255, 255, 0), 4.0, 500.0);
}

// Lava (#F8F894)
TEXT_EFFECT(rgb(248, 248, 148)) {
    apply_lava();
}

// Wavy + Rainbow (#F8F898)
TEXT_EFFECT(rgb(248, 248, 152)) {
    apply_wavy();
    apply_rainbow();
}

// Bouncy + Rainbow (#F8F89C)
TEXT_EFFECT(rgb(248, 248, 156)) {
    apply_bouncy();
    apply_rainbow();
}

// Custom Parameters (Fast Shake) (#C86432)
TEXT_EFFECT(rgb(200, 100, 50)) {
    apply_shake(2.0, 1.5);
    apply_color(rgb(255, 255, 85));
}

// Shadow Support Example (Text + Shadow)
TEXT_EFFECT_WITH_SHADOW(rgb(255, 200, 200)) {
    apply_wavy(5000.0, 0.5);
}

// Aurora (#F8F8A0)
TEXT_EFFECT(rgb(248, 248, 160)) {
    apply_aurora();
}

// Split (#F8F8A4) - Pink
TEXT_EFFECT_WITH_SHADOW(rgb(248, 248, 164)) {
    apply_split();
    apply_color(rgb(255, 100, 200));
}

// Outline (#F8F8AC) - fragment effect
TEXT_EFFECT(rgb(248, 248, 172)) {
    apply_outline(rgb(0, 0, 0), 1.0);
    apply_color(rgb(255, 255, 255));
}

// Hatch (#F8F8B0) - fragment effect
TEXT_EFFECT(rgb(248, 248, 176)) {
    apply_color(rgb(165, 233, 38));
    apply_hatch(rgb(255, 255, 255), 800.0, 3.0);
}

// Neon (#F8F8B4) - fragment effect
TEXT_EFFECT(rgb(248, 248, 180)) {
    apply_neon(rgb(80, 220, 255), 1.5);
}

// RGBA Alpha Example (#F8F8B8)
TEXT_EFFECT(rgb(248, 248, 184)) {
    apply_color(rgba(255, 80, 80, 0.5));
}

// Chromatic Aberration (#F8F8BC) — args: (intensity_pixels, speed)
TEXT_EFFECT(rgb(248, 248, 188)) {
    apply_chromatic(1.0, 1.0);
    apply_color(rgb(255, 255, 255));
}

// 3D Extrude (#F8F8C0) — args: (depth_pixels, layers)
TEXT_EFFECT(rgb(248, 248, 192)) {
    apply_extrude(1.0, 3.0);
    apply_color(rgb(255, 200, 0));
}

// 3D Extrude with explicit endColor (#F8F8CC) — args: (depth, layers, endColor)
TEXT_EFFECT(rgb(248, 248, 204)) {
    apply_extrude(1.0, 5.0, rgb(80, 40, 0));   // gradient from main color to dark brown
    apply_color(rgb(255, 220, 100));
}

// 3D Extrude 3-color (#F8F8D0) — args: (depth, layers, c1, c2, c3)
TEXT_EFFECT(rgb(248, 248, 208)) {
    apply_extrude(1.0, 5.0, rgb(206, 71, 240), rgb(180, 100, 30), rgb(89, 196, 28));
    apply_color(rgb(255, 240, 180));
}

// Noise (#F8F8C4) — args: (intensity_pixels, speed)
TEXT_EFFECT(rgb(248, 248, 196)) {
    apply_noise(1.0, 1.0);
    apply_color(rgb(255, 255, 255));
}

// Liquid Morph (#F8F8C8) — args: (intensity_pixels, speed)
TEXT_EFFECT(rgb(248, 248, 200)) {
    apply_liquid(1.0, 1.0);
    apply_color(rgb(80, 200, 220));
}

// Water (#F8F8D4) — args: (color) or (color, level) or (color, level, amp, speed) or (color, level, amp, speed, freq)
TEXT_EFFECT(rgb(248, 248, 212)) {
    apply_water(rgb(40, 150, 240));
    apply_color(rgb(60, 60, 80));   // dry portion (above water) tint
}

// Water with custom level (#F8F8D8) — 80% filled
TEXT_EFFECT(rgb(248, 248, 216)) {
    apply_water(rgb(0, 200, 200), 0.8, 1.5, 1.2);
    apply_color(rgb(40, 60, 60));
}
