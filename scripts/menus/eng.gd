extends Label

@export var lang: String

func _click():
	CONFIG.configs["language"] = lang
	CONFIG._updateConfigs()
	CONFIG.langChanged.emit()
	_update()

func _update():
	text = "lang. " + lang.to_upper() + " -- " + ("on" if CONFIG.configs["language"] == lang else "off")

func _ready() -> void :
	_update()
	$Button.button_down.connect(_click)
	CONFIG.langChanged.connect(_update)
