extends CharacterBody2D

func _physics_process(delta: float) -> void :
	var direction = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	direction = direction.normalized()
	velocity = lerp(velocity, direction * 350, delta * 16)
	if abs(direction.normalized().length()) > 0:
		$App.rotation = direction.angle() + deg_to_rad(90)
	move_and_slide()

func _input(event: InputEvent) -> void :
	if Input.is_action_just_pressed("move_attack"):
		_attack()

func _attack():
	$Anims / Combat01.stop()
	$Anims / Combat01.play("Hit")
	$FX / Circle / AnimationPlayer.stop()
	$FX / Circle / AnimationPlayer.play("default")
