extends Area3D
class_name Spawner

@export var cooldownMin: float
@export var cooldownMax: float

@export var creatureCap: int


@export var commonTable: Array
@export var uncommonTable: Array
@export var rareTable: Array
@export var superRareTable: Array


@export var commonTableN: Array
@export var uncommonTableN: Array
@export var rareTableN: Array
@export var superRareTableN: Array

@onready var cooldown: float = randf_range(cooldownMin, cooldownMax) / 2.0

const CREATURE = preload("res://branches/entities/creature.tscn")

func _physics_process(delta: float) -> void :
	if cooldown > 0.0:
		cooldown -= delta
	else:
		cooldown = randf_range(cooldownMin, cooldownMax)

		var counted: int = 0

		for i in get_tree().get_nodes_in_group("SPAWNED00"):
			if is_instance_valid(i):
				if i.global_position.distance_to(get_tree().get_first_node_in_group("PLAYERS").global_position) > 30.0:
					i.queue_free()
				else:
					counted += 1

		if counted >= creatureCap:
			return

		var decisionCreature = ""

		if randi_range(1, 4) == 1 and (uncommonTable if not World.time else uncommonTableN).size() > 0:
			decisionCreature = (uncommonTable if not World.time else uncommonTableN).pick_random()
		elif randi_range(1, 10) == 1 and (rareTable if not World.time else rareTableN).size() > 0:
			decisionCreature = (rareTable if not World.time else rareTableN).pick_random()
		elif randi_range(1, 20) == 1 and (superRareTable if not World.time else superRareTableN).size() > 0:
			decisionCreature = (superRareTable if not World.time else superRareTableN).pick_random()
		elif (commonTable if not World.time else commonTableN).size() > 0:
			decisionCreature = (commonTable if not World.time else commonTableN).pick_random()

		if decisionCreature != "":
			for i in get_overlapping_bodies():
				if i is Creature:
					if i.isPlayer:
						var instance = CREATURE.instantiate()
						instance.creatureType = decisionCreature
						get_parent().add_child(instance)
						instance.add_to_group("SPAWNED00")
						var posFin: Vector3
						for e in range(900):
							posFin = i.position + (Vector3(5 * randf_range(-1.5, 1.5), 0, 5 * randf_range(-1.5, 1.5)) * 3.0)
							if posFin.distance_to(i.position) > 20.0 and instance.get_node("RayCast3D").get_collider():
								break
						instance.position = posFin
