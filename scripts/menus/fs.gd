extends Label

func _click():
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_update()

var initialTextLang = {
	"eng": "full screen -- ", 
	"pt-br": "tela cheia -- ", 
	"rus": "full screen -- ", 
}

func _update():
	var mode = DisplayServer.window_get_mode()
	text = initialTextLang[CONFIG.configs["language"]] + ("on" if mode == DisplayServer.WINDOW_MODE_FULLSCREEN else "off")

func _ready() -> void :
	_update()
	$Button.button_down.connect(_click)
	CONFIG.langChanged.connect(_update)
