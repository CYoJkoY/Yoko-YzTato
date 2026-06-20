shader_type canvas_item;

uniform float distortion_strength : hint_range(0, 0.1) = 0.04;
uniform float flow_speed = 1;
uniform float lightning_power : hint_range(0, 2) = 1.0;
uniform vec4 lightning_color: hint_color = vec4(0.7, 0.9, 1.0, 1.0);

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f*f*(3.0-2.0*f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}
float fbm(vec2 p) {
    float value = 0.0;
    float amp = 0.5;
    float freq = 1.0;
    for (int i = 0; i < 4; i++) { 
        value += amp * noise(p * freq);
        amp *= 0.5;
        freq *= 2.0;
    }
    return value;
}

void fragment() {
    vec2 flow_vector = vec2(TIME * flow_speed * 0.8, TIME * flow_speed * 0.4);
    vec2 uv_flow_x = UV * 3.0 + flow_vector;
    vec2 uv_flow_y = UV * 3.0 + flow_vector + vec2(100.0, 100.0);

    float offset_x = fbm(uv_flow_x) - 0.5;
    float offset_y = fbm(uv_flow_y) - 0.5;

    vec2 distorted_uv = UV + vec2(offset_x, offset_y) * distortion_strength;

    vec4 col = texture(TEXTURE, distorted_uv);

    if (col.a < 0.01) discard;

    float light_noise = fbm(UV * 4.0 + flow_vector * 1.5);
    float brightness = 0.8 + 0.2 * light_noise;

    vec3 final_color = col.rgb * brightness;
    vec3 dark_tint = vec3(0.06, 0.08, 0.16);
    final_color = mix(final_color, dark_tint, 0.5);

    vec3 lightning_glow = lightning_color.rgb * lightning_power * 0.8;
    final_color += lightning_glow;

    COLOR = vec4(final_color, lightning_color.a);
}