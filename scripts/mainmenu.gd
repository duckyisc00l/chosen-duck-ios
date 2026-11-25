extends Control

@onready var selectedOPT = $Control / play

@onready var order = [$Control / play, $Control / options, $Control / gallery, $Control / arcade]

@onready var bc = get_parent().get_node("BLACKOUTCREDITS")

@onready var b2 = get_parent().get_node("B2")

func _press(nm: String):
	bc.get_node("CLICK").stop()
	bc.get_node("CLICK").play()
	match nm:
		"play":
			canInput = false
			CONFIG.modetoload = 0
			var tween = create_tween()
			tween.tween_property($LOGO, "position", Vector2(0, 64.0), 1.5).set_trans(Tween.TRANS_CUBIC)
			for i in get_children():
				if i != $LOGO:
					var tweenI = create_tween()
					tweenI.tween_property(i, "modulate", Color.TRANSPARENT, 1)
			b2.modulate = Color.TRANSPARENT
			b2.visible = true
			var tween2 = create_tween()
			tween2.tween_property(b2, "modulate", Color.WHITE, 1.0)
			tween2.tween_callback( func():
				var tween3 = create_tween()
				tween3.tween_property($LOGO, "modulate", Color.TRANSPARENT, 1.0)
				tween3.tween_callback( func(): get_tree().change_scene_to_file("res://scenes/load3d.tscn"))
			)
			for i in range(0, 40):
				bc.get_node("MUSIC").volume_db -= 2
				await get_tree().create_timer(0.05).timeout
			print("locked")
		"options":
			await get_tree().process_frame
			$OPTIONS.visible = true
		"arcade":
			print("locked")
			canInput = false
			CONFIG.modetoload = 6
			var tween = create_tween()
			tween.tween_property($LOGO, "position", Vector2(0, 64.0), 1.5).set_trans(Tween.TRANS_CUBIC)
			for i in get_children():
				if i != $LOGO:
					var tweenI = create_tween()
					tweenI.tween_property(i, "modulate", Color.TRANSPARENT, 1)
			b2.modulate = Color.TRANSPARENT
			b2.visible = true
			var tween2 = create_tween()
			tween2.tween_property(b2, "modulate", Color.WHITE, 1.0)
			tween2.tween_callback( func():
				var tween3 = create_tween()
				tween3.tween_property($LOGO, "modulate", Color.TRANSPARENT, 1.0)
				tween3.tween_callback( func(): get_tree().change_scene_to_file("res://scenes/load3d.tscn"))
			)
			for i in range(0, 40):
				bc.get_node("MUSIC").volume_db -= 2
				await get_tree().create_timer(0.05).timeout

var canInput = false

func _process(delta: float) -> void :
	if canInput and not $OPTIONS.visible:
		if Input.is_action_just_pressed("move_up"):
			selectedOPT = order[(order.find(selectedOPT) - 1 if order.find(selectedOPT) > 0 else (order.size() - 1))]
			bc.get_node("HOVER").stop()
			bc.get_node("HOVER").play()
		elif Input.is_action_just_pressed("move_down"):
			selectedOPT = order[(order.find(selectedOPT) + 1 if order.find(selectedOPT) < (order.size() - 1) else 0)]
			bc.get_node("HOVER").stop()
			bc.get_node("HOVER").play()
		if !DisplayServer.is_touchscreen_available():
			for i in order:
				if i != selectedOPT:
					i.modulate = Color.WHITE
				else:
					if i.name == "issisi":
						i.modulate = Color.INDIAN_RED
					else:
						i.modulate = Color.YELLOW
		if Input.is_action_just_pressed("move_action"):
			_press(selectedOPT.name)


func _ready() -> void :
	$LOGO / AnimationPlayer.play("logobump")
	for i in order:
		if DisplayServer.is_touchscreen_available():
			$ColorRect.visible = false
		else:
			if i != selectedOPT:
				i.modulate = Color.WHITE
			else:
				i.modulate = Color.YELLOW
		i.get_node("Button").mouse_entered.connect( func():
			if canInput and not $OPTIONS.visible:
				selectedOPT = i
				bc.get_node("HOVER").stop()
				bc.get_node("HOVER").play()
		)
		i.get_node("Button").button_down.connect( func():
			i.self_modulate = Color.DIM_GRAY
		)
		i.get_node("Button").button_up.connect( func():
			i.self_modulate = Color.WHITE
			if canInput and not $OPTIONS.visible:
				_press(i.name)
		)
	bc.visible = true
	await get_tree().create_timer(1).timeout
	var tween = create_tween()
	tween.tween_property(bc.get_node("Label"), "modulate", Color.TRANSPARENT, 2)
	tween.tween_callback( func():
		canInput = true
		var tween2 = create_tween()
		tween2.tween_property(bc, "modulate", Color.TRANSPARENT, 2)
		tween2.tween_callback( func(): bc.visible = false)
	)

func _physics_process(delta: float) -> void :
	$ColorRect.global_position.y = lerp($ColorRect.global_position.y, selectedOPT.global_position.y, delta * 32)
