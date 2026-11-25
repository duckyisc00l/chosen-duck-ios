extends Area3D

var already = false

func _on_body_entered(body: Node3D) -> void :
	if body is Creature and not already and !"cave" in SAVE.info["has-been"]:
		if body.isPlayer:
			already = true
			var dialogs = {
				"eng": ["shoot.. it seems like the path is blocked by rocks.", "andrew", "", "shoot.. it seems like the path is blocked by rocks."], 
				"pt-br": ["putz.. parece que o caminho está bloqueado por rochas.", "andrew", "", "putz.. parece que o caminho está bloqueado por rochas."], 
			}
			var final = "eng"
			if dialogs.has(CONFIG.configs["language"]):
				final = CONFIG.configs["language"]
			body.dialogQueue.append(dialogs[final])

func _ready() -> void :
	while get_parent().get_node_or_null("MAINHARSHROCK"):
		await get_tree().process_frame
	get_parent().get_node("WARPCAVE").disabled = false
	get_parent().get_node("WARPCAVE").disChanging.emit()
