shader_type canvas_item;

uniform float opacity : hint_range(0.0, 1.0) = 0.1;
uniform float line_thickness : hint_range(0.5, 2.0) = 1.0;

void fragment() {
    // Obtenir la taille de l'écran
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;

    // Créer les lignes horizontales
    float h_line = 0.9 + opacity * abs(sin(screen_size.y * PI * UV.y * line_thickness));

    // Créer les lignes verticales
    float v_line = 0.9 + opacity * abs(sin(screen_size.x * PI * UV.x * line_thickness));

    // Combiner les lignes horizontales et verticales
    float grid = min(h_line, v_line);

    // Appliquer l'effet de grille
    COLOR.rgb *= vec3(grid);
}