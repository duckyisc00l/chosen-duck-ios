extends Node

var minutes: float = 0
var hours: int = 9

var time: bool = false

var inCutscene: bool = false

var loadingMode

signal changeTime
signal canLoad

const CREATURE = preload("res://branches/entities/creature.tscn")

var JSON_AREAS = FileAccess.get_file_as_string("res://info/areas.json")
@onready var readJson = JSON.parse_string(JSON_AREAS)

var currentArea: String

func _physics_process(delta: float) -> void :
	if CONFIG.modetoload == 9:
		return
	if SAVE.info["current-scene"] == "village":
		return
	if Input.is_action_just_pressed("debug_addtime"):
		_loadScenary("cave")
	minutes += delta * (3 if CONFIG.modetoload != 6 else 6)
	if minutes >= 60.0:
		minutes = 0
		hours = (hours + 1) % 24
		print(hours)
		if hours > 16 or hours < 5:
			if time == false:
				changeTime.emit()
			time = true
		else:
			if time == true:
				changeTime.emit()
			time = false

func _ready() -> void :
	changeTime.connect( func():
		for i in get_tree().get_nodes_in_group("LIGHTMANAGER"):
			if not time:
				print("Night")
				i._switchToNight(10)
			else:
				print("Day")
				i._switchToDay(10)
	)
	canLoad.connect( func():
		await get_tree().scene_changed
		_loadScenary("village" if CONFIG.modetoload == 0 else "endless")
	)

func _changeTimeInstant():
	time = not time
	hours = 18 if time else 6
	for i in get_tree().get_nodes_in_group("LIGHTMANAGER"):
		if time:
			print("Night")
			i._switchToNight(0)
		else:
			print("Day")
			i._switchToDay(0)

func _loadScenary(request: String):
	if loadingMode:
		return
	loadingMode = true
	if currentArea != "":
		var compareOld = load("res://branches/maps/" + currentArea + ".tscn")
		var instanceCO = compareOld.instantiate()
		var remain = []
		for i in instanceCO.get_children():
			if i is Prop:
				for e in get_tree().get_first_node_in_group("SCENECURRENT").get_children():
					if e.name == i.name:
						remain.append(e.name)
		print("REMAIN: " + str(remain))
		var missing = []

		for i in instanceCO.get_children():
			if i is Prop:
				if remain.find(i.name) == -1:
					missing.append(i.name)
			await get_tree().process_frame
		print("MISSING IN AREA: " + str(missing))
		SAVE.info.set("_propinfo-missing-" + currentArea, missing)
	for i in get_tree().get_nodes_in_group("SCENECURRENT"):
		if is_instance_valid(i):
			i.queue_free()
			await get_tree().process_frame
	for i in get_tree().get_nodes_in_group("SPAWNED01"):
		i.queue_free()
		await get_tree().process_frame
	var scenetoload = load("res://branches/maps/" + request + ".tscn")
	var instance: Node3D = scenetoload.instantiate()
	get_tree().get_first_node_in_group("CONTAINER3D").add_child(instance)
	instance.add_to_group("SCENECURRENT")

	if SAVE.info.get("_propinfo-missing-" + request):
		for i in SAVE.info.get("_propinfo-missing-" + request):
			instance.get_node(NodePath(i)).queue_free()

	if ( !"cave" in SAVE.info["has-been"] and request == "greenish-field") or request == "cave":
		var critter = CREATURE.instantiate()
		critter.creatureType = "bud0b"
		instance.get_parent().add_child(critter)
		critter.following = get_tree().get_first_node_in_group("PLAYERS")
		critter.global_position = get_tree().get_first_node_in_group("PLAYERS").global_position
		critter.add_to_group("SPAWNED01")
	get_tree().get_first_node_in_group("PLAYERS").blockedInv = request == "village"
	var light: String = "lightning"
	if readJson[request].has("dif-light"):
		light = readJson[request]["dif-light"]
	for i in get_tree().get_nodes_in_group("LIGHTMANAGER"):
		i.queue_free()
	var new = load("res://branches/lightning/" + light + ".tscn").instantiate()
	instance.get_parent().add_child(new)
	if time:
		new._switchToNight(0)
	else:
		new._switchToDay(0)
	for i in range(10):
		await get_tree().process_frame
	loadingMode = false
	currentArea = request
	if readJson[request]["music-enter"].size() > 0:
		loadSong(readJson[request]["music-enter"].pick_random())
	SAVE.info["current-scene"] = request
	if not request in SAVE.info["has-been"]:
		SAVE.info["has-been"].append(request)
		for i in readJson[request]["trigger-first"]:
			match i:
				"first-dialog-cut":
					print("first")
					var dialogs = [
					["hey! .. wake up...", "andrew", "cutsceneStart", "hey! .. wake up..."], 
					["WAKE UP! ..", "andrew", "", "WAKE UP! .."], 
					["did you sleep well?", "andrew", "blackVanish", "did you sleep well?"], 
					["well, we will have to migrate today.", "andrew", "", "well, we will have to migrate today."], 
					["i know the greenish plains were a good place to live at first.", "andrew", "", "i know the greenish plains were a good place to live at first."], 
					["but dangerous creatures are infesting our ambient.", "andrew", "", "but dangerous creatures are infesting our ambient."], 
					["we need to get out of here before it becomes impossible for us.", "andrew", "", "we need to get out of here before it becomes impossible for us."], 
					["we'll go in a few minutes.", "andrew", "villagesong", "we'll go in a few minutes."]]
					var languagesdialogs = {
						"pt-br" = [
							["ei! .. acorda...", "andrew", "cutsceneStart", "ei! .. acorda..."], 
							["ACORDA! ..", "andrew", "", "ACORDA! .."], 
							["dormiu bem?", "andrew", "blackVanish", "dormiu bem?"], 
							["olha, vamos ter que migrar hoje.", "andrew", "", "olha, vamos ter que migrar hoje."], 
							["sei que de primeira as planícies foram um bom lugar para se viver.", "andrew", "", "sei que de primeira as planícies foram um bom lugar para se viver."], 
							["mas criaturas perigosas estão infestando nosso ambiente.", "andrew", "", "mas criaturas perigosas estão infestando nosso ambiente."], 
							["precisamos cair fora antes que seja inviável.", "andrew", "", "precisamos cair fora antes que seja inviável."], 
							["em poucos minutos estamos indo.", "andrew", "villagesong", "em poucos minutos estamos indo."]]
					}

					for dia in ((dialogs) if CONFIG.configs["language"] == "eng" or !languagesdialogs.has(CONFIG.configs["language"]) else (languagesdialogs[CONFIG.configs["language"]])):
						get_tree().get_first_node_in_group("PLAYERS").dialogQueue.append(dia)
					get_tree().get_first_node_in_group("PLAYERS").triggerTutorial.emit()
					await get_tree().process_frame
					await get_tree().get_first_node_in_group("PLAYERS").triggerTutorial
					var dialogs2 = {
						"eng": ["i'm ready to go. are you?", "andrew", "", "i'm ready to go. are you?"], 
						"pt-br": ["estou pronto pra ir. e você?", "andrew", "", "estou pronto pra ir. e você?"], 
					}
					var final = "eng"
					if dialogs2.has(CONFIG.configs["language"]):
						final = CONFIG.configs["language"]
					get_tree().get_first_node_in_group("PLAYERS").dialogQueue.append(dialogs2[final])
					while get_tree().get_first_node_in_group("PLAYERS").dialogQueue.size() != 0:
						await get_tree().process_frame
					_loadScenary("greenish-field")
					get_tree().get_first_node_in_group("PLAYERS").global_position = Vector3(-4.6, 0.3, 18.3)

				"andrew-coming":
					var dialogs = [
					["okay! listen up now.", "andrew", "", "okay! listen up now."], 
					["there is a shortcut in the cave, we just need to go there.", "andrew", "", "there is a shortcut in the cave, we just need to go there."], 
					["no rush, just take your time. i'm coming with you.", "andrew", "", "no rush, just take your time. i'm coming with you."], ]
					var languagesdialogs = {
						"pt-br" = [
							["okay! me escuta agora.", "andrew", "cutsceneStart", "okay! me escuta agora."], 
							["tem um atalho dentro da caverna, precisamos ir lá.", "andrew", "", "tem um atalho dentro da caverna, precisamos ir lá."], 
							["sem pressa, tudo no seu tempo. estou indo contigo", "andrew", "blackVanish", "sem pressa, tudo no seu tempo. estou indo contigo"], ]
					}

					for dia in ((dialogs) if CONFIG.configs["language"] == "eng" or !languagesdialogs.has(CONFIG.configs["language"]) else (languagesdialogs[CONFIG.configs["language"]])):
						get_tree().get_first_node_in_group("PLAYERS").dialogQueue.append(dia)
					get_tree().get_first_node_in_group("PLAYERS").triggerTutorial.emit()
				"andrew-coming-proto":
					var dialogs = {
						"eng": ["yo! wait for me! i'm coming with you.", "andrew", "", "yo! wait for me! i'm coming with you."], 
						"pt-br": ["ei! pera aí! tô indo contigo.", "andrew", "", "ei! pera aí! tô indo contigo."], 
					}
					var final = "eng"
					if dialogs.has(CONFIG.configs["language"]):
						final = CONFIG.configs["language"]
					get_tree().get_first_node_in_group("PLAYERS").dialogQueue.append(dialogs[final])


func loadSong(song: String):
	var music = get_tree().get_first_node_in_group("MUSIC00")
	music.stream = load("res://assets/sound/ost/" + song)
	music.stop()
	music.volume_db = -80.0
	music.play()
	for i in range(80):
		music.volume_db = clamp(music.volume_db + 1.0, -80.0, 0)
		await get_tree().create_timer(0.1 / 4.0).timeout
