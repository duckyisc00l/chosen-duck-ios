files: 962; scripts: 57; scenes: 75
C# scripts: 0; GDExtensions: 0
## project.godot
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="THE CHOSEN DUCK"
config/tags=PackedStringArray("TCD")
run/main_scene="uid://cfi1dbt0ygjsh"
config/features=PackedStringArray("4.7", "Mobile")
config/icon="uid://d4m7j8bwojh2y"

[audio]

buses/default_bus_layout="uid://dad3xc86wqtj4"

[autoload]

CONFIG="*uid://cetfgnq5kjgan"
_CameraShake3D="*uid://c82fdx2gisgam"
Mulltiplayer="*uid://b152elsi7bsvp"
World="*uid://bid5x0flrdhyg"
SAVE="*uid://dr2es8h0aygaa"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/size/mode=2

[editor]

movie_writer/movie_file="/home/gabrielalex/tcdvid.avi"
movie_writer/fps=30

[editor_overrides]

text_editor/behavior/indent/type=0
text_editor/behavior/indent/size=4

[editor_plugins]

enabled=PackedStringArray("res://addons/CameraShake3D/plugin.cfg")

[file_customization]

folder_colors={
"res://assets/": "red",
"res://branches/": "yellow",
"res://info/": "blue",
"res://scenes/": "green",
"res://scripts/": "purple"
}

[input]

move_left={
"deadzone": 0.1,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":13,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":-1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
]
}
move_up={
"deadzone": 0.1,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":11,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":-1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":87,"key_label":0,"unicode":119,"location":0,"echo":false,"script":null)
]
}
move_down={
"deadzone": 0.1,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":12,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":1,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":83,"key_label":0,"unicode":115,"location":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.1,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":14,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":0,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
]
}
move_attack={
"deadzone": 0.2,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":1,"position":Vector2(498.73108, 27.895966),"global_position":Vector2(509.73108, 83.895966),"factor":1.0,"button_index":1,"canceled":false,"pressed":true,"double_click":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":2,"pressure":0.0,"pressed":true,"script":null)
]
}
move_dash={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":5,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":81,"key_label":0,"unicode":113,"location":0,"echo":false,"script":null)
]
}
move_shoulder_left={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":9,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":73,"key_label":0,"unicode":105,"location":0,"echo":false,"script":null)
]
}
move_shoulder_right={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":10,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":79,"key_label":0,"unicode":111,"location":0,"echo":false,"script":null)
]
}
move_action={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":0,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":32,"location":0,"echo":false,"script":null)
]
}
move_left_kb={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":65,"key_label":0,"unicode":97,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194319,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_right_kb={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":68,"key_label":0,"unicode":100,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194321,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_sprint={
"deadzone": 0.2,
"events": [Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":5,"axis_value":1.0,"script":null)
, Object(InputEventJoypadMotion,"resource_local_to_scene":false,"resource_name":"","device":-1,"axis":4,"axis_value":1.0,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194326,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
ui_options={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":6,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
ui_quit_menu={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":1,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
move_open_inv={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":69,"key_label":0,"unicode":101,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":3,"pressure":0.0,"pressed":true,"script":null)
]
}
move_quit={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":1,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194305,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":66,"key_label":0,"unicode":98,"location":0,"echo":false,"script":null)
]
}
debug_addtime={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194337,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":46,"key_label":0,"unicode":46,"location":0,"echo":false,"script":null)
]
}
move_sandbox={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":4,"pressure":0.0,"pressed":true,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":48,"key_label":0,"unicode":48,"location":0,"echo":false,"script":null)
]
}
space_join={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":32,"location":0,"echo":false,"script":null)
]
}
m={
"deadzone": 0.2,
"events": []
}
startlazy={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":6,"pressure":0.0,"pressed":false,"script":null)
]
}
slotbind_1={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":49,"key_label":0,"unicode":49,"location":0,"echo":false,"script":null)
]
}
hud_showinfo={
"deadzone": 0.2,
"events": [Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":2,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":2,"position":Vector2(249, 23),"global_position":Vector2(261, 83),"factor":1.0,"button_index":2,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
move_next_mouse={
"deadzone": 0.2,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":8,"position":Vector2(261.21387, 33.958984),"global_position":Vector2(275.21387, 106.958984),"factor":1.0,"button_index":4,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
move_prev_mouse={
"deadzone": 0.2,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":16,"position":Vector2(325.667, 34.976563),"global_position":Vector2(339.667, 107.97656),"factor":1.0,"button_index":5,"canceled":false,"pressed":true,"double_click":false,"script":null)
]
}
hud_health={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194306,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":4,"pressure":0.0,"pressed":false,"script":null)
]
}
hud_dialogmain={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":32,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
, Object(InputEventJoypadButton,"resource_local_to_scene":false,"resource_name":"","device":-1,"button_index":0,"pressure":0.0,"pressed":false,"script":null)
, Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":16,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":4194309,"key_label":0,"unicode":0,"location":0,"echo":false,"script":null)
]
}
slotbind_2={
"deadzone": 0.2,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":50,"key_label":0,"unicode":50,"location":0,"echo":false,"script":null)
]
}
move_sprint_hold={
"deadzone": 0.2,
"events": []
}
move_invshow={
"deadzone": 0.2,
"events": []
}

[input_devices]

pointing/emulate_mouse_from_touch=false

[physics]

3d/physics_engine="Jolt Physics"

[rendering]

rendering_device/driver.windows="d3d12"
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
textures/vram_compression/import_s3tc_bptc=true
textures/vram_compression/import_etc2_astc=true
shading/overrides/force_vertex_shading=true

[shader_globals]

psx_affine_strength={
"type": "float",
"value": 1.0
}
psx_bit_depth={
"type": "int",
"value": 5
}
psx_fog_color={
"type": "color",
"value": Color(0.5, 0.5, 0.5, 0)
}
psx_fog_far={
"type": "float",
"value": 20.0
}
psx_fog_near={
"type": "float",
"value": 10.0
}
psx_snap_distance={
"type": "float",
"value": 0.025
}
psx_precision_uv={
"type": "float",
"value": 128.0
}
psx_precision_xy={
"type": "float",
"value": 256.0
}
psx_precision_z={
"type": "float",
"value": 512.0
}
## touch handling in scripts
proj/branches/hud/mobile.tscn:44:[node name="TouchScreenButton" type="TouchScreenButton" parent="Attack" unique_id=517066465]
proj/branches/hud/mobile.tscn:81:[node name="TouchScreenButton" type="TouchScreenButton" parent="Run" unique_id=2146500542]
proj/branches/hud/mobile.tscn:118:[node name="TouchScreenButton" type="TouchScreenButton" parent="Inv" unique_id=445585681]
proj/branches/hud/mobile.tscn:218:[node name="TouchScreenButton" type="TouchScreenButton" parent="ColorRect2" unique_id=1263934398]
proj/scenes/3d.tscn:1877:[node name="TouchScreenButton" type="TouchScreenButton" parent="AspectRatioContainer/SubViewportContainer/SubViewport/CanvasLayer/INVENTORY/CONTAINER/Slot1" unique_id=745594398]
proj/scenes/3d.tscn:1929:[node name="TouchScreenButton" type="TouchScreenButton" parent="AspectRatioContainer/SubViewportContainer/SubViewport/CanvasLayer/INVENTORY/CONTAINER/Slot2" unique_id=1962798031]
proj/systems/joystick/joystick.gd:80:	if not DisplayServer.is_touchscreen_available() and visibility_mode == Visibility_mode.TOUCHSCREEN_ONLY:
proj/systems/joystick/joystick.gd:87:	if event is InputEventScreenTouch:
proj/systems/joystick/joystick.gd:104:	elif event is InputEventScreenDrag:
proj/entities/characters/base_controller/camera_controller.gd:14:	if event is InputEventScreenDrag:
proj/scripts/modulategamepad.gd:4:	if event is InputEventMouseMotion or event is InputEventScreenTouch:
proj/scripts/buttonrotate.gd:6:	$TouchScreenButton.pressed.connect( func():
proj/scripts/mainmenu.gd:75:		if !DisplayServer.is_touchscreen_available():
proj/scripts/mainmenu.gd:91:		if DisplayServer.is_touchscreen_available():
proj/scripts/mobile.gd:14:	if DisplayServer.is_touchscreen_available():
proj/scripts/mobile.gd:22:	elif event is InputEventScreenTouch:
proj/scripts/mobile.gd:70:		$Attack / TouchScreenButton.action = "move_attack" if not CONFIG.tempDISINP else "hud_showinfo"
## keyboard/mouse reads in scripts
      1 proj/systems/joystick/joystick.gd: Input.is_action_pressed(action_up)
      1 proj/systems/joystick/joystick.gd: Input.is_action_pressed(action_right)
      1 proj/systems/joystick/joystick.gd: Input.is_action_pressed(action_left)
      1 proj/systems/joystick/joystick.gd: Input.is_action_pressed(action_down)
      1 proj/systems/joystick/joystick.gd: Input.is_action_pressed(action)
      1 proj/systems/joystick/example/player2d.gd: Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
      1 proj/scripts/sandbox.gd: Input.is_action_just_pressed("move_up")
      1 proj/scripts/sandbox.gd: Input.is_action_just_pressed("move_sandbox")
      1 proj/scripts/sandbox.gd: Input.is_action_just_pressed("move_open_inv")
      1 proj/scripts/sandbox.gd: Input.is_action_just_pressed("move_down")
      1 proj/scripts/sandbox.gd: Input.is_action_just_pressed("move_action")
      1 proj/scripts/options.gd: InputEventMouseMotion
      1 proj/scripts/options.gd: Input.is_action_just_pressed("ui_options")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_up")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_shoulder_right")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_shoulder_left")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_quit")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_down")
      1 proj/scripts/options.gd: Input.is_action_just_pressed("move_action")
      1 proj/scripts/opt.gd: InputEventMouseMotion
      1 proj/scripts/modulategamepad.gd: InputEventMouseMotion
      1 proj/scripts/mobile.gd: InputEventKey
      1 proj/scripts/manageSelecArcarde.gd: KEY_G
      1 proj/scripts/manageSelecArcarde.gd: InputEventKey
      1 proj/scripts/manageSelecArcarde.gd: Input.is_action_just_pressed("space_join")
      1 proj/scripts/mainmenu.gd: Input.is_action_just_pressed("move_up")
      1 proj/scripts/mainmenu.gd: Input.is_action_just_pressed("move_down")
      1 proj/scripts/mainmenu.gd: Input.is_action_just_pressed("move_action")
      1 proj/scripts/inventoryslotshud.gd: Input.is_action_pressed("move_invshow")
      1 proj/scripts/inventoryMenu.gd: InputEventMouseButton
      1 proj/scripts/inventoryMenu.gd: InputEventKey
      1 proj/scripts/inventoryMenu.gd: Input.is_action_pressed("hud_showinfo")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_shoulder_right")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_shoulder_left")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_sandbox")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_right")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_quit")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_prev_mouse")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_open_inv")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_next_mouse")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_left")
      1 proj/scripts/inventoryMenu.gd: Input.is_action_just_pressed("move_action")
      1 proj/scripts/hearts.gd: Input.is_action_pressed("hud_health")
      1 proj/scripts/gd_select.gd: Input.is_action_just_pressed("move_shoulder_right")
      1 proj/scripts/gd_select.gd: Input.is_action_just_pressed("move_shoulder_left")
      1 proj/scripts/gd_select.gd: Input.is_action_just_pressed("move_right_kb")
      1 proj/scripts/gd_select.gd: Input.is_action_just_pressed("move_left_kb")
      1 proj/scripts/gd_select.gd: Input.is_action_just_pressed("move_action")
      1 proj/scripts/dialog.gd: Input.is_action_pressed("move_action")
      1 proj/scripts/dialog.gd: Input.is_action_just_pressed("hud_dialogmain")
      1 proj/scripts/creature0.gd: Input.get_vector(prefixInput + "move_left", prefixInput + "move_right", prefixInput + "move_up", prefixInput + "move_down")
      1 proj/scripts/creature.gd: Input.is_action_just_pressed("move_attack")
      1 proj/scripts/creature.gd: Input.get_axis("move_up", "move_down")
      1 proj/scripts/creature.gd: Input.get_axis("move_left", "move_right")
      1 proj/scripts/closebtest.gd: Input.is_action_just_pressed("move_quit")
      1 proj/scripts/WorldManager.gd: Input.is_action_just_pressed("debug_addtime")
      1 proj/scenes/disclaimer.gd: Input.is_action_just_pressed("startlazy")
      1 proj/entities/characters/base_controller/base_controller.gd: Input.is_action_just_pressed("ui_accept")
      1 proj/entities/characters/base_controller/base_controller.gd: Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
      1 proj/branches/entities/player0.gd: Input.is_action_just_released(prefixInput + "move_sprint")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed(prefixInput + "move_sprint")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed(prefixInput + "move_shoulder_right")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed(prefixInput + "move_shoulder_left")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed(prefixInput + "move_attack")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed(prefixInput + "move_action")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed("slotbind_2")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed("slotbind_1")
      1 proj/branches/entities/player0.gd: Input.is_action_just_pressed("move_sprint_hold")
      1 proj/addons/CameraShake3D/Examples/CameraShakeNodeExample.gd: Input.is_key_pressed(KEY_4)
      1 proj/addons/CameraShake3D/Examples/CameraShakeNodeExample.gd: Input.is_key_pressed(KEY_3)
      1 proj/addons/CameraShake3D/Examples/CameraShakeNodeExample.gd: Input.is_key_pressed(KEY_2)
      1 proj/addons/CameraShake3D/Examples/CameraShakeNodeExample.gd: Input.is_key_pressed(KEY_1)
      1 proj/addons/CameraShake3D/Examples/CameraShakeConstructExample.gd: Input.is_key_pressed(KEY_4)
      1 proj/addons/CameraShake3D/Examples/CameraShakeConstructExample.gd: Input.is_key_pressed(KEY_3)
      1 proj/addons/CameraShake3D/Examples/CameraShakeConstructExample.gd: Input.is_key_pressed(KEY_2)
      1 proj/addons/CameraShake3D/Examples/CameraShakeConstructExample.gd: Input.is_key_pressed(KEY_1)
      1 proj/addons/CameraShake3D/Examples/CameraShakeAutoloadExample.gd: Input.is_key_pressed(KEY_4)
      1 proj/addons/CameraShake3D/Examples/CameraShakeAutoloadExample.gd: Input.is_key_pressed(KEY_3)
      1 proj/addons/CameraShake3D/Examples/CameraShakeAutoloadExample.gd: Input.is_key_pressed(KEY_2)
      1 proj/addons/CameraShake3D/Examples/CameraShakeAutoloadExample.gd: Input.is_key_pressed(KEY_1)
## textures with no source image
## GDRE failures
Verified 598 files, no errors detected!
Extracted 598 files, no errors detected!
Failed conversions:                     0
## scripts
addons/CameraShake3D/CameraShake3D/CameraShake3D.gd
addons/CameraShake3D/CameraShake3D/CameraShake3DNode.gd
addons/CameraShake3D/Examples/CameraShakeAutoloadExample.gd
addons/CameraShake3D/Examples/CameraShakeConstructExample.gd
addons/CameraShake3D/Examples/CameraShakeNodeExample.gd
addons/CameraShake3D/Plugin.gd
autoload/Save.gd
autoload/config.gd
branches/entities/player0.gd
entities/characters/base_controller/base_controller.gd
entities/characters/base_controller/camera_controller.gd
render.gd
scenes/disclaimer.gd
scripts/Mulltiplayer.gd
scripts/WorldManager.gd
scripts/adaptiveUI.gd
scripts/addtogroup.gd
scripts/area_3d_2first.gd
scripts/buttonrotate.gd
scripts/classCreature.gd
scripts/closebtest.gd
scripts/control_2translate.gd
scripts/creature.gd
scripts/creature0.gd
scripts/creature1.gd
scripts/dialog.gd
scripts/gd_select.gd
scripts/hearts.gd
scripts/hud_deathscreen.gd
scripts/indicators.gd
scripts/inventoryMenu.gd
scripts/inventoryslotshud.gd
scripts/item0.gd
scripts/lighting0.gd
scripts/lite.gd
scripts/load.gd
scripts/loading00.gd
scripts/mainmenu.gd
scripts/manageSelecArcarde.gd
scripts/menus/crt.gd
scripts/menus/eng.gd
scripts/menus/fs.gd
scripts/menus/lyt.gd
scripts/mobile.gd
scripts/modulategamepad.gd
scripts/opt.gd
scripts/options.gd
scripts/prop0.gd
scripts/sandbox.gd
scripts/sign0.gd
scripts/spawner0.gd
scripts/translateChildren00.gd
scripts/tutorial.gd
scripts/warp0.gd
systems/joystick/example/player2d.gd
systems/joystick/joystick.gd
ursc/setup.gd
## scenes
addons/CameraShake3D/Examples/shake_autoload_example_scene.tscn
addons/CameraShake3D/Examples/shake_construct_example_scene.tscn
addons/CameraShake3D/Examples/shake_node_example_scene.tscn
branches/3dchar/bubck/char.tscn
branches/3dchar/duck/char.tscn
branches/3dchar/ganderglide/char.tscn
branches/3dchar/goose/char.tscn
branches/3dchar/metallico/char.tscn
branches/3dchar/plantsiform/char.tscn
branches/3dchar/rusmo/char.tscn
branches/3dchar/slimer/char.tscn
branches/3dchar/slithe/char.tscn
branches/3dtool/stick/tool.tscn
branches/3dtool/wooden-pickaxe/tool.tscn
branches/3dtool/wooden-sword/tool.tscn
branches/crtsetup.tscn
branches/entities/creature.tscn
branches/entities/item.tscn
branches/entities/player.tscn
branches/entities/prop.tscn
branches/entities/sign.tscn
branches/hud/main.tscn
branches/hud/mobile.tscn
branches/hud/options.tscn
branches/items/coal.tscn
branches/items/cyan-tulip.tscn
branches/items/daisy.tscn
branches/items/iron-ingot.tscn
branches/items/log.tscn
branches/items/poppy.tscn
branches/items/scrap.tscn
branches/items/shiny-stone.tscn
branches/items/stick.tscn
branches/items/stone.tscn
branches/items/torch.tscn
branches/lightning/lightingcave.tscn
branches/lightning/lightjustdark.tscn
branches/lightning/lightning.tscn
branches/lightning/lightningTUT.tscn
branches/maps/cave.tscn
branches/maps/endless.tscn
branches/maps/greenish-field.tscn
branches/maps/snowy-cutscene.tscn
branches/maps/village.tscn
branches/props/coal-ore.tscn
branches/props/collision/coal-ore.tscn
branches/props/collision/diamond-ore.tscn
branches/props/collision/gold-ore.tscn
branches/props/collision/harshrock.tscn
branches/props/collision/iron-ore.tscn
branches/props/collision/ruby-ore.tscn
branches/props/collision/stone.tscn
branches/props/collision/tree.tscn
branches/props/diamond-ore.tscn
branches/props/gold-ore.tscn
branches/props/harshrock.tscn
branches/props/iron-ore.tscn
branches/props/ruby-ore.tscn
branches/props/stone.tscn
branches/props/tree.tscn
branches/warp.tscn
entities/characters/base_controller/base_controller.tscn
render.tscn
scenes/2d.tscn
scenes/3d.tscn
scenes/3d_multi.tscn
scenes/arcadeselect.tscn
scenes/disclaimer.tscn
scenes/gdSELECT.tscn
scenes/load3d.tscn
scenes/menu/menu.tscn
scenes/selectforarcade.tscn
systems/joystick/example/test_example_2d.tscn
systems/joystick/joystick.tscn
test_levels/prototype v1.tscn
