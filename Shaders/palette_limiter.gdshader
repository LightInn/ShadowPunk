shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


uniform vec4 color_1 : source_color = vec4(0.090, 0.125, 0.220, 1.0);
uniform vec4 color_2 : source_color = vec4(0.145, 0.227, 0.369, 1.0);
uniform vec4 color_3 : source_color = vec4(0.235, 0.369, 0.545, 1.0);
uniform vec4 color_4 : source_color = vec4(0.310, 0.561, 0.729, 1.0);
uniform vec4 color_5 : source_color = vec4(0.451, 0.745, 0.827, 1.0);
uniform vec4 color_6 : source_color = vec4(0.643, 0.867, 0.859, 1.0);
uniform vec4 color_7 : source_color = vec4(0.098, 0.200, 0.176, 1.0);
uniform vec4 color_8 : source_color = vec4(0.145, 0.337, 0.180, 1.0);
uniform vec4 color_9 : source_color = vec4(0.275, 0.510, 0.196, 1.0);
uniform vec4 color_10 : source_color = vec4(0.459, 0.655, 0.263, 1.0);
uniform vec4 color_11 : source_color = vec4(0.659, 0.792, 0.345, 1.0);
uniform vec4 color_12 : source_color = vec4(0.816, 0.855, 0.569, 1.0);
uniform vec4 color_13 : source_color = vec4(0.302, 0.169, 0.196, 1.0);
uniform vec4 color_14 : source_color = vec4(0.478, 0.282, 0.255, 1.0);
uniform vec4 color_15 : source_color = vec4(0.678, 0.467, 0.341, 1.0);
uniform vec4 color_16 : source_color = vec4(0.753, 0.580, 0.451, 1.0);
uniform vec4 color_17 : source_color = vec4(0.843, 0.710, 0.580, 1.0);
uniform vec4 color_18 : source_color = vec4(0.906, 0.835, 0.702, 1.0);
uniform vec4 color_19 : source_color = vec4(0.204, 0.110, 0.153, 1.0);
uniform vec4 color_20 : source_color = vec4(0.376, 0.173, 0.173, 1.0);
uniform vec4 color_21 : source_color = vec4(0.533, 0.294, 0.169, 1.0);
uniform vec4 color_22 : source_color = vec4(0.745, 0.467, 0.169, 1.0);
uniform vec4 color_23 : source_color = vec4(0.871, 0.620, 0.255, 1.0);
uniform vec4 color_24 : source_color = vec4(0.910, 0.757, 0.439, 1.0);
uniform vec4 color_25 : source_color = vec4(0.141, 0.082, 0.153, 1.0);
uniform vec4 color_26 : source_color = vec4(0.255, 0.114, 0.192, 1.0);
uniform vec4 color_27 : source_color = vec4(0.459, 0.141, 0.220, 1.0);
uniform vec4 color_28 : source_color = vec4(0.647, 0.188, 0.188, 1.0);
uniform vec4 color_29 : source_color = vec4(0.812, 0.341, 0.235, 1.0);
uniform vec4 color_30 : source_color = vec4(0.855, 0.525, 0.243, 1.0);

uniform vec4 color_31 : source_color = vec4(0.118, 0.114, 0.224, 1.0);

uniform vec4 color_32 : source_color = vec4(0.251, 0.153, 0.318, 1.0);
uniform vec4 color_33 : source_color = vec4(0.478, 0.212, 0.482, 1.0);
uniform vec4 color_34 : source_color = vec4(0.635, 0.243, 0.549, 1.0);
uniform vec4 color_35 : source_color = vec4(0.776, 0.318, 0.592, 1.0);
uniform vec4 color_36 : source_color = vec4(0.875, 0.518, 0.647, 1.0);
uniform vec4 color_362 : source_color = vec4(0.875, 0.518, 0.647, 1.0);


uniform vec4 color_37 : source_color = vec4(0.035, 0.039, 0.078, 1.0);
uniform vec4 color_38 : source_color = vec4(0.063, 0.078, 0.122, 1.0);
uniform vec4 color_39 : source_color = vec4(0.082, 0.114, 0.157, 1.0);
uniform vec4 color_40 : source_color = vec4(0.125, 0.180, 0.216, 1.0);
uniform vec4 color_41 : source_color = vec4(0.224, 0.290, 0.314, 1.0);
uniform vec4 color_42 : source_color = vec4(0.341, 0.447, 0.467, 1.0);
uniform vec4 color_43 : source_color = vec4(0.506, 0.592, 0.588, 1.0);
uniform vec4 color_44 : source_color = vec4(0.659, 0.710, 0.698, 1.0);
uniform vec4 color_45 : source_color = vec4(0.780, 0.812, 0.800, 1.0);
uniform vec4 color_46 : source_color = vec4(0.922, 0.929, 0.914, 1.0);

void fragment() {
    vec4 colors[46] = {color_1, color_2, color_3, color_4, color_5, color_6, color_7, color_8, color_9, color_10,
                       color_11, color_12, color_13, color_14, color_15, color_16, color_17, color_18, color_19, color_20,
                       color_21, color_22, color_23, color_24, color_25, color_26, color_27, color_28, color_29, color_30,
                       color_31, color_32, color_33, color_34, color_35, color_36, color_37, color_38, color_39, color_40,
                       color_41, color_42, color_43, color_44, color_45, color_46};

    float min_diff = 1000.0;
    vec4 min_color = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 uv = SCREEN_UV;
    vec4 temp = textureLod(SCREEN_TEXTURE, uv, 0.0);

    for (int i = 0; i < 46; i++) {
        float curr_dist = distance(colors[i], temp);
        if (curr_dist < min_diff) {
            min_diff = curr_dist;
            min_color = colors[i];
        }
    }

    COLOR = vec4(min_color.rgb, 1.0);
}