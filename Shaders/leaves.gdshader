shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,diffuse_toon,specular_toon;

uniform sampler2D leaf_texture : source_color,filter_nearest_mipmap,repeat_enable;
uniform float spread : hint_range(0.0, 2.0) = 1.0;
uniform float size_variation : hint_range(0.0, 1.0) = 0.3;
uniform vec3 leaf_color : source_color = vec3(0.2, 0.8, 0.2);
uniform float wind_strength : hint_range(0.0, 1.0) = 0.1;
uniform float wind_speed : hint_range(0.0, 2.0) = 1.0;

varying vec3 vertex_position;

// Fonction de hashage rapide
uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >>  6u);
    x += (x <<  3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

// Génère un nombre aléatoire entre 0 et 1
float random(uint seed) {
    return float(hash(seed)) / 4294967295.0; // 2^32 - 1
}

void vertex() {
    vertex_position = VERTEX;

    // Utiliser l'index de l'instance pour la génération aléatoire
    uint id = uint(INSTANCE_ID);
    vec3 random_values = vec3(
        random(id),
        random(id + 1u),
        random(id + 2u)
    );

    // Positionner le billboard
    VERTEX += (random_values - 0.5) * spread;

    // Faire face à la caméra (billboard)
    //MODELVIEW_MATRIX = INV_VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(INV_VIEW_MATRIX[2].xyz), 0.0), MODEL_MATRIX[3]);

    // Varier la taille
    float size = 1.0 + (random_values.x - 0.5) * size_variation;
    VERTEX *= size;

    // Animation de vent simple
    float wind = sin(TIME * wind_speed + VERTEX.x + VERTEX.z) * wind_strength;
    VERTEX.x += wind;
    VERTEX.z += wind * 0.5;
}

void fragment() {
    // Échantillonner la texture de feuille
    vec4 tex = texture(leaf_texture, UV);

    // Appliquer la couleur et l'alpha
    ALBEDO = leaf_color * tex.rgb;
    ALPHA = tex.a;

    // Ajouter un peu de variation de couleur basée sur la position
    float color_variation = sin(vertex_position.x * 10.0) * 0.1 + sin(vertex_position.z * 10.0) * 0.1;
    ALBEDO += vec3(color_variation);

    // Paramètres de base pour le rendu
    ROUGHNESS = 0.8;
    SPECULAR = 0.2;
}