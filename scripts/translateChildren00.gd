extends Control

var languagesCategories = {
	"eng": ["campaign", "options", "gallery", "arcade mode"], 
	"pt-br": ["campanha", "opções", "galeria", "modo arcade"], 
	"rus": ["campaign", "options", "gallery", "arcade mode"], 
}

func _adaptlang():
	$play.text = languagesCategories[CONFIG.configs["language"]][0]
	$options.text = languagesCategories[CONFIG.configs["language"]][1]
	$gallery.text = languagesCategories[CONFIG.configs["language"]][2]
	$arcade.text = languagesCategories[CONFIG.configs["language"]][3]

func _ready() -> void :
	_adaptlang()
	CONFIG.langChanged.connect(_adaptlang)
