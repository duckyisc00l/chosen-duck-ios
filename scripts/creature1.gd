extends Creature

const JUMP_VELOCITY = 4.5

signal itemGet

var target: Creature

var following: Creature

var wanderC = 0.0
var wanderT = 0.0
var cdPunchNPC = 0.0
var NPCsoundCD = 0.0
var desperate = false
var sprintTimeNPC = 0.0
var changeDir = 0.0
var lookAtPlayerCD = 0.0

var punching = false
var punchSide = false
var sprintMode = false
var isSpriting = false
var finishedSprinting = false
var wasSprinting = false

var sleeping = false

var cooldownParticles = 0.0

var lastDir = Vector3.LEFT

var cooldownAtk01 = 0.0
var cooldownDsh01 = 0.0

var accX: float
var accZ: float

var inventoryMaterial = []



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
		closest.pickUp(self)

func _simAction(act: int):
	if HP > 0 and not sleeping:
		if act == 1:
			print("good 4 u")








		elif act == 0:
			if cooldownAtk01 <= 0.0:
				cooldownAtk01 = 0.1
				$duck1 / ANIM_IDLE.speed_scale = 2.0
				$duck1 / ANIM_PUNCH.play("Lpunch" if punchSide else "Rpunch")
				$ANIMS / jump.play("jump")
				punchSide = not punchSide
				for i in $PIVOTHITBOX / HITBOX.get_overlapping_bodies():
					if i == target:
						if i.has_method("_damage"):
							i._damage(ATTACK, self)
						if i.has_method("_applyKB"):
							i._applyKB(lastDir * 3)
				await $duck1 / ANIM_PUNCH.animation_finished
				punching = false
				$duck1 / ANIM_IDLE.speed_scale = 1.0

func _process(delta: float) -> void :
	if cooldownAtk01 > 0.0:
		cooldownAtk01 -= delta
	if cooldownDsh01 > 0.0:
		cooldownDsh01 -= delta
	if cooldownParticles > 0.0:
		cooldownParticles -= delta
	if wanderC > 0.0:
		wanderC -= delta
	if cdPunchNPC > 0.0:
		cdPunchNPC -= delta
	if NPCsoundCD > 0.0:
		NPCsoundCD -= delta
	if sprintTimeNPC > 0.0:
		sprintTimeNPC -= delta
	if changeDir > 0.0:
		changeDir -= delta
	if lookAtPlayerCD > 0.0:
		lookAtPlayerCD -= delta

var dir = Vector2.ZERO

var levitate: float = 0.0

func _physics_process(delta: float) -> void :

	if not get_node_or_null("duck1") or HP <= 0:
		return
	if not is_on_floor() and not World.loadingMode:
		velocity += (get_gravity() * delta) / (1.0 if !"glide" in behaviors else 6.0)

	if lookAtPlayerCD <= 0.0:
		lookAtPlayerCD = 4.0
		for i in $DETECTIONBOX.get_overlapping_bodies():
			if i is Creature:
				if i.isPlayer:
					$duck1.look_at(i.position)
					$duck1.rotation = Vector3(0, $duck1.rotation.y + 90, 0)

	if target != null and bh == 2:
		target = null
	if desperate == true:
		if changeDir <= 0.0:
			changeDir = 0.4
			dir = Vector2(float(sign(randi_range(-1, 1))), float(sign(randi_range(-1, 1))))
		isSpriting = true
	if sprintTimeNPC <= 0.0 and isSpriting:
		isSpriting = false
		dir = Vector2.ZERO
		desperate = false
	if target == null:
		var dist = 0.0
		if following:
			dist = following.global_position.distance_to(global_position)
		if (wanderC <= 0 and dist < 10.0) or not is_on_floor():
			if is_on_floor():
				wanderT -= delta
			if dir == Vector2.ZERO or not is_on_floor():
				wanderT = randf_range(0.4, 1.4)
				dir = Vector2(float(sign(randi_range(-1, 1))), float(sign(randi_range(-1, 1))))
			if wanderT <= 0:
				wanderC = randf_range(1, 4)
				dir = Vector2.ZERO
		elif following and dist > 5.0:
			dir = Vector2(global_position.direction_to(following.global_position).x, global_position.direction_to(following.global_position).z)
			if dist > 40.0:
				global_position = following.global_position
			elif dist > 15.0:
				sprintMode = true
			else:
				sprintMode = false
	else:
		if target.global_position.distance_to(global_position) > 0.7:
			dir = Vector2(global_position.direction_to(target.global_position).x, global_position.direction_to(target.global_position).z)
		else:
			dir = Vector2.ZERO
			if cdPunchNPC <= 0.0 and backwardsImpulse <= 0.0 and bh != 9:
				punching = true
				cdPunchNPC = 1.2
				await get_tree().create_timer(0.1).timeout
				_simAction(0)
	if not is_on_floor() and "glide" in behaviors:
		if dir == Vector2.ZERO:
			dir = Vector2(float(sign(randi_range(-1, 1))), float(sign(randi_range(-1, 1))))
	var direction: = (transform.basis * Vector3(dir.x, 0, dir.y)).normalized() if bh != 9 else Vector3.ZERO
	if $RayCast3D.is_colliding():
		$Sprite3D.global_position = $RayCast3D.get_collision_point()
		$Sprite3D.visible = true
	else:
		$Sprite3D.visible = false
	if direction and backwardsImpulse <= 0.0 and $RaycastStun.is_colliding() and punching == false and not sleeping:
		var multiplierSpeed = 1.0 if not isSpriting else 1.8
		if "bouncy" in behaviors:
			$ANIMS / bounce_slime.play("jump")
			$ANIMS / bounce_slime.speed_scale = multiplierSpeed
		else:
			if is_on_floor() or !"glide" in behaviors:
				if multiplierSpeed > 1.5:
					$duck1 / ANIM_WALK.stop()
					$duck1 / ANIM_RUN.play("run" if get_node_or_null("duck1/USESGOOSEANIM") == null else "run_gs")
				else:
					$duck1 / ANIM_RUN.stop()
					if $duck1 / ANIM_WALK.current_animation == "glide_gs":
						$duck1 / ANIM_WALK.stop()
					$duck1 / ANIM_WALK.play("walk" if get_node_or_null("duck1/USESGOOSEANIM") == null else "walk_gs")
				$duck1 / ANIM_IDLE.stop()
		lastDir = direction
		velocity.x = direction.x * SPEED * multiplierSpeed * (5.0 if not is_on_floor() and "glide" in behaviors else 1.0)
		velocity.z = direction.z * SPEED * multiplierSpeed * (5.0 if not is_on_floor() and "glide" in behaviors else 1.0)
		$duck1.rotation.y = atan2(direction.x, direction.z) + (90 - 35)
		$PIVOTHITBOX.rotation.y = atan2(direction.x, direction.z)
		wasSprinting = isSpriting


	else:
		if is_on_floor() or !"glide" in behaviors:
			$duck1 / ANIM_IDLE.play("idle" if get_node_or_null("duck1/USESGOOSEANIM") == null else "idle_gsss")
			if sprintMode:
				$duck1 / ANIM_IDLE.speed_scale = 1.4

			$duck1 / ANIM_WALK.stop()
			$duck1 / ANIM_RUN.stop()
		velocity.x = move_toward(velocity.x, accX, SPEED)
		velocity.z = move_toward(velocity.z, accZ, SPEED)


	if backwardsImpulse > 0.0:
		backwardsImpulse -= delta * (1.0 if !"sudden-flight" in behaviors else 0.3)
		knockback.y = backwardsImpulse * 20 * (1.0 if !"sudden-flight" in behaviors else 20.0)
		velocity = knockback * (1.0 if !"sudden-flight" in behaviors else 0.3)
	if NPCsoundCD <= 0.0 and $SOUND / LIVING_HIT.playing == false and randomLivingSounds.size() > 0:
		$SOUND / LIVING_DEFAULT.stream = randomLivingSounds.pick_random()
		$SOUND / LIVING_DEFAULT.stop()
		$SOUND / LIVING_DEFAULT.play()
		NPCsoundCD = (randf_range(2, 5) if target == null else randf_range(3.5, 7)) * (1.5 / (8 / HP))
	if "noctorage" in behaviors:
		bh = 0 if not World.time else 1
		if creatureType == "metallico" and loadedAPP:
			$duck1 / Cube_005 / Cube / Cube_001 / Sprite3D.visible = bh == 0
			$duck1 / Cube_005 / Cube / Cube_002 / Sprite3D.visible = bh == 0
			$duck1 / Cube_005 / Cube / Cube_001 / Sprite3D2.visible = bh == 1
			$duck1 / Cube_005 / Cube / Cube_002 / Sprite3D2.visible = bh == 1
	elif "diurnal" in behaviors:
		sleeping = World.time
		$FX / SleepingZzz.visible = sleeping
		$duck1 / Cube_005 / Cube / Cube_001.visible = not sleeping
		$duck1 / Cube_005 / Cube / Cube_002.visible = not sleeping
		$duck1 / ANIM_IDLE.speed_scale = 0.3 if sleeping else 1.0
	if not is_on_floor() and "glide" in behaviors:
		$duck1 / ANIM_IDLE.stop()
		$duck1 / ANIM_WALK.play("glide_gs")
	move_and_slide()

const BUTTONGMPD_A_XB = preload("res://assets/iconsAtlas/a.tres")
const BUTTONGMPD_X_PS = preload("res://assets/iconsAtlas/x.tres")

func _on_collectbox_body_entered(body: Node3D) -> void :
	if body is Item:
		itemsRange.append(body)
		body.get_node("billboard").visible = true
	elif body is Creature:
		if body.isPlayer and readJson[creatureType].has("dialog-interact"):
			if body.interactingNPC == null:
				body.interactingNPC = self
				$FX / Ainteract.texture = BUTTONGMPD_A_XB if CONFIG.configs["layout"] == "xb" else BUTTONGMPD_X_PS
				$FX / Ainteract.visible = true

func _on_collectbox_body_exited(body: Node3D) -> void :
	if body is Item:
		itemsRange.remove_at(itemsRange.find(body))
		body.get_node("billboard").visible = false
	elif body is Creature:
		if body.isPlayer:
			if body.interactingNPC == self:
				body.interactingNPC = null
			$FX / Ainteract.visible = false

func _on_took_damage(dmg: int, author: Creature) -> void :
	if bh != -1:
		if target == null and not sleeping:
			if bh == 2:
				desperate = true
				sprintTimeNPC = randf_range(1.4, 2.0)
			else:
				if bh != 3 or not author.isPlayer:
					target = author
	if "gooey" in behaviors:
		var cloneGush = $FX / GooGush.duplicate()
		cloneGush.global_position = global_position
		get_parent().add_child(cloneGush)
		cloneGush.emitting = true
		await cloneGush.finished
		cloneGush.queue_free()

func _on_detectionbox_body_entered(body: Node3D) -> void :
	if body is Creature and bh == 1:
		if body.isPlayer == true:
			target = body
			if "accelerate" in behaviors:
				sprintTimeNPC = 2.0
				isSpriting = true
				$SOUND / COMBAT_ACC.stop()
				$SOUND / COMBAT_ACC.play()
