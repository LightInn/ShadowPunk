shader_type spatial;
render_mode depth_prepass_alpha, unshaded;

uniform sampler2D noiseTexture : source_color, filter_linear_mipmap, repeat_enable;
uniform bool isSoft = false;
uniform float speed : hint_range(0.0, 1.0) = 0.1;
uniform float brightness : hint_range(0.0, 2.0) = 0.1;
uniform float threshold : hint_range(0.0, 5.0) = 0.5;
uniform float fluffiness : hint_range(0.0, 2.0) = 0.1;

// Nouveaux uniformes pour la deuxième couche
uniform float layer2_scale : hint_range(0.5, 2.0) = 1.5;
uniform float layer2_opacity : hint_range(0.0, 1.0) = 0.7;
uniform float layer2_darkness : hint_range(0.0, 1.0) = 0.3;

void fragment() {
    // Première couche (large)
    vec4 noise1 = texture(noiseTexture, fract(UV + TIME * 2.5 * speed / 10.0));
    vec4 noise2 = texture(noiseTexture, fract(UV + TIME * (2.5 + fluffiness * 3.0) * speed / 10.0));
    vec4 combinedNoise = noise1 + noise2;
    
    // Deuxième couche (plus petite et plus sombre)
    vec4 noise3 = texture(noiseTexture, fract(UV * layer2_scale + TIME * 3.0 * speed / 10.0));
    vec4 noise4 = texture(noiseTexture, fract(UV * layer2_scale + TIME * (3.0 + fluffiness * 2.0) * speed / 10.0));
    vec4 combinedNoise2 = noise3 + noise4;

    vec3 finalColor;
    float finalAlpha;

    if (isSoft) {
        // Première couche
        vec3 color1 = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise.rgb) * brightness;
        float alpha1 = smoothstep(threshold - 0.3, threshold + 0.3, combinedNoise.a);

        // Deuxième couche
        vec3 color2 = smoothstep(threshold - 0.2, threshold + 0.2, combinedNoise2.rgb) * brightness * (1.0 - layer2_darkness);
        float alpha2 = smoothstep(threshold - 0.2, threshold + 0.2, combinedNoise2.a) * layer2_opacity;

        // Combiner les deux couches
        finalColor = mix(color1, color2, alpha2);
        finalAlpha = max(alpha1, alpha2);
    } else {
        // Première couche
        vec3 color1 = combinedNoise.rgb * brightness;
        float alpha1 = (combinedNoise.r >= threshold) ? 1.0 : 0.0;

        // Deuxième couche
        vec3 color2 = combinedNoise2.rgb * brightness * (1.0 - layer2_darkness);
        float alpha2 = (combinedNoise2.r >= threshold + 0.1) ? layer2_opacity : 0.0;

        // Combiner les deux couches
        finalColor = mix(color1, color2, alpha2);
        finalAlpha = max(alpha1, alpha2);
    }

    ALBEDO = finalColor;
    ALPHA = finalAlpha;
}