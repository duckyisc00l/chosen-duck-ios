extends Control

var languagesCategories = {
	"eng": ["achievements", "index", "visuals", "back"], 
	"pt-br": ["conquistas", "índice", "visuais", "voltar"], 
	"rus": ["achievements", "index", "visuals", "back"], 
}

func _adaptlang():
	$achievements.text = languagesCategories[CONFIG.configs["language"]][0]
	$index.text = languagesCategories[CONFIG.configs["language"]][1]
	$visuals.text = languagesCategories[CONFIG.configs["language"]][2]
	$back.text = languagesCategories[CONFIG.configs["language"]][3]

func _ready() -> void :
	_adaptlang()
	CONFIG.langChanged.connect(_adaptlang)
