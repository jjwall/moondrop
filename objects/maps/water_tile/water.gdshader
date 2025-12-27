shader_type canvas_item;

render_mode skip_vertex_transform;
uniform vec2 world_scale = vec2(1024.0, 1024.0);

void vertex() {
    VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
    UV = VERTEX / world_scale;
}

uniform vec2 tiled_factor = vec2(10.0, 10.0);
uniform float aspect_ratio = 0.5;
uniform vec2 offset_scale = vec2(2.0, 2.0);

void fragment() {
	//vec2 tiled_uvs = UV * tiled_factor;
	//vec2 tiled_uvs = floor(UV * tiled_factor / SCREEN_PIXEL_SIZE / 3.0) * SCREEN_PIXEL_SIZE * 3.0;
	vec2 s = 1.0 / (3.0) / TEXTURE_PIXEL_SIZE;
    vec2 tiled_uvs = floor(UV * s  * tiled_factor) / s;
	
	tiled_uvs.y *= aspect_ratio;
	
	vec2 waves_uv_offset;
	waves_uv_offset.x = cos(TIME + (tiled_uvs.x + tiled_uvs.y) * offset_scale.x);
	waves_uv_offset.y = sin(TIME + (tiled_uvs.x + tiled_uvs.y) * offset_scale.y);
	
	COLOR = texture(TEXTURE, tiled_uvs + waves_uv_offset * 0.1);
	
	//COLOR = texture(TEXTURE, tiled_uvs);
	//COLOR = vec4(tiled_uvs, 0.0, 1.0);
}