extends ColorRect

var selected = 0

var inventorySpot = Vector2i.ZERO
var addedY = 0
var quantItem: int = 90
var onspot = 1

var onCraft = 0
var craftOrder: String = "default"

var timerCannotCraft: float = 0.0

const SLOTON = preload("res://assets/hud/slotnoduck.png")
const SLOTOFF = preload("res://assets/hud/slotduck.png")

var JSON_CRAFTING = FileAccess.get_file_as_string("res://info/crafting.json")
@onready var readJsonCRAFT = JSON.parse_string(JSON_CRAFTING)
var JSON_ITEMS = FileAccess.get_file_as_string("res://info/items.json")
@onready var readJsonITEMS = JSON.parse_string(JSON_ITEMS)

@export var player: CharacterBody3D

@onready var inventoryControls = [$XFunc, $Hud]
@onready var craftingControls = [$XFunc2, $AFunc2, $ItemCraftName, $ItemCenterCraft, $PrevItem, $NextItem, $StuffCraft]
@onready var equipmentControls = [$Slot1Main, $Slot2Main, $Slot3Main, $Slot4Main, $Slot5Main, $FrameDuck, $SubViewportContainer, $SArmor, $AFunc]

var mode: int = 0

func _input(event: InputEvent) -> void :
	if event is InputEventJoypadButton:
		mode = 0
	if event is InputEventKey or event is InputEventMouseButton:
		mode = 1

func _updateSelectedMenu():
	$IndINV.modulate = Color.YELLOW if selected == 0 else Color.WHITE
	$IndCraft.modulate = Color.YELLOW if selected == 1 else Color.WHITE
	$IndEquip.modulate = Color.YELLOW if selected == 2 else Color.WHITE
	for i in inventoryControls:
		i.visible = selected == 0
	for i in craftingControls:
		i.visible = selected == 1
	for i in equipmentControls:
		i.visible = selected == 2

func _convertSpot():
	return (inventorySpot.y * 3) + inventorySpot.x + 1

func _physics_process(delta: float) -> void :
	$StuffCraft / Cannot.position = lerp($StuffCraft / Cannot.position, (Vector2(136.0, 344.0)) if timerCannotCraft > 0.0 else (Vector2(136, 484.0)), delta * 8)
	if timerCannotCraft > 0.0:
		timerCannotCraft -= delta
	if selected and Input.is_action_pressed("hud_showinfo"):
		$Recipe.visible = true
	else:
		$Recipe.visible = false
	if CONFIG.canInput:
		if Input.is_action_just_pressed("move_open_inv") and not CONFIG.tdi2 and CONFIG.modetoload != 6 and player.dialogQueue.size() == 0 and !player.blockedInv:
			visible = not visible
			CONFIG.tempDISINP = visible
		if Input.is_action_just_pressed("move_quit") or Input.is_action_just_pressed("move_sandbox"):
			if visible:
				visible = false
				CONFIG.tempDISINP = visible
		if Input.is_action_just_pressed("move_shoulder_left") and visible:
			$GP_SHOULDERS / L / Control / label / AnimationPlayer.stop()
			$GP_SHOULDERS / L / Control / label / AnimationPlayer.play("lb")
			selected = selected - 1 if selected != 0 else 2
			_updateSelectedMenu()
		if Input.is_action_just_pressed("move_shoulder_right") and visible:
			$GP_SHOULDERS / R / Control / label / AnimationPlayer.stop()
			$GP_SHOULDERS / R / Control / label / AnimationPlayer.play("lb")
			selected = selected + 1 if selected != 2 else 0
			_updateSelectedMenu()
		if Input.is_action_just_pressed("move_action") and visible:
			if selected == 1:
				_craftAttempt()
		if (Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_next_mouse")) and visible:
			if selected == 1:
				_moveCraft(-1)
				$ItemCenterCraft.position.y = 170.0
		if (Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("move_prev_mouse")) and visible:
			if selected == 1:
				_moveCraft(1)
				$ItemCenterCraft.position.y = 170.0
		$ItemCenterCraft.position = lerp($ItemCenterCraft.position, Vector2(184.136, 120.0), delta * 8)

func _updateRestCraft():
	var centeritem = readJsonCRAFT["_order"][craftOrder][onCraft]

	var info: Dictionary = {
		"1": [], 
		"2": [], 
		"3": [], 
		"4": [], 
	}
	var arrayItemsUse: Array = readJsonCRAFT[centeritem]["uses"]
	var arrayItemsGive: Array = readJsonCRAFT[centeritem]["gives"]
	for e in arrayItemsUse:
		if not e in info["1"] and not e in info["2"] and not e in info["3"] and not e in info["4"]:
			for i in range(4):
				if info[str(i + 1)].size() == 0:
					info[str(i + 1)] = [e, arrayItemsUse.count(e)]
					break
	for i in range(4):
		if info[str(i + 1)].size() == 0:
			get_node("Recipe/S" + str(i + 1)).visible = false
		else:
			get_node("Recipe/S" + str(i + 1)).visible = true
			if FileAccess.file_exists("res://assets/items/" + info[str(i + 1)][0] + ".png"):
				get_node("Recipe/S" + str(i + 1) + "/Icon").texture = load("res://assets/items/" + info[str(i + 1)][0] + ".png")
			else:
				get_node("Recipe/S" + str(i + 1) + "/Icon").texture = load("res://icon.svg")
			get_node("Recipe/S" + str(i + 1) + "/label").text = "x" + str(info[str(i + 1)][1])

	$Recipe / Gives.text = "gives x" + str(arrayItemsGive.count(centeritem))

	var adaptedName = centeritem

	var displayList: Dictionary = readJsonITEMS["_basic"]["has-display"]

	if displayList.has(centeritem):
		adaptedName = displayList[centeritem]

	$ItemCraftName.text = adaptedName

	if FileAccess.file_exists("res://assets/items/" + centeritem + ".png"):
		$ItemCenterCraft.texture = load("res://assets/items/" + centeritem + ".png")
	else:
		$ItemCenterCraft.texture = load("res://icon.svg")

	var previtem = readJsonCRAFT["_order"][craftOrder][calcPrevious()]

	if FileAccess.file_exists("res://assets/items/" + previtem + ".png"):
		$PrevItem.texture = load("res://assets/items/" + previtem + ".png")
	else:
		$PrevItem.texture = load("res://icon.svg")

	var nextitem = readJsonCRAFT["_order"][craftOrder][calcNext()]

	if FileAccess.file_exists("res://assets/items/" + nextitem + ".png"):
		$NextItem.texture = load("res://assets/items/" + nextitem + ".png")
	else:
		$NextItem.texture = load("res://icon.svg")

func _moveCraft(dir: int):
	onCraft = calcPrevious() if dir == -1 else calcNext()
	$StuffCraft / Cannot.position = Vector2(136, 484.0)
	timerCannotCraft = 0.0
	_updateRestCraft()

func calcPrevious(basedOn: int = onCraft):
	return readJsonCRAFT["_order"][craftOrder].size() - 1 if basedOn == 0 else basedOn - 1

func calcNext(basedOn: int = onCraft):
	return 0 if basedOn == readJsonCRAFT["_order"][craftOrder].size() - 1 else basedOn + 1

func _ready() -> void :
	_updateSelectedMenu()
	_updateRestCraft()
	updateInv()

	var duck: Node3D = load("res://branches/3dchar/duck/char.tscn").instantiate()

	$SubViewportContainer / SubViewport.add_child(duck)

	$SubViewportContainer / SubViewport / duck1 / ANIM_IDLE.play("idle")
	player.itemChange.connect( func():
		updateInv()
	)
	$IndINV / Button.button_down.connect( func():
		selected = 0
		_updateSelectedMenu()
	)
	$IndCraft / Button.button_down.connect( func():
		selected = 1
		_updateSelectedMenu()
	)
	$IndEquip / Button.button_down.connect( func():
		selected = 2
		_updateSelectedMenu()
	)

	$ItemCenterCraft / Button.button_down.connect( func():
		_craftAttempt()
	)

	$PrevItem / Button.button_down.connect( func():
		_moveCraft(-1)
		$ItemCenterCraft.position.y = 170.0
	)

	$NextItem / Button.button_down.connect( func():
		_moveCraft(1)
		$ItemCenterCraft.position.y = 170.0
	)

func _craftAttempt():
	var centeritem = readJsonCRAFT[readJsonCRAFT["_order"][craftOrder][onCraft]]
	var afterInvMat: Array = player.inventoryMaterial
	for i in centeritem["uses"]:
		if afterInvMat.find(i) != -1:
			afterInvMat.remove_at(afterInvMat.find(i))
		else:
			timerCannotCraft = 1.0
			return
	if "PLACE" in centeritem["gives"]:
		player.inventoryMaterial = afterInvMat
		var PLACEABLE = load("res://branches/entities/item.tscn").instantiate()
		var playerRaycast = player.get_node("RayCast3D") as RayCast3D
		PLACEABLE.itemName = readJsonCRAFT["_order"][craftOrder][onCraft]
		PLACEABLE.isStatic = true
		PLACEABLE.global_position = playerRaycast.get_collision_point()
		get_tree().get_first_node_in_group("SCENECURRENT").add_child(PLACEABLE)
		player.changeitem.emit()
		updateInv()
	else:
		if centeritem["class"] == "material":
			for i in centeritem["gives"]:
				print(i)
				afterInvMat.append(i)
				await get_tree().process_frame
		print(afterInvMat)
		player.inventoryMaterial = afterInvMat
		if centeritem["class"] == "sword":
			player.slotSword[1] = readJsonCRAFT["_order"][craftOrder][onCraft]
		elif centeritem["class"] == "pickaxe":
			player.slotPickaxe[1] = readJsonCRAFT["_order"][craftOrder][onCraft]
		print(player.slotPickaxe)
		player.itemGet.emit()
		player.changeitem.emit()
		updateInv()
	visible = false
	CONFIG.tempDISINP = visible

func updateInv():
	for i in range(18):
		var indexSur = 1 + i
		var inventoryMat: Array = player.inventoryMaterial
		var sem_repetidos = []
		for item in inventoryMat:
			if not sem_repetidos.has(item):
				sem_repetidos.append(item)
		var indItemVer = sem_repetidos.size() > i
		var slot = get_node("Hud/Items/S" + str(indexSur))
		if indItemVer:
			var indItem = sem_repetidos.get(i)
			if FileAccess.file_exists("res://assets/items/" + indItem + ".png"):
				slot.get_node("Icon").texture = load("res://assets/items/" + indItem + ".png")
			else:
				slot.get_node("Icon").texture = load("res://icon.svg")
			slot.texture = SLOTON
			slot.get_node("Icon").visible = true
			slot.get_node("label").visible = true
			slot.get_node("label").text = "x" + str(inventoryMat.count(indItem))
		else:
			slot.texture = SLOTOFF
			slot.get_node("Icon").visible = false
			slot.get_node("label").visible = false
