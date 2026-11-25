extends Control

func _input(event: InputEvent) -> void :
	if Input.is_action_just_pressed("move_quit"):
		queue_free()
