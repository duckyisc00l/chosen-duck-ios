extends Control

@export var Player: Creature

@export var storyPannel: Control

var timerletter: = 0.0
var lettersRemaining: = 0
var loadingDialog: = false

const BUTTONGMPD_A_XB = preload("res://assets/iconsAtlas/a.tres")
const BUTTONGMPD_X_PS = preload("res://assets/iconsAtlas/x.tres")

func _physics_process(delta: float) -> void :
	visible = Player.dialogQueue.size() > 0

	if !visible:
		loadingDialog = false
		return

	if !loadingDialog:
		_load_dialog()

	if timerletter > 0.0:
		timerletter -= delta * (3.0 if Input.is_action_pressed("move_action") else 1.0)
	elif lettersRemaining > 0:
		lettersRemaining -= 1
		$box / Label.visible_characters += 1

		var current_index = $box / Label.visible_characters - 1
		var char = $box / Label.text[current_index]

		$DialogTextMachine.stop()
		$DialogTextMachine.play()

		match char:
			".", "!", "?", ";", ":":
				timerletter = 0.25
			",":
				timerletter = 0.15
			_:
				timerletter = 0.03

	$box / A.visible = !lettersRemaining > 0

	if $box / A.visible:
		$box / A.texture = BUTTONGMPD_A_XB if CONFIG.configs["layout"] == "xb" else BUTTONGMPD_X_PS

	if Input.is_action_just_pressed("hud_dialogmain"):
		if lettersRemaining > 0:
			$box / Label.visible_characters = $box / Label.text.length()
			lettersRemaining = 0
		else:
			_next_dialog()

func _load_dialog() -> void :
	loadingDialog = true
	var dialog = Player.dialogQueue[0]

	var filteredMessage: String = dialog[0]

	$box / Name.text = dialog[1]
	$box / Label.text = dialog[3]

	$box / Label.visible_characters = 0
	lettersRemaining = dialog[0].length()

	match dialog[2]:




		"endcutsc":
			while Player.dialogQueue.size() > 0:
				await get_tree().process_frame
			await get_tree().create_timer(1.0).timeout
			World._loadScenary("village")
			Player.global_position = Vector3(0, 0.625, 0)












		"cutsceneStart":
			storyPannel.get_node("Black").visible = true
		"blackVanish":
			storyPannel.get_node("Black").visible = true
			storyPannel.get_node("Black").modulate = Color.WHITE
			var tween = create_tween()
			tween.tween_property(storyPannel, "modulate", Color.TRANSPARENT, 1.5)
			tween.tween_callback( func(): storyPannel.get_node("Black").visible = false)
		"jumpandrew0":
			Player.sleeping = false
			Player.get_node("SOUND/LIVING_HIT").stop()
			Player.get_node("SOUND/LIVING_HIT").play()
			Player.get_node("ANIMS/jump").stop()
			Player.get_node("ANIMS/jump").play("jump")
			get_tree().get_first_node_in_group("npc_bud0").get_node("ANIMS/jump").stop()
			get_tree().get_first_node_in_group("npc_bud0").get_node("ANIMS/jump").play("jump")
		"villagesong":
			World.loadSong("villageogg.ogg")

func _next_dialog() -> void :
	Player.dialogQueue.remove_at(0)

	loadingDialog = false

	if Player.dialogQueue.size() == 0:
		visible = false
