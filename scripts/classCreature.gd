extends CharacterBody3D
class_name Creature

var SPEED = 5.0

var ATTACK = 1

const ITEM = preload("res://branches/entities/item.tscn")

var loadedAPP = false

signal tookDamage(dmg: int, author: Creature)
signal death
signal respawn

var slotHelmet = [0, "empty", "colorless"]
var slotSword = [0, "empty", "colorless"]
var slotPickaxe = [0, "empty", "colorless"]

var holdingSlot = 0

var backwardsImpulse = 0.0
var knockback = Vector3.ZERO
var stun = 0.0
@export var isPlayer: bool
var appLoad

var warp: Warp

var HP: int

var bh = 0

var behaviors = []

var JSON_CREATURES = FileAccess.get_file_as_string("res://info/creatures.json")

var loadAppearance

@onready var readJson = JSON.parse_string(JSON_CREATURES)

@export var creatureType: String

var programmedDrops = []

var randomHitSounds = []

var randomDeathSounds = []

var randomLivingSounds = []

func _ready() -> void :

	if isPlayer:
		add_to_group("PLAYERS")

	var section: Dictionary = readJson[creatureType]
	HP = section["hlt"]
	ATTACK = section["atk"]
	SPEED = section["spd"] / 2.0
	if section.has("custom-behaviors"):
		behaviors = section["custom-behaviors"]
	if section.has("behavior"):
		bh = section["behavior"]
	if section.has("drops-full"):
		for i in section["drops-full"]:
			programmedDrops.append(i)
	if section.has("drops-half"):
		for i in section["drops-half"]:
			if randi_range(1, 2) == 1:
				programmedDrops.append(i)
	if section.has("drops-third"):
		for i in section["drops-third"]:
			if randi_range(1, 3) == 1:
				programmedDrops.append(i)
	if section.has("drops-ten"):
		for i in section["drops-ten"]:
			if randi_range(1, 10) == 1:
				programmedDrops.append(i)
	print(programmedDrops)
	for i in readJson[creatureType]["sounds-hit"]:
		randomHitSounds.append(load("res://assets/sound/sfx/creatures/" + i))
	for i in readJson[creatureType]["sounds-death"]:
		randomDeathSounds.append(load("res://assets/sound/sfx/creatures/" + i))
	for i in readJson[creatureType]["sounds-living"]:
		randomLivingSounds.append(load("res://assets/sound/sfx/creatures/" + i))
	if "supersight" in behaviors:
		$DETECTIONBOX / CollisionShape3D.scale *= 2

	$duck1.queue_free()
	await get_tree().process_frame
	appLoad = section["app"]

	if appLoad == "chosen":
		appLoad = "goose" if SAVE.info["chosen"] == 2 else "duck"
	elif appLoad == "contra-chosen":
		appLoad = "goose" if SAVE.info["chosen"] == 1 or SAVE.info["chosen"] == 0 else "duck"

	loadAppearance = load("res://branches/3dchar/" + appLoad + "/char.tscn")
	var instance = loadAppearance.instantiate()
	instance.scale = Vector3.ONE * 0.3
	add_child(instance)
	await get_tree().process_frame
	loadedAPP = true
	if get_node_or_null("CamPivot"):
		$CamPivot.position = global_position + Vector3(0, 3.5, 9.0)
	if creatureType.find("bud0"):
		add_to_group("npc_bud0")
	await get_tree().process_frame
	if "spawn-above" in behaviors:
		global_position += Vector3(0, 30, 0)

func _damage(dmg: int = 1, author: Creature = null, toolType: String = "none", toolName: String = "none"):
	if author == self or HP <= 0:
		return
	if author.isPlayer == false or not "ally" in behaviors:
		HP = clamp(HP - dmg, 0, 9999)
	tookDamage.emit(dmg, author)
	if isPlayer:
		$CamPivot / Camera3D / CameraShake3DNode._custom_shake(1, 0.2)
	if HP <= 0:
		if author:
			if author.isPlayer == false:
				if author.target == self:
					author.target = null
		if randomDeathSounds.size() > 0:
			$SOUND / LIVING_HIT.stream = randomDeathSounds.pick_random()
			$SOUND / LIVING_HIT.stop()
			$SOUND / LIVING_HIT.play()
		death.emit()
		if not isPlayer:
			for i in programmedDrops:
				var drop = createDrop(global_position, i)
			var clone = $FX / GPUParticles3D.duplicate()
			clone.global_position = global_position
			get_parent().add_child(clone)
			await get_tree().process_frame
			visible = false
			clone.emitting = true
			await clone.finished
			clone.queue_free()
			await get_tree().create_timer(2).timeout
			queue_free()
		else:
			var clone = $FX / GPUParticles3D.duplicate()
			clone.global_position = global_position
			get_parent().add_child(clone)
			await get_tree().process_frame
			visible = false
			clone.emitting = true
			await clone.finished
			clone.queue_free()
	else:
		$SOUND / LIVING_HIT.stream = randomHitSounds.pick_random()
		$SOUND / LIVING_HIT.stop()
		$SOUND / LIVING_HIT.play()
		if author.isPlayer == false or not "ally" in behaviors:
			$HB.visible = true
			for i in range(30 / 3):
				$HB.visible = not $HB.visible
				for o in range(4):
					await get_tree().process_frame
			$HB.visible = false

func createDrop(pos: Vector3, itemChosen: String) -> Item:
	var item = ITEM.instantiate()
	item.itemName = itemChosen
	item.global_position = pos
	get_parent().add_child(item)
	return item

func _applyKB(dir0: Vector3):
	backwardsImpulse = 0.2
	knockback = dir0 * 3
