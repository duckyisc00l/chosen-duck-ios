extends ColorRect

func _physics_process(delta: float) -> void :
	visible = World.loadingMode

func _ready() -> void :
	$TextureRect / AnimatedSprite2D.play("default")
