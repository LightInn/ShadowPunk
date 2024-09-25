shader_type spatial;

render_mode depth_prepass_alpha, unshaded;

uniform sampler2D noiseTexture : source_color, filter_linear_mipmap, repeat_enable;
uniform bool isSoft = false;
uniform float speed : hint_range(0.0, 1.0) = 0.1;
uniform float brightness : hint_range(0.0, 2.0) = 0.1;
uniform float threshold : hint_range(0.0, 2.0) = 0.1;
uniform float fluffiness : hint_range(0.0, 2.0) = 0.1;

void fragment() {
    // Mixing two time-shifted textures to create fluffiness
    vec4 noise1 = texture(noiseTexture, fract(UV + TIME * 2.5 * speed / 10.0));
    vec4 noise2 = texture(noiseTexture, fract(UV + TIME * (2.5 + fluffiness * 3.0) * speed / 10.0));
    vec4 combinedNoise = noise1 + noise2;
    
    if (isSoft) {
        // Creating smooth transitions using smoothstep
        combinedNoise.a = combinedNoise.r;
        ALBEDO = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise.rgb) * brightness;
        ALPHA = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise.a);
    } else {
        // Creating hard transitions
        ALBEDO = combinedNoise.rgb * brightness;
        ALPHA = (combinedNoise.r >= threshold) ? 1.0 : 0.0;
    }
}