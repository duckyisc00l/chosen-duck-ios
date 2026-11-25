extends Control

@export var Player: Creature

const HEART_FULL = preload("res://assets/hud/icons/heart.png")
const HEART_HALF = preload("res://assets/hud/icons/halfheart.png")

const MAX_HEARTS = 6

var canVanish = true

func _ready() -> void :
	Player.tookDamage.connect(_showHealth)

	_showHealth(0, null)

func _physics_process(delta: float) -> void :
	if canVanish:
		visible = Input.is_action_pressed("hud_health")

func _showHealth(_dmg = 0, _author = null) -> void :
	for i in range(MAX_HEARTS):
		var heart = get_node_or_null("Heart" + str(i + 1))

		if heart == null:
			push_warning("Heart" + str(i + 1) + " não foi encontrado!")
			continue

		var hp_remaining = Player.HP - (i * 2)

		if hp_remaining >= 2:
			heart.texture = HEART_FULL
			heart.modulate = Color.WHITE

		elif hp_remaining == 1:
			heart.texture = HEART_HALF
			heart.modulate = Color.WHITE

		else:
			heart.texture = HEART_FULL
			heart.modulate = Color.BLACK
	if canVanish:
		canVanish = false
		for i in range(6):
			visible = (i % 2 == 0)
			await get_tree().create_timer(0.2).timeout
		canVanish = true
	visible = false
