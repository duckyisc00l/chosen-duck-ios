extends CanvasLayer

var holdjoystick = false
var holder: float

var isHolding = false
var holding: float = 0.0

var doubletap: float

@export var Player: Creature

func _ready() -> void :
	if DisplayServer.is_touchscreen_available():
		visible = true
	else:
		visible = false

func _input(event: InputEvent) -> void :
	if event is InputEventKey or event is InputEventJoypadButton:
		visible = false
	elif event is InputEventScreenTouch:
		if event.double_tap:
			if Player.itemsRange.size() != 0 or Player.interactingNPC != null:
				doubletap = 0.3
		elif event.pressed:
			Input.action_press("hud_dialogmain")
		else:
			Input.action_release("hud_dialogmain")
		visible = true
		var posTouch = (event.position / (DisplayServer.window_get_size().x / 1280.0)).x
		if posTouch < 290.0:
			$Joystick.modulate = Color(1, 1, 1, 0.6)
			holder = 0.5

const ICONATK = preload("res://assets/hud/icons/attack.png")
const ICONREC = preload("res://assets/hud/icons/heart.png")

func _physics_process(delta: float) -> void :
	$Joystick.scale = Vector2.ONE * (DisplayServer.window_get_size().y / 720.0)
	$Attack / TextureRect.rotation_degrees = lerp($Attack / TextureRect.rotation_degrees, 0.0, delta * 16)
	$Run / TextureRect.rotation_degrees = lerp($Run / TextureRect.rotation_degrees, 0.0, delta * 16)
	$Inv / TextureRect.rotation_degrees = lerp($Inv / TextureRect.rotation_degrees, 0.0, delta * 16)

	if doubletap > 0.0:
		doubletap -= delta
		if Player.warp != null:
			Player.warp.tpWarpScene()
		elif Player.itemsRange.size() != 0:
			Player._grab1Item()
			doubletap = -1.0
		elif Player.interactingNPC != null and Player.dialogQueue.size() == 0:
			Player.interact()
			doubletap = -1.0
	if holder > 0.0:
		holder -= delta
	if isHolding:
		holding += delta
	if Player.dialogQueue.size() != 0:
		$Joystick.visible = false
		$Attack.visible = false
		$Run.visible = false
		$Inv.visible = false
	else:
		$Joystick.visible = not CONFIG.tempDISINP
		$Attack.visible = true
		$Attack / TextureRect.texture = ICONATK if not CONFIG.tempDISINP else ICONREC
		$Run.visible = not CONFIG.tempDISINP
		$Inv.visible = not Player.blockedInv
		$Attack / TouchScreenButton.action = "move_attack" if not CONFIG.tempDISINP else "hud_showinfo"
	if Player.input_dir == Vector2.ZERO and holder <= 0.0:
		$Joystick.modulate.a = lerp($Joystick.modulate.a, 0.3, delta * 8)
	else:
		$Joystick.modulate = Color.WHITE

	if Player.sprintMode:
		$Run / TextureRect.modulate = Color.BLACK
	else:
		$Run / TextureRect.modulate = Color.WHITE
	if Player.warp != null:
		$"ColorRect".visible = true
		$ColorRect / play.text = "double tap - enter"
	elif Player.itemsRange.size() != 0:
		$"ColorRect".visible = true
		$ColorRect / play.text = "double tap - grab"
	elif Player.interactingNPC and Player.dialogQueue.size() == 0:
		$"ColorRect".visible = true
		$ColorRect / play.text = "double tap - interact"
	else:
		$ColorRect.visible = false
