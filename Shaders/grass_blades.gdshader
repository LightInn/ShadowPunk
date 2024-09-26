shader_type spatial;
render_mode diffuse_toon, specular_toon;

uniform vec3 albedo : source_color = vec3(0.81, 0.95, 0.27);
uniform float ambient_light : hint_range(0.0, 1.0) = 0.1;


uniform float collapse_factor : hint_range(0.0, 1.0) = 1.0;
void vertex() {
    // Calculer un facteur basé sur la hauteur du vertex
    float height_factor = smoothstep(1.0, 10.0, VERTEX.y);
    
    // Amplitude de base du mouvement
    float base_amplitude_x = 5.0 * 0.2;
    float base_amplitude_z = 5.0 * 0.15;
    
    // Appliquer le mouvement avec une amplitude modulée par la hauteur
    VERTEX.x += sin(NODE_POSITION_WORLD.x + TIME) * base_amplitude_x * (0.0 + height_factor);
    VERTEX.z += cos(NODE_POSITION_WORLD.z + TIME) * base_amplitude_z * (0.0 + height_factor);
	
	VERTEX = mix(VERTEX,  vec3(0.0, 0.0, 0.0), collapse_factor);
}

void fragment() {
    ALBEDO = albedo;

	RIM = 0.;
	
}

void light() {
    // Calculer la position du centre de l'objet dans l'espace vue
    vec3 view_center = (INV_VIEW_MATRIX * MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
    
    // Calculer l'atténuation basée sur la distance au centre de l'objet
    float dist = length(view_center - LIGHT);
    float custom_attenuation = 1.0 / (1.0 + dist * dist);
    
    // Si c'est une lumière directionnelle, on ignore l'atténuation basée sur la distance
    if (LIGHT_IS_DIRECTIONAL) {
        custom_attenuation = 1.0;
    }
    
    // Combiner avec l'atténuation fournie par Godot (pour les ombres, etc.)
    custom_attenuation *= ATTENUATION;
    
    // Calculer la contribution de la lumière
    vec3 light_contribution = ALBEDO * custom_attenuation * LIGHT_COLOR;
    
    // Ajouter la lumière ambiante
    //vec3 ambient = ALBEDO * ambient_light;
    
    // Combiner la contribution de la lumière et la lumière ambiante, puis clamp
    DIFFUSE_LIGHT += clamp(light_contribution, vec3(0.0), vec3(0.816));
	//DIFFUSE_LIGHT = vec3(0.);
	
	    // Calculer la position du centre de l'objet dans l'espace vue
}