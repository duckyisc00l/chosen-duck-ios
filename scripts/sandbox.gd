extends Control

@export var Player: Creature

var selected = -1

@onready var order = [$Control / slimer, $Control / metallico, $Control / plantsiform, $Control / bubck, $Control / slithe]

func _process(delta: float) -> void :
	if Input.is_action_just_pressed("move_sandbox"):
		visible = not visible
		CONFIG.tdi2 = not CONFIG.tdi2
	if Input.is_action_just_pressed("move_open_inv") and visible:
		World._changeTimeInstant()
	if Input.is_action_just_pressed("move_down") and visible:
		selected = clamp(selected + 1, 0, order.size() - 1)
		for i in order:
			i.modulate = Color.WHITE
		order[selected].modulate = Color.YELLOW
	if Input.is_action_just_pressed("move_up") and visible:
		selected = clamp(selected - 1, 0, order.size() - 1)
		for i in order:
			i.modulate = Color.WHITE
		order[selected].modulate = Color.YELLOW
	if Input.is_action_just_pressed("move_action") and visible:
		visible = not visible
		CONFIG.tdi2 = not CONFIG.tdi2
		match order[selected].name:
			"slimer":
				var instance = load("res://branches/entities/creature.tscn").instantiate()
				instance.creatureType = "slimer"
				Player.get_parent().add_child(instance)
				instance.position = Player.position
			"metallico":
				var instance = load("res://branches/entities/creature.tscn").instantiate()
				instance.creatureType = "metallico"
				Player.get_parent().add_child(instance)
				instance.position = Player.position
			"plantsiform":
				var instance = load("res://branches/entities/creature.tscn").instantiate()
				instance.creatureType = "plantsiform"
				Player.get_parent().add_child(instance)
				instance.position = Player.position
			"bubck":
				var instance = load("res://branches/entities/creature.tscn").instantiate()
				instance.creatureType = "bubck"
				Player.get_parent().add_child(instance)
				instance.position = Player.position
			"slithe":
				var instance = load("res://branches/entities/creature.tscn").instantiate()
				instance.creatureType = "slithe"
				Player.get_parent().add_child(instance)
				instance.position = Player.position

func _physics_process(delta: float) -> void :
	if selected != -1:
		$ColorRect2.global_position.y = lerp($ColorRect2.global_position.y, order[selected].global_position.y, delta * 32)
	$ColorRect2.visible = selected != -1
