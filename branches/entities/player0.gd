extends _Player

@export var client: bool

var blockedInv: bool

func interact():
	if interactingNPC is Sign:
		var signLang = interactingNPC.signText[CONFIG.configs["language"]]
		for i in signLang:
			dialogQueue.append(i)
	else:
		for i in readJson[interactingNPC.creatureType]["dialog-interact"]:
			dialogQueue.append(i)

func _input(event: InputEvent) -> void :
	if client:
		if CONFIG.canInput and not CONFIG.tempDISINP and isCurrent and not CONFIG.tdi2 and dialogQueue.size() == 0 and World.inCutscene == false:
			if Input.is_action_just_pressed(prefixInput + "move_attack"):
				_simAction(0)
			if Input.is_action_just_pressed(prefixInput + "move_shoulder_left"):
				holdingSlot = clamp(holdingSlot - 1, 0, 5)
				timeInv = 1.0
				changeitem.emit()
				_updateTool()
			if Input.is_action_just_pressed(prefixInput + "move_shoulder_right"):
				holdingSlot = (holdingSlot + 1) if holdingSlot != 5 else 0
				timeInv = 1.0
				changeitem.emit()
				_updateTool()
			if Input.is_action_just_pressed(prefixInput + "move_action"):
				if HP > 0:
					if interactingNPC and dialogQueue.size() == 0:
						interact()
					elif warp:
						warp.tpWarpScene()
					else:
						_grab1Item()
				else:
					_respawn()
					respawn.emit()
			if Input.is_action_just_pressed(prefixInput + "move_sprint"):
				sprintMode = true
				while not Input.is_action_just_released(prefixInput + "move_sprint"):
					await get_tree().process_frame
				sprintMode = false
			if Input.is_action_just_pressed("move_sprint_hold"):
				sprintMode = not sprintMode
			if Input.is_action_just_pressed("slotbind_1") and cooldown <= 0.0:
				cooldown = 0.3
				holdingSlot = 1 if holdingSlot != 1 else 0
				if slotSword[1] == "empty":
					holdingSlot = 0
				timeInv = 1.0
				changeitem.emit()
				_updateTool()
			if Input.is_action_just_pressed("slotbind_2") and cooldown <= 0.0:
				cooldown = 0.3
				print("skw")
				holdingSlot = 2 if holdingSlot != 2 else 0
				if slotPickaxe[1] == "empty":
					holdingSlot = 0
				timeInv = 1.0
				changeitem.emit()
				_updateTool()
				print("don" + str(holdingSlot))
