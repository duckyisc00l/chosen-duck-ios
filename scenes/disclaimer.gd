extends Control

func _input(event: InputEvent) -> void :
	if Input.is_action_just_pressed("startlazy"):
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")

func _ready() -> void :
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
