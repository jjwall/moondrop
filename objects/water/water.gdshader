shader_type canvas_item;

uniform vec2 tiled_factor = vec2(5.0, 1.0);
uniform float aspect_ratio = 7; //0.7533; // = 0.5;

uniform vec2 offset_scale = vec2(2.0, 2.0);

void fragment(){
	vec2 tiled_uvs = UV * tiled_factor;
	tiled_uvs.y *= aspect_ratio;
	
	vec2 waves_uv_offset;
	waves_uv_offset.x = cos(TIME + (tiled_uvs.x + tiled_uvs.y) * offset_scale.x);
	waves_uv_offset.y = sin(TIME + (tiled_uvs.x + tiled_uvs.y) * offset_scale.y);
	
	//COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR = texture( TEXTURE, tiled_uvs + waves_uv_offset * 0.1);
	
	//COLOR = texture ( TEXTURE, tiled_uvs);
	
	//COLOR = vec4(tiled_uvs, 0.0, 1.0);
}