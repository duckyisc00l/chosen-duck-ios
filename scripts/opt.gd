extends Control

@onready var order = get_children()

@export var selected: Control

func _ready() -> void :
	selected.modulate = Color.YELLOW

func _input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		for i in order:
			i.modulate = Color.WHITE
	elif event is InputEventJoypadMotion or event is InputEventJoypadButton:
		for i in order:
			i.modulate = Color.WHITE
		selected.modulate = Color.YELLOW

func _forwardSelect():
	if visible:
		selected = order[(order.find(selected) + 1) if order.find(selected) < order.size() - 1 else 0]
		for i in order:
			i.modulate = Color.WHITE
		selected.modulate = Color.YELLOW

func _backSelect():
	if visible:
		selected = order[(order.find(selected) - 1) if order.find(selected) > 0 else order.size() - 1]
		for i in order:
			i.modulate = Color.WHITE
		selected.modulate = Color.YELLOW
