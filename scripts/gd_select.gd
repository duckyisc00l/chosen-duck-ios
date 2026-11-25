extends Node3D

var can = true

var positions = [
	Vector3(0.638, 2.355, 0.921), 
	Vector3(1.576, 2.355, 0.506)
]

var rotations = [
	Vector3(-15.6, 28.7, 0.0), 
	Vector3(-15.6, -8.6, 0.0)
]

@onready var SV = $AspectRatioContainer / SubViewportContainer / SubViewport

var gd = false

func loadapp():
	var l_duck = load("res://branches/3dchar/duck/char.tscn").instantiate()
	var l_goose = load("res://branches/3dchar/goose/char.tscn").instantiate()
	l_duck.position = SV.get_node("SELECTIONS/duck1").position
	l_duck.rotation = SV.get_node("SELECTIONS/duck1").rotation
	l_duck.name = "duck1"
	l_goose.position = SV.get_node("SELECTIONS/duck2").position
	l_goose.rotation = SV.get_node("SELECTIONS/duck2").rotation
	l_goose.name = "duck2"
	await get_tree().process_frame
	SV.get_node("SELECTIONS/duck1").queue_free()
	SV.get_node("SELECTIONS/duck2").queue_free()
	await get_tree().process_frame
	SV.get_node("SELECTIONS").add_child(l_duck)
	SV.get_node("SELECTIONS").add_child(l_goose)

func _ready() -> void :
	SV.get_node("MODBLACKOUT/ColorRect").visible = true
	await loadapp()
	await get_tree().process_frame
	SV.get_node("SELECTIONS/duck1").scale = Vector3(0, 0, 0)
	SV.get_node("SELECTIONS/duck2").scale = Vector3(0, 0, 0)
	SV.get_node("SELECTIONS/duck1").get_node("ANIM_IDLE").play("idle")
	SV.get_node("SELECTIONS/duck2").get_node("ANIM_IDLE").play("idle_gs")
	var tween = create_tween()
	tween.parallel().tween_property(SV.get_node("SELECTIONS/duck1"), "scale", Vector3(0.6, 0.6, 0.6), 2).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(SV.get_node("SELECTIONS/duck2"), "scale", Vector3(0.6, 0.6, 0.6), 2).set_trans(Tween.TRANS_CUBIC)
	tween.parallel().tween_property(SV.get_node("MODBLACKOUT/ColorRect"), "modulate", Color(0.0, 0.0, 0.0, 0.0), 2)
	tween.tween_callback( func():
		SV.get_node("MODBLACKOUT/ColorRect").visible = false
	)

func _input(event: InputEvent) -> void :
	if can:
		SV.get_node("MODBLACKOUT/Control/KEYBOARDCFRM").visible = Input.get_connected_joypads().size() == 0
		SV.get_node("MODBLACKOUT/Control/GAMEPADCFRM").visible = Input.get_connected_joypads().size() > 0
		if Input.is_action_just_pressed("move_shoulder_left") or Input.is_action_just_pressed("move_left_kb"):
			gd = not gd
			SV.get_node("SFX_CLICK").stop()
			SV.get_node("SFX_CLICK").play()
			SV.get_node("MODBLACKOUT/Control/label").text = "goose" if gd else "duck"
			SV.get_node("MODBLACKOUT/Control/desc").visible_characters = 0
			SV.get_node("MODBLACKOUT/Control/GAMEPADCFRM/GP_SHOULDERS/L/Control/label/AnimationPlayer").stop()
			SV.get_node("MODBLACKOUT/Control/GAMEPADCFRM/GP_SHOULDERS/L/Control/label/AnimationPlayer").play("lb")
		if Input.is_action_just_pressed("move_shoulder_right") or Input.is_action_just_pressed("move_right_kb"):
			gd = not gd
			SV.get_node("SFX_CLICK").stop()
			SV.get_node("SFX_CLICK").play()
			SV.get_node("MODBLACKOUT/Control/label").text = "goose" if gd else "duck"
			SV.get_node("MODBLACKOUT/Control/desc").visible_characters = 0
			SV.get_node("MODBLACKOUT/Control/GAMEPADCFRM/GP_SHOULDERS/R/Control/label/AnimationPlayer").stop()
			SV.get_node("MODBLACKOUT/Control/GAMEPADCFRM/GP_SHOULDERS/R/Control/label/AnimationPlayer").play("lb")
		if Input.is_action_just_pressed("move_action"):
			can = false
			SV.get_node("SFX_SELECT").stop()
			SV.get_node("SFX_SELECT").play()
			var target_index = 2 if gd else 1
			SAVE.info["chosen"] = target_index
			SV.get_node("MODBLACKOUT/ColorRect").visible = true
			var tween = create_tween()
			tween.parallel().tween_property(SV.get_node("SELECTIONS/duck1"), "scale", Vector3(0, 0, 0), 2).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(SV.get_node("SELECTIONS/duck2"), "scale", Vector3(0, 0, 0), 2).set_trans(Tween.TRANS_CUBIC)
			tween.parallel().tween_property(SV.get_node("MODBLACKOUT/ColorRect"), "modulate", Color(0.0, 0.0, 0.0, 1.0), 2)
			tween.tween_callback( func():
				get_tree().change_scene_to_file("res://scenes/load3d.tscn")
			)


func _physics_process(delta: float) -> void :
	if SV.get_node("MODBLACKOUT/Control/desc").visible_characters < str(SV.get_node("MODBLACKOUT/Control/desc").text).length():
		SV.get_node("MODBLACKOUT/Control/desc").visible_characters += 1

	var target_index = 1 if gd else 0

	SV.get_node("Camera3D").position = SV.get_node("Camera3D").position.lerp(positions[target_index], delta * 8)

	var current = SV.get_node("Camera3D").rotation
	var target = rotations[target_index]

	current.y = lerp_angle(current.y, deg_to_rad(target.y), delta * 8)

	SV.get_node("Camera3D").rotation = current
