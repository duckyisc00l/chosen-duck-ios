extends CharacterBody3D
class_name Prop

var JSON_PROPS = FileAccess.get_file_as_string("res://info/props.json")

@onready var readJson = JSON.parse_string(JSON_PROPS)

var JSON_ITEMS = FileAccess.get_file_as_string("res://info/items.json")

@onready var readJsonITM = JSON.parse_string(JSON_ITEMS)


@export var propName: String = "tree"

var HP: int

var MAXHP: int

var stepDrop: int = 0

var countHarsh = 10

const ITEM = preload("res://branches/entities/item.tscn")

var spacementDrops = Vector3(1.5, 1, 0)

var programmedDrops = {
	"0": ["stick"], 
	"1": ["stick"], 
	"9": ["log"], 
}

func createDrop(pos: Vector3, itemChosen: String) -> Item:
	var item = ITEM.instantiate()
	item.itemName = itemChosen
	item.global_position = pos
	get_parent().add_child(item)
	return item

func _damage(dmg: int = 1, author: Creature = null, toolType: String = "none", toolName: String = "none"):
	if toolType != "none" and readJson[propName]["tool"] == toolType:
		if readJsonITM["_basic"]["tools"][toolType].has(toolName):
			dmg = readJsonITM["_basic"]["tools"][toolType][toolName]
	if HP != -1 or toolType == readJson[propName]["tool"]:
		HP -= dmg
	elif countHarsh > 0:
		countHarsh -= 1
	elif author.isPlayer:
		countHarsh = 10
		var dialogs = {
			"eng": ["those rocks are way too harsh to be broken with your wings!", "andrew", "", "those rocks are way too harsh to be broken with your wings!"], 
			"pt-br": ["essas pedras são duras demais para serem quebradas com as asas!", "andrew", "", "essas pedras são duras demais para serem quebradas com as asas!"], 
		}
		var final = "eng"
		if dialogs.has(CONFIG.configs["language"]):
			final = CONFIG.configs["language"]
		author.dialogQueue.append(dialogs[final])

	$SOUND / HIT.stop()
	$SOUND / HIT.volume_db = randf_range(-5, 0)
	$SOUND / HIT.play()
	if stepDrop == 0 and programmedDrops["0"].size() > 0:
		for i in programmedDrops["0"]:
			var drop = createDrop(global_position + spacementDrops * Vector3((1 if randi_range(1, 2) == 1 else -1), 1, 1), i)
		stepDrop += 1
	if stepDrop == 1 and HP <= int(MAXHP / 2.0) and programmedDrops["1"].size() > 0:
		for i in programmedDrops["1"]:
			var drop = createDrop(global_position + spacementDrops * Vector3((1 if randi_range(1, 2) == 1 else -1), 1, 1), i)
		stepDrop += 1
	if HP <= 0:
		if HP != -1 or toolType == readJson[propName]["tool"]:
			if programmedDrops["9"].size() > 0:
				for i in programmedDrops["9"]:
					var drop = createDrop(global_position + spacementDrops * Vector3((1 if randi_range(1, 2) == 1 else -1), 1, 1), i)
			visible = false
			$CollisionShape3D.queue_free()
			var clone = $FX / GPUParticles3D.duplicate()
			get_parent().add_child(clone)
			clone.global_position = global_position + Vector3(0, 1.847, 0)
			clone.emitting = true
			await clone.finished
			clone.queue_free()
			queue_free()
	else:
		shake(0.2, 0.125)
		var clone = $FX / GPUParticles3D.duplicate()
		$FX.add_child(clone)
		clone.emitting = true
		await clone.finished
		clone.queue_free()

@export var shake_strength: float = 0.2
@export var shake_decay: float = 3.0

var shake_time: = 0.0
var original_position: Vector3

func _ready():
	var propinfo = readJson[propName]
	MAXHP = propinfo["health"]
	HP = propinfo["health"]
	programmedDrops = propinfo["programmedDrops"]
	if get_node_or_null("APP"):
		get_node("APP").queue_free()
	while get_node_or_null("APP"):
		await get_tree().process_frame
	var loadAPP = load("res://branches/props/" + propName + ".tscn").instantiate()
	add_child(loadAPP)
	var loadCOL = load("res://branches/props/collision/" + propName + ".tscn").instantiate()
	add_child(loadCOL)
	await get_tree().process_frame
	rotation = Vector3(0, randf_range(-180, 180), 0)
	original_position = $APP.position

func shake(duration: float, strength: float = shake_strength):
	shake_time = duration
	shake_strength = strength

func _process(delta):
	if shake_time > 0:
		shake_time -= delta

		var offset = Vector3(
			randf_range(-1, 1), 
			randf_range(-1, 1), 
			randf_range(-1, 1)
		) * shake_strength
		$APP.position = original_position + offset
		shake_strength = lerp(shake_strength, 0.0, shake_decay * delta)
	else:
		$APP.position = original_position
