extends Label

func _click():
	CONFIG.configs["crt-filter"] = not CONFIG.configs["crt-filter"]
	CONFIG._updateConfigs()
	_update()

var initialTextLang = {
	"eng": "CRT filter -- ", 
	"pt-br": "filtro CRT -- ", 
	"rus": "CRT filter -- ", 
}

func _update():
	text = initialTextLang[CONFIG.configs["language"]] + ("on" if CONFIG.configs["crt-filter"] else "off")

func _ready() -> void :
	_update()
	$Button.button_down.connect(_click)
	CONFIG.langChanged.connect(_update)
