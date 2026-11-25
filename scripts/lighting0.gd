extends Node3D

@export var dayColor: Color
@export var nightColor: Color

@export var isDark: bool

var Player: Creature

var timeself = false

func _switchToNight(transition: float = 0):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($WorldEnvironment.environment, "background_color", nightColor, transition)
	tween.tween_property($DirectionalLight3D, "light_color", Color.WEB_PURPLE, transition)
	tween.tween_property($DirectionalLight3D, "light_energy", 0.7, transition)
	tween.tween_callback( func(): timeself = true)

func _switchToDay(transition: float = 0):
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property($WorldEnvironment.environment, "background_color", dayColor, transition)
	tween.tween_property($DirectionalLight3D, "light_color", Color.WHITE, transition)
	tween.tween_property($DirectionalLight3D, "light_energy", 2.0, transition)
	tween.tween_callback( func(): timeself = false)

func _ready() -> void :
	Player = get_tree().get_first_node_in_group("PLAYERS")
	add_to_group("LIGHTMANAGER")

func _physics_process(delta: float) -> void :
	if isDark:
		var environmento = $WorldEnvironment.environment as Environment
		environmento.tonemap_exposure = lerp(environmento.tonemap_exposure, 0.3 if not Player.lightZone else 1.0, delta * 4)
