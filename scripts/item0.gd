extends RigidBody3D
class_name Item

@export var itemName: String

@export var isStatic: bool

func _applyKB(to: Vector3):
	apply_central_impulse(to)

func _physics_process(delta: float) -> void :
	$RayCast3D.global_position = global_position
	$billboard.global_position = global_position + Vector3.UP
	if $RayCast3D.is_colliding():
		$Sprite3D.global_position = $RayCast3D.get_collision_point()
		$Sprite3D.visible = true
	else:
		$Sprite3D.visible = false

func pickUp(by: CharacterBody3D):
	if itemName == "torch":
		by.inventoryMaterial.append("coal")
	else:
		by.inventoryMaterial.append(itemName)
	by.itemGet.emit()
	by.itemChange.emit()
	queue_free()

func _ready() -> void :
	if itemName == "_rndflower":
		itemName = ["cyan-tulip", "poppy", "daisy"].pick_random()
	rotation_degrees.y = randf_range(-180, 180)
	if get_node_or_null("APP"):
		$APP.queue_free()
	if isStatic:
		$SOUND / SPAWN.queue_free()
		freeze = true
		rotation = Vector3(0, randf_range(-180, 180), 0)
	await get_tree().process_frame
	var loadapp = load("res://branches/items/" + itemName + ".tscn").instantiate()
	add_child(loadapp)
