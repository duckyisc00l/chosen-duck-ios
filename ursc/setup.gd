







@tool
extends EditorScript


var shader_globals: = {
	"affine_texture_mapping": {
		"type": "bool", 
		"value": true
	}, 
	"fog_color": {
		"type": "color", 
		"value": Color(0, 0, 0, 1)
	}, 
	"fog_start_distance": {
		"type": "float", 
		"value": 0.0
	}, 
	"fog_end_distance": {
		"type": "float", 
		"value": 0.0
	}, 
	"cull_distance": {
		"type": "float", 
		"value": 64.0
	}, 
	"texture_filtering": {
		"type": "bool", 
		"value": false
	}, 
	"texture_lod_halve_distance": {
		"type": "float", 
		"value": 0.0
	}, 
	"vertex_snap_intensity": {
		"type": "int", 
		"value": 2
	}
}


func _run() -> void :
	for key: String in shader_globals:
		var full_key: = "shader_globals/%s" % key

		if not ProjectSettings.has_setting(full_key):
			ProjectSettings.set_setting(full_key, shader_globals[key])

	ProjectSettings.save()
	EditorInterface.restart_editor()
