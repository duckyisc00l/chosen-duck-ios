extends TextureRect

@export var Player: Creature

func _physics_process(delta: float) -> void :
	if Player.lightZone:
		modulate.a = lerp(modulate.a, 0.7, delta * 2)
	else:
		modulate.a = lerp(modulate.a, 0.0, delta * 2)
