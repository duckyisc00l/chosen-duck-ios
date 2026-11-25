extends Node

@export var group: String = "crt_filter"

func _ready() -> void :
	add_to_group(group)
