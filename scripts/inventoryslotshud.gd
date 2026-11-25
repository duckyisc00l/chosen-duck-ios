extends Control

@export var Player: Creature

const ICONSLOT_MT = preload("res://assets/hud/slotduck.png")
const ICONSLOT_FL = preload("res://assets/hud/slotnoduck.png")

func updateItems():
	get_node("Slot1/ITEMICON").visible = Player.slotSword[1] != "empty"
	get_node("Slot1/ItemName").text = Player.slotSword[1]
	if get_node("Slot1/ITEMICON").visible:
		get_node("Slot1").texture = ICONSLOT_FL
		get_node("Slot1/ITEMICON").texture = load("res://assets/items/" + Player.slotSword[1] + ".png") if FileAccess.file_exists("res://assets/items/" + Player.slotSword[1] + ".png") else load("res://icon.svg")
	else:
		get_node("Slot1").texture = ICONSLOT_MT
	get_node("Slot2/ITEMICON").visible = Player.slotPickaxe[1] != "empty"
	get_node("Slot2/ItemName").text = Player.slotPickaxe[1]
	if get_node("Slot2/ITEMICON").visible:
		get_node("Slot2").texture = ICONSLOT_FL
		get_node("Slot2/ITEMICON").texture = load("res://assets/items/" + Player.slotPickaxe[1] + ".png") if FileAccess.file_exists("res://assets/items/" + Player.slotPickaxe[1] + ".png") else load("res://icon.svg")
	else:
		get_node("Slot2").texture = ICONSLOT_MT
	for i in range(1, 6):
		if Player.holdingSlot == i:
			get_node("Slot" + str(i) + "/ItemName").visible = true
			get_node("Slot" + str(i) + "/AnimationPlayer").play("appearItemName")
		else:
			get_node("Slot" + str(i) + "/ItemName").visible = false

func _ready() -> void :
	Player.changeitem.connect(updateItems)

func _input(event: InputEvent) -> void :
	if Input.is_action_pressed("move_invshow") and Player.dialogQueue.size() == 0:
		Player.timeInv = 1.0

func _process(delta: float) -> void :
	position = lerp(position, Vector2(65.469, 96.667) if Player.timeInv > 0.0 else Vector2(65.469, 178.0), delta * 16)
