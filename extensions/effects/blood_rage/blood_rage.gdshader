shader_type canvas_item;

uniform vec4 blood_rage_color: hint_color = vec4(0.0, 0.5, 1.0, 1.0);
uniform float distortion_intensity: hint_range(0.0, 1.0) = 0.0;
uniform float wave_speed = 2.0;
uniform float wave_amount = 0.1;

void fragment() {
    vec2 uv = UV;
    
    float wave = sin(TIME * wave_speed + uv.x * 10.0) * wave_amount * distortion_intensity;
    uv.y += wave;
    
    vec4 original_color = texture(TEXTURE, uv);
    vec4 final_color = mix(original_color, blood_rage_color, distortion_intensity * 0.3);
    
    float blue_glow = sin(TIME * wave_speed * 2.0) * 0.1 * distortion_intensity;
    final_color.rgb += vec3(0.0, 0.0, blue_glow);
    
    COLOR = final_color;
}