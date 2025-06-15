shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_always, depth_test_disabled;

void fragment() {
    vec3 outline_color = vec3(1.0, 0.2, 0.2); // Red
    ALBEDO = outline_color;
    EMISSION = outline_color * 5.0;
}