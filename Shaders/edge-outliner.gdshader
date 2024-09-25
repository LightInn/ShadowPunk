//shader_type spatial;
//render_mode blend_add, depth_draw_never;
//// Ported from: https://github.com/KodyJKing/hello-threejs/blob/08a3696ed1d9f93e9d3dc6a6a3fb17ffcd70d453/src/RenderPixelatedPass.ts
//
//uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
//uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
//uniform sampler2D normal_roughness_texture : hint_normal_roughness_texture, repeat_disable, filter_nearest;
//
//const float normalEdgeCoefficient = 1.2;
//const float depthEdgeCoefficient = .9;
//
//void vertex() {
//}
//
//float gedepth_texture(vec2 uv, vec2 pixelSize, int x, int y) {
    //return textureLod(depth_texture, uv + vec2(ivec2(x, y)) * pixelSize, 0).r;
//}
//vec3 genormal_roughness_texture(vec2 uv, vec2 pixelSize, int x, int y) {
    //return textureLod(normal_roughness_texture, uv + vec2(ivec2(x, y)) * pixelSize, 0).rgb * 2. - 1.;
//}
//float depthEdgeIndicator(vec2 uv, vec2 pixelSize) {
    //float depth = gedepth_texture(uv, pixelSize, 0, 0);
    //vec3 normal = genormal_roughness_texture(uv, pixelSize, 0, 0);
    //float diff = 0.0;
    //diff += clamp(gedepth_texture(uv, pixelSize, 1, 0) - depth, 0.0, 1.0);
    //diff += clamp(gedepth_texture(uv, pixelSize, -1, 0) - depth, 0.0, 1.0);
    //diff += clamp(gedepth_texture(uv, pixelSize, 0, 1) - depth, 0.0, 1.0);
    //diff += clamp(gedepth_texture(uv, pixelSize, 0, -1) - depth, 0.0, 1.0);
    //return floor(smoothstep(0.01, 0.02, diff) * 2.) / 2.;
//}
//float neighborNormalEdgeIndicator(vec2 uv, vec2 pixelSize, int x, int y, float depth, vec3 normal) {
    //float depthDiff = gedepth_texture(uv, pixelSize, x, y) - depth;
    //// Edge pixels should yield to faces who's normals are closer to the bias normal.
    //vec3 normalEdgeBias = vec3(1., 1., 1.); // This should probably be a parameter.
    //float normalDiff = dot(normal - genormal_roughness_texture(uv, pixelSize, x, y), normalEdgeBias);
    //float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
    //// Only the shallower pixel should detect the normal edge.
    //float depthIndicator = clamp(sign(depthDiff * .25 + .0025), 0.0, 1.0);
    //return distance(normal, genormal_roughness_texture(uv, pixelSize, x, y)) * depthIndicator * normalIndicator;
//}
//float normalEdgeIndicator(vec2 uv, vec2 pixelSize) {
    //float depth = gedepth_texture(uv, pixelSize, 0, 0);
    //vec3 normal = genormal_roughness_texture(uv, pixelSize, 0, 0);
    //float indicator = 0.0;
    //indicator += neighborNormalEdgeIndicator(uv, pixelSize, 0, -1, depth, normal);
    //indicator += neighborNormalEdgeIndicator(uv, pixelSize, 0, 1, depth, normal);
    //indicator += neighborNormalEdgeIndicator(uv, pixelSize, -1, 0, depth, normal);
    //indicator += neighborNormalEdgeIndicator(uv, pixelSize, 1, 0, depth, normal);
    //return step(0.1, indicator);
//}
//void fragment() {
    //vec4 texel = texture(screen_texture, SCREEN_UV);
    //vec2 SCREEN_PIXEL_SIZE = vec2(1.) / vec2(textureSize(screen_texture, 0));
    //float dei = depthEdgeIndicator(SCREEN_UV, SCREEN_PIXEL_SIZE);
    //float nei = normalEdgeIndicator(SCREEN_UV, SCREEN_PIXEL_SIZE);
    //float coefficient = dei > 0.0 ? (1.0 - depthEdgeCoefficient * dei) : (1. + normalEdgeCoefficient * nei);
    //ALBEDO = texel.rgb * coefficient;
//}



shader_type spatial;
render_mode blend_add, depth_draw_never;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform float depth_threshold : hint_range(0, 1) = 0.05;
uniform float reverse_depth_threshold : hint_range(0, 1) = 0.25;
uniform float normal_threshold : hint_range(0, 1) = 0.6;

uniform float darken_amount : hint_range(0, 1, 0.01) = 0.3;
uniform float lighten_amount : hint_range(0, 10, 0.01) = 1.5;

uniform vec3 normal_edge_bias = vec3(1, 1, 1);
uniform vec3 light_direction = vec3(-0.96, -0.18, 0.2);

float get_depth(vec2 screen_uv, mat4 inv_projection_matrix) {
	float depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
}

void fragment() {
	float depth = get_depth(SCREEN_UV, INV_PROJECTION_MATRIX);
	vec3 normal = texture(normal_texture, SCREEN_UV).xyz * 2.0 - 1.0;
	vec2 texel_size = 1.0 / VIEWPORT_SIZE.xy;

	vec2 uvs[4];
	uvs[0] = vec2(SCREEN_UV.x, min(1.0 - 0.001, SCREEN_UV.y + texel_size.y));
	uvs[1] = vec2(SCREEN_UV.x, max(0.0, SCREEN_UV.y - texel_size.y));
	uvs[2] = vec2(min(1.0 - 0.001, SCREEN_UV.x + texel_size.x), SCREEN_UV.y);
	uvs[3] = vec2(max(0.0, SCREEN_UV.x - texel_size.x), SCREEN_UV.y);

	float depth_diff = 0.0;
	float depth_diff_reversed = 0.0;
	float nearest_depth = depth;
	vec2 nearest_uv = SCREEN_UV;

	float normal_sum = 0.0;
	for (int i = 0; i < 4; i++) {
		float d = get_depth(uvs[i], INV_PROJECTION_MATRIX);
		depth_diff += depth - d;
		depth_diff_reversed += d - depth;

		if (d < nearest_depth) {
			nearest_depth = d;
			nearest_uv = uvs[i];
		}

		vec3 n = texture(normal_texture, uvs[i]).xyz * 2.0 - 1.0;
		vec3 normal_diff = normal - n;

		// Edge pixels should yield to the normal closest to the bias direction
		float normal_bias_diff = dot(normal_diff, normal_edge_bias);
		float normal_indicator = smoothstep(-0.01, 0.01, normal_bias_diff);

		normal_sum += dot(normal_diff, normal_diff) * normal_indicator;
	}
	float depth_edge = step(depth_threshold, depth_diff);

	// The reverse depth sum produces depth lines inside of the object, but they don't look as nice as the normal depth_diff
	// Instead, we can use this value to mask the normal edge along the outside of the object
	float reverse_depth_edge = step(reverse_depth_threshold, depth_diff_reversed);

	float indicator = sqrt(normal_sum);
	float normal_edge = step(normal_threshold, indicator - reverse_depth_edge);

	vec3 original = texture(screen_texture, SCREEN_UV).rgb;
	vec3 nearest = texture(screen_texture, nearest_uv).rgb;

	mat3 view_to_world_normal_mat = mat3(
            INV_VIEW_MATRIX[0].xyz,
            INV_VIEW_MATRIX[1].xyz,
            INV_VIEW_MATRIX[2].xyz
	);
	float ld = dot((view_to_world_normal_mat * normal), normalize(light_direction));

	vec3 depth_col = nearest * darken_amount;
	vec3 normal_col = original * (ld > 0.0 ? darken_amount : lighten_amount);
	vec3 edge_mix = mix(normal_col, depth_col, depth_edge);

	ALBEDO = mix(original, edge_mix, (depth_edge > 0.0 ? depth_edge : normal_edge));
}