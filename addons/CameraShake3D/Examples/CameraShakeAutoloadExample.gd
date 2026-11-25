extends Node
class_name CameraShakeAutoLoadExample





@export var camera: Camera3D

var warn_message = "[CameraShake3D] [AutoloadExample] You must enable the plugin and uncomment lines in this script"


func _ready() -> void :
	if is_instance_valid(CameraShake3D) == false:
		printerr("CameraShake3D is not autoloaded or accessible")
		return


	print(warn_message)

func _process(delta: float) -> void :

	if Input.is_key_pressed(KEY_1):

		print(warn_message)

	elif Input.is_key_pressed(KEY_2):

		print(warn_message)

	elif Input.is_key_pressed(KEY_3):

		print(warn_message)

	elif Input.is_key_pressed(KEY_4):

		print(warn_message)
		pass
	pass
