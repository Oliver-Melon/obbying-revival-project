shader_type spatial;

uniform vec3 base_color: source_color = vec3(0.0,0.0,0.0);
uniform sampler2D albedo_texture : source_color, repeat_enable;
uniform vec2 tiling_scale = vec2(0.25, 0.25);
uniform float sharpness : hint_range(0.0, 50.0) = 10.0;
uniform float transparency: hint_range(0.0, 1.0, 0.01) = 0;

varying vec3 scale;
varying vec3 local_pos;
varying vec3 local_normal;

void vertex() {
    // Object scale
    scale = vec3(
        length(MODEL_MATRIX[0].xyz),
        length(MODEL_MATRIX[1].xyz),
        length(MODEL_MATRIX[2].xyz)
    );
	
    local_pos = (VERTEX) * scale;
    local_normal = abs(NORMAL);
}

void fragment() {
    vec2 uv_x = local_pos.zy * tiling_scale;
    vec2 uv_y = local_pos.xz * tiling_scale;
    vec2 uv_z = local_pos.xy * tiling_scale;

    vec3 tex_x = texture(albedo_texture, uv_x).rgb;
    vec3 tex_y = texture(albedo_texture, uv_y).rgb;
    vec3 tex_z = texture(albedo_texture, uv_z).rgb;
    
    vec3 weights = local_normal;
    weights = pow(weights, vec3(sharpness));
    weights /= (weights.x + weights.y + weights.z);
    
    vec3 final_texture_color = tex_x * weights.x + tex_y * weights.y + tex_z * weights.z;
    ALBEDO = mix(final_texture_color, base_color, transparency);
}