extends Control

@export var Player: CharacterBody3D

func _ready() -> void :
	Player.itemGet.connect( func():
		$BP / AnimationPlayer.stop()
		$BP / AnimationPlayer.play("default")
	)
