extends Control


var toLoad = ["res://scenes/3d.tscn", "res://branches/entities/creature.tscn", "res://branches/entities/prop.tscn", "res://branches/entities/item.tscn"]

func get_files(path: String) -> Array[String]:
	var files: Array[String] = []

	var dir: = DirAccess.open(path)
	if dir == null:
		return files

	dir.list_dir_begin()

	var file_name: = dir.get_next()

	while file_name != "":
		if !dir.current_is_dir():
			files.append(path.path_join(file_name))

		file_name = dir.get_next()

	dir.list_dir_end()

	return files

func _ready() -> void :
	var all_files: Array[String] = []
	all_files.append_array(get_files("res://branches/items"))
	all_files.append_array(get_files("res://branches/3dchar"))
	for i in all_files:
		toLoad.append(i)
	await get_tree().create_timer(1).timeout
	$TextureRect / AnimatedSprite2D.play("default")
	$TextureRect / AnimatedSprite2D.modulate = Color.WHITE_SMOKE
	for i in toLoad:
		if i.find("remap") == -1:
			var load1 = load(i)
			$Label.text = "... " + i + " (1/2)"
			for o in range(2):
				await get_tree().process_frame
			var instance = load1.instantiate()

			$Label.text = "... " + i + " (2/2)"
			for o in range(2):
				await get_tree().process_frame
			instance.queue_free()
	$Label.text = "finalizing... (1/2)"
	World.canLoad.emit()
	$Label.text = "finalizing... (2/2)"
	get_tree().change_scene_to_file("res://scenes/3d.tscn")
