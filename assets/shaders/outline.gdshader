shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0);
uniform float line_thickness : hint_range(0.0, 20.0) = 10.0;
uniform int pattern : hint_range(0, 2) = 0; // diamond, circle, square
uniform bool inside = true;
uniform bool effect_enabled = true;
uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 scale_factor = vec2(1.0, 1.0);

const vec2 OFFSETS[8] = vec2[](
    vec2(-1, -1), vec2(-1, 0), vec2(-1, 1),
    vec2(0, -1), vec2(0, 1),
    vec2(1, -1), vec2(1, 0), vec2(1, 1)
);

bool hasContraryNeighbour(vec2 uv, vec2 pixel_size, vec2 thickness) {
    for (int i = 0; i < 8; i++) {
        vec2 offset_uv = uv + OFFSETS[i] * pixel_size * thickness;
        float neighbor_alpha = texture(screen_texture, offset_uv).a;

        if (inside) {
            if (neighbor_alpha <= 0.0) {
                return true;
            }
        } else {
            if (neighbor_alpha > 0.0) {
                return true;
            }
        }
    }
    return false;
}

void fragment() {
    if (!effect_enabled) {
        COLOR = texture(screen_texture, SCREEN_UV);
    } else {

        vec2 pixel_size = SCREEN_PIXEL_SIZE;

        vec2 adjusted_thickness = line_thickness * scale_factor;

        vec4 base_color = texture(screen_texture, SCREEN_UV);

        if (inside) {
            if (base_color.a > 0.0 && hasContraryNeighbour(SCREEN_UV, pixel_size, adjusted_thickness)) {
                vec4 outline_color = vec4(line_color.rgb, base_color.a);
                COLOR = mix(base_color, outline_color, line_color.a);
            } else {
                COLOR = base_color;
            }
        } else {
            if (base_color.a <= 0.0 && hasContraryNeighbour(SCREEN_UV, pixel_size, adjusted_thickness)) {
                COLOR = vec4(line_color.rgb, 1.0);
            } else {
                COLOR = base_color;
            }
        }
    }
}