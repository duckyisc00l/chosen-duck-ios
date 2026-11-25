extends CanvasLayer

var p1Device = -1
var p2Device = -1
var p3Device = -1
var p4Device = -1

var readies = [false, false, false, false]

var toActions = ["move_sprint", "move_action", "move_attack", "move_left", "move_right", "move_up", "move_down"]

func updatePannel():
	$Control / p1.visible = true
	$Control / p1 / use.visible = p1Device != -2
	$Control / p1 / start.text = ("start to be ready" if p1Device != -2 else "g to be ready") if readies[0] == false else "ready!"
	$Control / p1 / start.modulate = Color.WHITE if readies[0] == false else Color.GREEN_YELLOW
	$Control / p2.visible = p2Device != -1
	$Control / p2 / start.text = "start to be ready" if readies[1] == false else "ready!"
	$Control / p2 / start.modulate = Color.WHITE if readies[1] == false else Color.GREEN_YELLOW
	$Control / p3.visible = p3Device != -1
	$Control / p3 / start.text = "start to be ready" if readies[2] == false else "ready!"
	$Control / p3 / start.modulate = Color.WHITE if readies[2] == false else Color.GREEN_YELLOW
	$Control / p4.visible = p4Device != -1
	$Control / p4 / start.text = "start to be ready" if readies[3] == false else "ready!"
	$Control / p4 / start.modulate = Color.WHITE if readies[3] == false else Color.GREEN_YELLOW

func _ready() -> void :
	$ColorRect.visible = true
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", Color.TRANSPARENT, 1.0)
	$Control / AnimationPlayer.play("all")
	if Input.get_connected_joypads().size() == 0:
		p1Device = -2
	updatePannel()

func _input(event: InputEvent) -> void :
	if Input.is_action_just_pressed("space_join") and p1Device != -2:
		p1Device = -2
		readies[0] = false
		updatePannel()
	if event.is_pressed():
		if event is InputEventJoypadButton:
			if event.button_index == JOY_BUTTON_START:
				if not event.device in [p1Device, p2Device, p3Device, p4Device]:
					if p1Device == -1:
						p1Device = event.device
					elif p2Device == -1:
						p2Device = event.device
					elif p3Device == -1:
						p3Device = event.device
					elif p4Device == -1:
						p4Device = event.device
					updatePannel()
				else:
					match event.device:
						p1Device:
							readies[0] = not readies[0]
						p2Device:
							readies[1] = not readies[1]
						p3Device:
							readies[2] = not readies[2]
						p4Device:
							readies[3] = not readies[3]
					updatePannel()
		elif event is InputEventKey:
			if event.keycode == KEY_G and p1Device == -2:
				readies[0] = not readies[0]
				updatePannel()

func _startGame():
	print("start")
