extends Node
# iPhone screen fixes for The Chosen Duck, added by the iPhone port (the game's own files stay unchanged):
#  - widescreen: the game's 4:3 picture is widened to fill the whole iPhone screen, edge to edge,
#    showing more of the world (nothing is stretched); its menus stay centred
#  - touch buttons and joystick are kept inside the safe area (clear of the Dynamic Island and
#    the rounded corners), whichever way round the phone is held
#  - the game's own "full screen" option (Options > video) switches widescreen on and off
# The same file is copied to user://update/ so a version downloaded by the updater gets it too.

const CFG := "user://ios_screen.cfg"
const MARGIN := 12.0          # extra space between the buttons and the safe-area edge, in pixels

var widescreen := true
var _orig_ratio := {}         # AspectRatioContainer -> its original ratio
var _orig_2d := {}            # SubViewport -> its original 2D size
var _orig_pos := {}           # touch control -> its original position
var _fs_labels: Array = []
var _arcs: Array = []           # AspectRatioContainers seen (tracked as they're added: no tree searches per frame)
var _mobile_layers: Array = []  # the game's touch-control layers (scripts/mobile.gd)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var c := ConfigFile.new()
	if c.load(CFG) == OK:
		widescreen = c.get_value("screen", "widescreen", true)
	get_tree().node_added.connect(_on_node_added)
	# Godot readies the autoloads and the first scene together, so that scene was added before
	# this could listen: pick up what's already there
	for n in get_tree().root.find_children("*", "", true, false):
		_on_node_added(n)
	_share_with_updates()

func _share_with_updates() -> void:
	# keep a plain-text copy where a downloaded version can load it (see TCDUpdater.m)
	var src := FileAccess.get_file_as_string("res://ios_screen_src.txt")
	if src.is_empty():
		return
	DirAccess.make_dir_recursive_absolute("user://update")
	var f := FileAccess.open("user://update/ios_screen.gd", FileAccess.WRITE)
	if f:
		f.store_string(src)

func _save() -> void:
	var c := ConfigFile.new()
	c.set_value("screen", "widescreen", widescreen)
	c.save(CFG)

func _on_node_added(n: Node) -> void:
	if n is AspectRatioContainer:
		if not n in _arcs: _arcs.append(n)
	elif n is CanvasLayer and n.get_script() and String(n.get_script().resource_path).ends_with("mobile.gd"):
		if not n in _mobile_layers: _mobile_layers.append(n)
	# the game's "full screen" option: on iPhone it switches widescreen instead of window mode
	if n is Label and n.name == "fs" and n.get_script() and String(n.get_script().resource_path).ends_with("fs.gd"):
		if n.is_node_ready():
			_take_over_fs.call_deferred(n)
		else:
			n.ready.connect(_take_over_fs.bind(n), CONNECT_ONE_SHOT)

func _take_over_fs(lbl: Label) -> void:
	var b := lbl.get_node_or_null("Button")
	if b:
		for c in b.button_down.get_connections():
			b.button_down.disconnect(c["callable"])
		b.button_down.connect(_toggle)
	_fs_labels.append(lbl)

func _toggle() -> void:
	widescreen = not widescreen
	_save()

func _safe_rect() -> Rect2:
	var win := Vector2(DisplayServer.window_get_size())
	var safe := Rect2(DisplayServer.get_display_safe_area())
	if safe.size.x <= 0 or safe.size.y <= 0 or safe.size.x > win.x + 1 or safe.size.y > win.y + 1:
		safe = Rect2(Vector2.ZERO, win)
	return safe

var _log_t := 0.0
var _log_n := 0

func _process(delta: float) -> void:
	var win := Vector2(DisplayServer.window_get_size())
	var safe := _safe_rect()
	_log_t -= delta
	if _log_t <= 0.0 and _log_n < 12:   # a few lines in Godot's log, to check the screen maths
		_log_t = 5.0; _log_n += 1
		print("IOSScreen: window ", win, " safe ", DisplayServer.get_display_safe_area(), " screen ", DisplayServer.screen_get_size(),
			" widescreen ", widescreen, " containers ", _arcs.size(), " ratios ", _arcs.map(func(a): return a.ratio if is_instance_valid(a) else -1.0),
			" touch layers ", _mobile_layers.size())
	_fit_picture(win, safe)
	_fit_touch_controls(safe)
	_update_fs_labels()

# ---- widescreen ----
func _fit_picture(win: Vector2, safe: Rect2) -> void:
	for arc in _arcs.duplicate():
		if not is_instance_valid(arc) or not arc.is_inside_tree():
			_arcs.erase(arc)
			_orig_ratio.erase(arc)
			continue
		if not _orig_ratio.has(arc):
			_orig_ratio[arc] = arc.ratio
		var orig: float = _orig_ratio[arc]
		var want: float = orig
		if widescreen and win.y > 0:
			want = max(orig, win.x / win.y)   # the whole screen, edge to edge
		if abs(arc.ratio - want) > 0.001:
			arc.ratio = want
		# keep the game's 2D overlays (hearts, menus, dialogue) at their own shape, just wider
		for svc in arc.get_children():
			if not (svc is SubViewportContainer):
				continue
			for sv in svc.get_children():
				if not (sv is SubViewport) or sv.size_2d_override == Vector2i.ZERO:
					continue
				_fit_2d(sv, orig, want, win, safe)

func _fit_2d(sv: SubViewport, orig: float, want: float, win: Vector2, safe: Rect2) -> void:
	if not _orig_2d.has(sv):
		_orig_2d[sv] = sv.size_2d_override
		sv.tree_exiting.connect(func(): _orig_2d.erase(sv), CONNECT_ONE_SHOT)
	var o: Vector2i = _orig_2d[sv]
	var w := o
	if want > orig + 0.001:
		w = Vector2i(roundi(o.y * want), o.y)
	if sv.size_2d_override != w:
		sv.size_2d_override = w
	# The game places its 2D screens for a 640-wide picture. In the wider picture they're centred
	# (X = the extra width on each side); anything anchored to the picture's edges or centre, and
	# full-screen covers such as fades, stretch to the real edges instead.
	var x := (w.x - o.x) / 2.0
	# the Dynamic Island / rounded-corner margins, in the game's 2D units
	var k: float = float(w.x) / maxf(win.x, 1.0)
	var inset_l: float = safe.position.x * k
	var inset_r: float = (win.x - safe.end.x) * k
	for layer in sv.get_children():
		if layer is CanvasLayer:
			if layer.offset.x != x:
				layer.offset.x = x
			for c in layer.get_children():
				if c is Control:
					_place_2d(c, x, float(o.x), inset_l, inset_r)

func _place_2d(c: Control, x: float, design_w: float, inset_l: float, inset_r: float) -> void:
	if not c.has_meta("ios_orig"):
		c.set_meta("ios_orig", [c.offset_left, c.offset_right])
	var key := Vector3(x, inset_l, inset_r)
	if c.get_meta("ios_key", Vector3.ZERO) == key:
		return
	var orig: Array = c.get_meta("ios_orig")
	var l: float = orig[0]
	var r: float = orig[1]
	if c.anchor_left >= 0.99:
		# pinned to the right edge: the real right edge, kept clear of the Dynamic Island
		l -= x + inset_r; r -= x + inset_r
	elif c.anchor_left > 0.0 and c.anchor_right < 0.99:
		# centred: the real centre
		l -= x; r -= x
	elif c.anchor_right > 0.0:
		# stretched across (covers, bars): the whole width, edge to edge
		l -= x; r -= x
	elif l <= 0.0 and r >= design_w:
		# a full-screen cover drawn at a fixed 640 size: widen it to the whole picture
		l -= x; r += x
	c.offset_left = l
	c.offset_right = r
	c.set_meta("ios_key", key)

# ---- touch controls inside the safe area ----
const GROUP := ["Attack", "Run", "Inv"]   # the action buttons on the right
const GROUP_SQUEEZE := 0.7                 # brings them closer together (1.0 = the game's own spacing)
const INWARD := 0.03                       # and a little in from the screen edge (share of the width)

func _fit_touch_controls(safe: Rect2) -> void:
	var area := safe.grow(-MARGIN)
	for layer in _mobile_layers.duplicate():
		if not is_instance_valid(layer) or not layer.is_inside_tree():
			_mobile_layers.erase(layer)
			continue
		var kids: Array = []
		for c in layer.get_children():
			if not (c is Control) or c.name == "ColorRect":
				continue
			if not _orig_pos.has(c):
				_orig_pos[c] = c.position
				c.tree_exiting.connect(func(): _orig_pos.erase(c), CONNECT_ONE_SHOT)
			# start from where the game puts it
			if c.position != _orig_pos[c]:
				c.position = _orig_pos[c]
			kids.append(c)
		# the action buttons: closer together around the attack button, and nearer the thumb
		var anchor := layer.get_node_or_null("Attack") as Control
		var cy := 0.0
		if anchor:
			var ar: Rect2 = anchor.get_global_transform() * Rect2(Vector2.ZERO, anchor.size)
			cy = ar.get_center().y
		for c in kids:
			if anchor and c.name in GROUP:
				var r0: Rect2 = c.get_global_transform() * Rect2(Vector2.ZERO, c.size)
				c.position.y += (cy - r0.get_center().y) * (1.0 - GROUP_SQUEEZE)
				c.position.x -= safe.size.x * INWARD
		# then pushed inside the safe area (clear of the Dynamic Island and rounded corners)
		for c in kids:
			var r: Rect2 = c.get_global_transform() * Rect2(Vector2.ZERO, c.size)
			var d := Vector2.ZERO
			if r.end.x > area.end.x: d.x = area.end.x - r.end.x
			if r.position.x + d.x < area.position.x: d.x = area.position.x - r.position.x
			if r.end.y > area.end.y: d.y = area.end.y - r.end.y
			if r.position.y + d.y < area.position.y: d.y = area.position.y - r.position.y
			if d != Vector2.ZERO:
				c.position += d

func _update_fs_labels() -> void:
	for lbl in _fs_labels.duplicate():
		if not is_instance_valid(lbl):
			_fs_labels.erase(lbl)
			continue
		var t: String = lbl.text
		var cut := t.find("-- ")
		if cut < 0:
			continue
		var want := t.substr(0, cut + 3) + ("on" if widescreen else "off")
		if t != want:
			lbl.text = want
