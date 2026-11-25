extends Node

var crtFILTER: ColorRect

var tempDISINP = false

var tdi2 = false

var mobileMode = true

var modetoload = 0

var configs = {
	"crt-filter": true, 
	"language": "eng", 
	"layout": "xb", 
}

var deviceP1: int

var canInput = true

signal langChanged

func _updateConfigs():
	var nodes = get_tree().get_nodes_in_group("crt_filter")
	if nodes.size() > 0:
		crtFILTER = nodes[0]
		crtFILTER.visible = configs["crt-filter"]

func _update():
	_updateConfigs()

func _ready() -> void :
	get_tree().scene_changed.connect(_update)
