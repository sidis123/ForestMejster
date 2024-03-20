shader_type spatial;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_nearest;


// Water color
uniform vec4 out_color: source_color = vec4(0.0, 0.2, 1.0, 1.0);
// Amount of height for each triangle
uniform float amount: hint_range(0.2, 5.0, 0.1) = 0.8;
// The speed of the trangles height change
uniform float speed: hint_range(0.1, 5.0, 0.1) = 1;
// Beer factor (used to calculate how transparent the water is going to be) if equals to 0.0 then the alpha is going to be the out_color's alpha
uniform float beer_factor = 0.2;
uniform float metallic = 0.6;
uniform float specular = 0.5;
uniform float roughness = 0.2;

// New uniforms for water transparency and depth effect
uniform float transparency : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float max_visible_depth : hint_range(0.0, 100.0, 0.1) = 10.0;
uniform vec3 edge_color : source_color;

uniform float border_scale : hint_range(0.0, 5.0, 0.01) = 2.0;
uniform float near = 1.0;
uniform float far = 100.0;

float generateOffset(float x, float z, float val1, float val2, float time) {
	float radiansX = ((mod(x + z * x * val1, amount) / amount) + (time * speed) * mod(x * 0.8 + z, 1.5)) * 2.0 * 3.14;
	float radiansZ = ((mod(val2 * (z * x + x * z), amount) / amount) + (time * speed) * 2.0 * mod(x, 2.0)) * 2.0 * 3.14;
	
	return amount * 0.5 * (sin(radiansZ) * cos(radiansX));
}

vec3 applyDistortion(vec3 vertex, float time) {
	float xd = generateOffset(vertex.x, vertex.z, 0.2, 0.1, time);
	float yd = generateOffset(vertex.x, vertex.z, 0.1, 0.3, time);
	float zd = generateOffset(vertex.x, vertex.z, 0.15, 0.2, time);
	
	return vertex + vec3(xd, yd, zd);
}

float edge(float depth) {
    depth = 2.0 * depth - 1.0;
    return near * far / (far + depth * (near - far));
}

float normalize_float(float min_v, float max_v, float value) {
	float clamped_value = clamp(value, min_v, max_v);
	return  (clamped_value - min_v) / (max_v - min_v);
}

void vertex() {
	VERTEX = applyDistortion(VERTEX, TIME * 0.1);
}

void fragment() {
    NORMAL = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
    METALLIC = metallic;
    SPECULAR = specular;
    ROUGHNESS = roughness;

    float screen_depth_raw = texture(DEPTH_TEXTURE, SCREEN_UV).r;
    float surface_depth = FRAGCOORD.z;

    // Correct texture sampling
    vec3 screen_texture_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;

    float screen_depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
    float z_depth = edge(screen_depth_raw);
    float z_pos = edge(surface_depth);
    float z_dif = z_depth - z_pos;

    vec3 depth_color = mix(out_color.rgb, screen_texture_color, transparency);
    vec3 depth_color_adj = mix(edge_color, depth_color, step(border_scale, z_dif));

    // Note: Implement the normalize_float function as it was in the first shader
    float depth_opacity = 1.0 - normalize_float(0.0, max_visible_depth, surface_depth);
    vec3 final_color = mix(depth_color_adj, out_color.rgb, depth_opacity);

    ALBEDO = clamp(final_color, vec3(0.0), vec3(1.0));
    ALPHA = out_color.a;
}
