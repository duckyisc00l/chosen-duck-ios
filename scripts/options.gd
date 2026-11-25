extends ColorRect

@onready var order = [$opt_video, $opt_audio, $opt_gamepad, $opt_keyboard, $opt_lang]

@onready var selected = $opt_video

@export var openable = false

var languagesCategories = {
	"eng": ["video", "audio", "gamepd", "keybrd", "lang"], 
	"pt-br": ["vídeo", "áudio", "contrl", "tecldo", "ling"], 
	"rus": ["video", "audio", "gamepd", "keybrd", "lang"], 
}

var leaveIndLang = {
	"eng": "hit    to leave", 
	"pt-br": "apt    para sair", 
	"rus": "hit    to leave", 
}

func _input(event: InputEvent) -> void :
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		$GAMEPADCFRM.visible = true
		$leave.visible = false
	elif event is InputEventMouseMotion:
		$GAMEPADCFRM.visible = false
		$leave.visible = true

func _adaptLangCategories():
	$opt_video / play.text = languagesCategories[CONFIG.configs["language"]][0]
	$opt_audio / play.text = languagesCategories[CONFIG.configs["language"]][1]
	$opt_gamepad / play.text = languagesCategories[CONFIG.configs["language"]][2]
	$opt_keyboard / play.text = languagesCategories[CONFIG.configs["language"]][3]
	$opt_lang / play.text = languagesCategories[CONFIG.configs["language"]][4]
	$GAMEPADCFRM / label.text = leaveIndLang[CONFIG.configs["language"]]
	$leave / play.text = {"eng": "leave", "pt-br": "sair", "rus": "leave"}[CONFIG.configs["language"]]

func _ready():
	selected.modulate = Color.YELLOW
	position = Vector2(185, 75)
	_adaptLangCategories()
	CONFIG.langChanged.connect(_adaptLangCategories)
	$leave / Button.button_down.connect( func():
		visible = false
	)
	for i in order:
		i.get_node("Button").button_down.connect( func():
			selected = i
			var selectedMENU = $MENUS.get_node(NodePath(selected.name))
			for e in order:
				e.modulate = Color.WHITE
			for e in $MENUS.get_children():
				e.visible = false
			selectedMENU.visible = true
			selected.modulate = Color.YELLOW
		)

func _process(delta: float) -> void :
	CONFIG.canInput = not visible
	if not visible and openable:
		if Input.is_action_just_pressed("ui_options"):
			visible = true
	else:
		if Input.is_action_just_pressed("move_quit"):
			visible = false
	if visible and $GAMEPADCFRM.visible:
		var selectedMENU = $MENUS.get_node(NodePath(selected.name))
		if Input.is_action_just_pressed("move_down"):
			if selectedMENU.has_method("_backSelect"):
				selectedMENU._backSelect()
		if Input.is_action_just_pressed("move_up"):
			if selectedMENU.has_method("_forwardSelect"):
				selectedMENU._forwardSelect()
		if Input.is_action_just_pressed("move_action"):
			if selectedMENU.selected.has_method("_click"):
				selectedMENU.selected._click()

		if Input.is_action_just_pressed("move_shoulder_left"):
			selected = order[(order.find(selected) - 1) if order.find(selected) > 0 else order.size() - 1]
			selectedMENU = $MENUS.get_node(NodePath(selected.name))
			for i in order:
				i.modulate = Color.WHITE
			for i in $MENUS.get_children():
				i.visible = false
			selectedMENU.visible = true
			selected.modulate = Color.YELLOW
		elif Input.is_action_just_pressed("move_shoulder_right"):
			selected = order[(order.find(selected) + 1) if order.find(selected) < order.size() - 1 else 0]
			selectedMENU = $MENUS.get_node(NodePath(selected.name))
			for i in order:
				i.modulate = Color.WHITE
			for i in $MENUS.get_children():
				i.visible = false
			selectedMENU.visible = true
			selected.modulate = Color.YELLOW
