extends ColorRect

@export var Player: Creature

func _ready() -> void :
	Player.death.connect( func():
		visible = true
	)
	Player.respawn.connect( func():
		visible = false
	)
