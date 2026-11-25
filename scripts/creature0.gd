extends Creature
class_name _Player


var input_dir: Vector2
var isHost = false
var isCurrent = true

@export var prefixInput: String



var dialogQueue = []

const JUMP_VELOCITY = 4.5

signal itemGet
signal itemChange
signal punchedProp
signal triggerTutorial

var lightZone: bool
var interactingNPC: CharacterBody3D
var sleeping = false
var holdingSwordLike = false
var punchSide = false
var sprintMode = false
var isSpriting = false
var finishedSprinting = false
var wasSprinting = false

var isMoving = false

var blockedProps = false

var cooldownParticles = 0.0
var cooldown = 0.0

var JSON_ITEMS = FileAccess.get_file_as_string("res://info/items.json")

@onready var readJsonITM = JSON.parse_string(JSON_ITEMS)

var lastDir = Vector3.LEFT

var cooldownAtk01 = 0.0
var cooldownDsh01 = 0.0

var accX: float
var accZ: float

var inventoryMaterial: Array = []

var timeInv = 0.0



var itemsRange = []

func _grab1Item():
	var closest: Item
	for item in itemsRange:
		if closest == null:
			closest = item
		else:
			if global_position.distance_to(item.global_position) < global_position.distance_to(closest.global_position):
				closest = item
	if closest != null:
		itemsRange.remove_at(itemsRange.find(closest))
		closest.pickUp(self)
		$SOUND / GRAB.stop()
		$SOUND / GRAB.volume_db = randf_range(-5, 0)
		$SOUND / GRAB.play()
		$COLLECTBOX.monitoring = false
		await get_tree().process_frame
		await get_tree().process_frame
		$COLLECTBOX.monitoring = true

func _simAction(act: int):
	if not get_node_or_null("duck1") or not visible:
		return
	if HP > 0:
		if act == 1:
			print("good 4 u")








		elif act == 0:
			if cooldownAtk01 <= 0.0:
				cooldownAtk01 = 0.1
				$duck1 / ANIM_IDLE.speed_scale = 2.0
				if holdingSwordLike == false:
					$duck1 / ANIM_PUNCH.play("Lpunch" if punchSide else "Rpunch")
					punchSide = not punchSide
				else:
					$duck1 / ANIM_PUNCH.play("Rswing")
				$SOUND / COMBAT_SWING.stop()
				$SOUND / COMBAT_SWING.play()
				for i in $PIVOTHITBOX / HITBOX.get_overlapping_bodies():
					if i != self:
						if i.has_method("_damage"):
							if not i is Prop or blockedProps == false:
								var toolType = "none"
								var toolName = "none"
								var dmg: int = 1
								if not i is Prop and holdingSlot == 1 and slotSword[1] != "empty":
									dmg = readJsonITM["_basic"]["tools"]["sword"][slotSword[1]]
								if holdingSlot == 2 and slotPickaxe[1] != "empty":
									toolType = "pickaxe"
									toolName = slotPickaxe[1]
								i._damage(dmg, self, toolType, toolName)
								if i is Prop:
									punchedProp.emit(i)
								$CamPivot / Camera3D / CameraShake3DNode._custom_shake(1, 0.05)
						if i.has_method("_applyKB"):
							i._applyKB(lastDir * 2)
				await $duck1 / ANIM_PUNCH.animation_finished
				$duck1 / ANIM_IDLE.speed_scale = 1.0

signal changeitem

func _disCam():
	global_position = Vector3(0, -100, 0)

func _updateTool():
	var toolName = "none"
	if holdingSlot == 1:
		toolName = slotSword[1]
	elif holdingSlot == 2:
		toolName = slotPickaxe[1]
	for i in get_node("duck1/Cube_005/Cube_007/ToolSlot").get_children():
		i.queue_free()
	if toolName != "none" and toolName != "empty":
		var loadTool = load("res://branches/3dtool/" + toolName + "/tool.tscn")
		var instance = loadTool.instantiate()
		get_node("duck1/Cube_005/Cube_007/ToolSlot").add_child(instance)

func _process(delta: float) -> void :
	if cooldown > 0.0:
		cooldown -= delta
	if cooldownAtk01 > 0.0:
		cooldownAtk01 -= delta
	if cooldownDsh01 > 0.0:
		cooldownDsh01 -= delta
	if cooldownParticles > 0.0:
		cooldownParticles -= delta
	if timeInv > 0.0:
		timeInv -= delta
	if holdingSlot == 1 or holdingSlot == 2:
		holdingSwordLike = true
	else:
		holdingSwordLike = false

func _physics_process(delta: float) -> void :

	if not get_node_or_null("duck1") or not visible:
		return
	if not is_on_floor() and not World.loadingMode:
		velocity += get_gravity() * delta

	input_dir = Input.get_vector(prefixInput + "move_left", prefixInput + "move_right", prefixInput + "move_up", prefixInput + "move_down") if CONFIG.canInput and not CONFIG.tdi2 and not CONFIG.tempDISINP and isCurrent else Vector2.ZERO


	var canLight = false

	for i in itemsRange:
		if i.itemName == "torch" and i.isStatic:
			canLight = true

	lightZone = canLight

	$CamPivot.position = lerp($CamPivot.position, global_position + Vector3(0, 3.5, 9.0), delta * 16)

	$CamPivot / Camera3D.fov = lerp($CamPivot / Camera3D.fov, 75.0 if not isSpriting or isMoving == false else 85.0, delta * 8)

	$FX / SleepingZzz.visible = sleeping
	$duck1 / Cube_005 / Cube / Cube_001.visible = not sleeping
	$duck1 / Cube_005 / Cube / Cube_002.visible = not sleeping
	if sleeping:
		$duck1 / ANIM_IDLE.speed_scale = 0.3


	var direction: = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() if dialogQueue.size() == 0 and World.inCutscene == false else Vector3.ZERO
	if $RayCast3D.is_colliding():
		$Sprite3D.global_position = $RayCast3D.get_collision_point()
		$Sprite3D.visible = true
	else:
		$Sprite3D.visible = false
	if direction and HP > 0:
		isMoving = true
		var multiplierSpeed = 1.0 if not isSpriting else 1.8
		if multiplierSpeed > 1.5:
			$duck1 / ANIM_WALK.stop()
			$duck1 / ANIM_RUN.play("run" if get_node_or_null("duck1/USESGOOSEANIM") == null else "run_gs")
		else:
			$duck1 / ANIM_RUN.stop()
			$duck1 / ANIM_WALK.play("walk" if get_node_or_null("duck1/USESGOOSEANIM") == null else "walk_gs")
		$duck1 / ANIM_IDLE.stop()
		lastDir = direction
		velocity.x = direction.x * SPEED * multiplierSpeed
		velocity.z = direction.z * SPEED * multiplierSpeed
		$duck1.rotation.y = atan2(direction.x, direction.z) + (90 - 35)
		$PIVOTHITBOX.rotation.y = atan2(direction.x, direction.z)
		wasSprinting = isSpriting


	else:
		isMoving = false
		$duck1 / ANIM_IDLE.play("idle" if get_node_or_null("duck1/USESGOOSEANIM") == null else "idle_gsss")
		if sprintMode:
			$duck1 / ANIM_IDLE.speed_scale = 1.4

		$duck1 / ANIM_WALK.stop()
		$duck1 / ANIM_RUN.stop()
		velocity.x = move_toward(velocity.x, accX, SPEED)
		velocity.z = move_toward(velocity.z, accZ, SPEED)


	isSpriting = sprintMode
	if backwardsImpulse > 0.0:
		backwardsImpulse -= delta
		knockback.y = backwardsImpulse * 20
		velocity = knockback
	move_and_slide()

const BUTTONGMPD_A_XB = preload("res://assets/iconsAtlas/a.tres")
const BUTTONGMPD_X_PS = preload("res://assets/iconsAtlas/x.tres")

func _on_collectbox_body_entered(body: Node3D) -> void :
	if body is Item:
		itemsRange.append(body)
		body.get_node("billboard").texture = BUTTONGMPD_A_XB if CONFIG.configs["layout"] == "xb" else BUTTONGMPD_X_PS
		body.get_node("billboard").visible = true

func _on_collectbox_body_exited(body: Node3D) -> void :
	if body is Item:
		itemsRange.remove_at(itemsRange.find(body))
		body.get_node("billboard").visible = false

func _respawn():
	HP = 8
	visible = true

func _on_took_damage(dmg: int, author: Creature) -> void :
	sprintMode = false
