extends Control

@export var Player: Creature

var barRun = -1.0
var barPunch = -1.0

signal ran

signal punch

var waitingRun = false
var waitingPnch = false

const BUTTONGAMEPAD_LT = preload("res://assets/iconsAtlas/lt.tres")
const BUTTONGAMEPAD_L2 = preload("res://assets/iconsAtlas/l2.tres")

const BUTTONGAMEPAD_X_XB = preload("res://assets/iconsAtlas/x_xb.tres")
const BUTTONGAMEPAD_SQUARE = preload("res://assets/iconsAtlas/quadado.tres")

func _ready() -> void :
	await Player.triggerTutorial
	Player.blockedProps = true
	while Player.isMoving == false:
		await get_tree().create_timer(0.5).timeout
	visible = true
	$RUN / TextureRect.texture = BUTTONGAMEPAD_LT if CONFIG.configs["layout"] == "xb" else BUTTONGAMEPAD_L2
	$RUN.modulate = Color.TRANSPARENT
	var tween = create_tween()
	tween.tween_property($RUN, "modulate", Color.WHITE, 1)
	$RUN.visible = true
	$RUN / AnimatedSprite2D.play("default")
	await tween.finished
	barRun = 0.0
	waitingRun = true
	await ran
	waitingRun = false
	var tween2 = create_tween()
	tween2.tween_property($RUN, "position", Vector2(-337.197, 0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween2.finished
	$RUN.visible = false
	$PUNCH.modulate = Color.TRANSPARENT
	$PUNCH / TextureRect.texture = BUTTONGAMEPAD_X_XB if CONFIG.configs["layout"] == "xb" else BUTTONGAMEPAD_SQUARE
	var tween3 = create_tween()
	tween3.tween_property($PUNCH, "modulate", Color.WHITE, 1)
	$PUNCH.visible = true
	$PUNCH / TextureRect2 / AnimationPlayer.play("wow")
	$PUNCH / AnimatedSprite2D.play("punch")
	await tween3.finished
	Player.blockedProps = false
	barPunch = 0.0
	waitingPnch = true
	await punch
	waitingPnch = false
	var tween4 = create_tween()
	tween4.tween_property($PUNCH, "position", Vector2(-337.197, 0), 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await tween4.finished
	visible = false
	await get_tree().process_frame
	Player.triggerTutorial.emit()

func _physics_process(delta: float) -> void :
	if Player.sprintMode and Player.isMoving == true:
		if barRun > -0.4:
			barRun += delta * (218.0 / 4.0)
			$RUN / Size218.size.x = clamp(barRun, 0.0, 218.0)
			if barRun > 218.0 and waitingRun:
				ran.emit()
	Player.punchedProp.connect( func(i):
		if barPunch > -0.4 and i.propName == "tree":
			barPunch = 80.0 - (i.HP * 10.0)
			$PUNCH / Size218.size.x = clamp(barPunch * (1.3) * (2.18), 0.0, 218.0)
			if barPunch >= 80.0 and waitingPnch:
				punch.emit()
	)
