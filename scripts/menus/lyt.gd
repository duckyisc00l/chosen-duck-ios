extends Label

func _click():
	CONFIG.configs["layout"] = "xb" if CONFIG.configs["layout"] == "ps" else "ps"
	CONFIG._updateConfigs()
	_update()

func _update():
	text = "layout -- " + CONFIG.configs["layout"]

func _ready() -> void :
	_update()
	$Button.button_down.connect(_click)
