extends Control

func _input(event: InputEvent) -> void :
	if event is InputEventMouseMotion or event is InputEventScreenTouch:
		modulate = Color.TRANSPARENT
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		modulate = Color.WHITE
