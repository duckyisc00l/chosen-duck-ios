extends Node3D
class_name Warp

@export var destiny: String
@export var posDes: Vector3
@export var automatic: bool
@export var tpCreatures: bool
@export var disabled: bool

signal disChanging

func tpWarpScene():
	for i in get_tree().get_nodes_in_group("PLAYERS"):
		i.global_position = posDes
	World._loadScenary(destiny)

const BUTTONGMPD_A_XB = preload("res://assets/iconsAtlas/a.tres")
const BUTTONGMPD_X_PS = preload("res://assets/iconsAtlas/x.tres")

func _on_area_3d_body_entered(body: Node3D) -> void :
	if body is Creature and not disabled:
		if body.isPlayer:
			if automatic:
				tpWarpScene()
			else:
				body.warp = self
				$Sprite3D.texture = BUTTONGMPD_A_XB if CONFIG.configs["layout"] == "xb" else BUTTONGMPD_X_PS
				visible = true

func _on_area_3d_body_exited(body: Node3D) -> void :
	if body is Creature:
		if body.isPlayer:
			if body.warp == self:
				body.warp = null
				visible = false

func _ready() -> void :
	visible = false
	disChanging.connect( func():
		$Area3D.monitoring = false
		await get_tree().process_frame
		$Area3D.monitoring = true
	)
