extends CharacterBody3D
class_name Sign

@export var signText = {
	"pt-br": [], 
	"eng": [], 
	"rus": []
}

const BUTTONGMPD_A_XB = preload("res://assets/iconsAtlas/a.tres")
const BUTTONGMPD_X_PS = preload("res://assets/iconsAtlas/x.tres")

func _on_area_3d_body_entered(body: Node3D) -> void :
	if body is Creature:
		if body.isPlayer:
			if body.interactingNPC == null:
				body.interactingNPC = self
				$FX / Ainteract.texture = BUTTONGMPD_A_XB if CONFIG.configs["layout"] == "xb" else BUTTONGMPD_X_PS
				$FX / Ainteract.visible = true

func _on_area_3d_body_exited(body: Node3D) -> void :
	if body is Creature:
		if body.isPlayer:
			if body.interactingNPC == self:
				body.interactingNPC = null
			$FX / Ainteract.visible = false
