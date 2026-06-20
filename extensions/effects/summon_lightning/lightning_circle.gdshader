shader_type canvas_item;

uniform float rotation_speed : hint_range(0.0, 5.0) = 1.5;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.5;
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    float angle = TIME * rotation_speed;
    mat2 rot = mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
    vec2 uv = (UV - 0.5) * rot + 0.5;

    vec4 tex = texture(TEXTURE, uv);

    float flow = sin((uv.x * 10.0 + uv.y * 20.0) - TIME * flow_speed * 10.0) * 0.5 + 0.5;
    float glow = tex.a * flow;

    vec3 yellow = vec3(1.0, 0.8, 0.0);
    vec3 blue   = vec3(0.0, 0.6, 1.0);
    vec3 col = mix(yellow, blue, progress);

    vec3 final_color = col * (1.0 + glow * 0.8);
    final_color = min(final_color, vec3(1.0));

    COLOR = vec4(final_color, tex.a);
}
