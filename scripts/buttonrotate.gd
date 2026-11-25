extends TextureRect



func _ready() -> void :
	$TouchScreenButton.pressed.connect( func():
		$TextureRect.rotation_degrees = 180
	)
