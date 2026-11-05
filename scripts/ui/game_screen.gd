extends Control
## First playable portrait graybox. Rules remain in the tested core models.

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const LevelLoaderScript = preload("res://scripts/core/level_loader.gd")
const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")

const LEVEL_PATHS := [
	"res://levels/level_001.json",
	"res://levels/level_002.json",
	"res://levels/level_003.json",
	"res://levels/level_004.json",
]
const VIRTUAL_SIZE := Vector2(720.0, 1280.0)
const CELL_SIZE := 68.0
const CELL_GAP := 8.0

const COLOR_BG := Color("#101a17")
const COLOR_PANEL := Color("#1b2a24")
const COLOR_PANEL_LIGHT := Color("#26382f")
const COLOR_GRID := Color("#33483c")
const COLOR_TEXT := Color("#f2ecd9")
const COLOR_MUTED := Color("#9eae9e")
const COLOR_GOLD := Color("#e3bd70")
const COLOR_AMBER := Color("#e8ad45")
const COLOR_TEAL := Color("#55c4b4")
const COLOR_CORAL := Color("#e77c69")
const COLOR_VIOLET := Color("#aa91e5")

var _board: BoardModel
var _colony: ColonyModel
var _level_data: Dictionary = {}
var _level_index: int = 0
var _selected_squad_id: String = ""
var _status: String = "Choose a squad to begin."
var _last_path: Array[Vector2i] = []
var _last_target: Vector2i = Vector2i(-1, -1)
var _last_path_start: Vector2i = Vector2i(-1, -1)
var _ant_progress: float = 0.0
var _feedback_progress: float = 1.0
var _feedback_cell: Vector2i = Vector2i(-1, -1)
var _feedback_tween: Tween
var _is_animating: bool = false
var _returning_to_nest: bool = false
var _animation_tween: Tween
var _ui_scale: float = 1.0
var _ui_offset: Vector2 = Vector2.ZERO
var _board_origin: Vector2 = Vector2.ZERO
var _board_cell_size: float = CELL_SIZE
var _board_gap: float = CELL_GAP
var _slot_rects: Array[Rect2] = []
var _squad_rects: Dictionary = {}
var _level_rects: Array[Rect2] = []
var _restart_rect := Rect2(548, 1152, 100, 58)


func _ready() -> void:
	_board = BoardModelScript.new()
	_colony = ColonyModelScript.new()
	_load_level(0)
	queue_redraw()


func _process(_delta: float) -> void:
	# CanvasItem drawing is event-driven; request frames while tweens are moving.
	if _is_animating or _feedback_progress < 1.0:
		queue_redraw()


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	_ui_scale = minf(size.x / VIRTUAL_SIZE.x, size.y / VIRTUAL_SIZE.y)
	if _ui_scale <= 0.0:
		_ui_scale = 1.0
	_ui_offset = (size - VIRTUAL_SIZE * _ui_scale) * 0.5
	draw_set_transform(_ui_offset, 0.0, Vector2(_ui_scale, _ui_scale))

	draw_rect(Rect2(Vector2.ZERO, VIRTUAL_SIZE), COLOR_BG)
	_draw_header(font)
	_draw_slots(font)
	_draw_squads(font)
	_draw_board(font)
	_draw_status(font)
	_draw_level_picker(font)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_header(font: Font) -> void:
	draw_string(font, Vector2(42, 62), "ANTWORKS", HORIZONTAL_ALIGNMENT_LEFT, -1, 32, COLOR_GOLD)
	draw_string(font, Vector2(44, 91), "FIELD NOTES  /  MEADOW", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, COLOR_MUTED)
	draw_string(font, Vector2(678, 62), "%02d / 04" % (_level_index + 1), HORIZONTAL_ALIGNMENT_RIGHT, -1, 18, COLOR_TEXT)

	var title := String(_level_data.get("title", "New field"))
	var objective := String(_level_data.get("objective", ""))
	draw_string(font, Vector2(42, 155), title, HORIZONTAL_ALIGNMENT_LEFT, 630, 30, COLOR_TEXT)
	draw_string(font, Vector2(44, 190), objective, HORIZONTAL_ALIGNMENT_LEFT, 632, 17, COLOR_MUTED)
	draw_line(Vector2(42, 216), Vector2(678, 216), COLOR_GRID, 2.0)


func _draw_slots(font: Font) -> void:
	draw_string(font, Vector2(44, 258), "DEPLOYMENT SLOTS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_MUTED)
	_slot_rects.clear()
	var slot_count: int = _colony.slot_capacity
	var slot_width := 290.0 if slot_count == 1 else 290.0
	var start_x := (720.0 - slot_count * slot_width - (slot_count - 1) * 14.0) * 0.5
	for index in range(slot_count):
		var rect := Rect2(start_x + index * (slot_width + 14.0), 276, slot_width, 72)
		_slot_rects.append(rect)
		draw_rect(rect, COLOR_PANEL_LIGHT if _slot_is_occupied(index) else COLOR_PANEL)
		draw_rect(Rect2(rect.position, Vector2(4, rect.size.y)), COLOR_GOLD if _slot_is_occupied(index) else COLOR_GRID)
		var occupant := _slot_occupant(index)
		draw_string(font, rect.position + Vector2(20, 28), "SLOT %02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, COLOR_MUTED)
		draw_string(font, rect.position + Vector2(20, 53), occupant if not occupant.is_empty() else "AVAILABLE", HORIZONTAL_ALIGNMENT_LEFT, slot_width - 35, 17, COLOR_TEXT if not occupant.is_empty() else COLOR_MUTED)


func _draw_squads(font: Font) -> void:
	draw_string(font, Vector2(44, 392), "WORKER SQUADS  ·  TAP TO DEPLOY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_MUTED)
	_squad_rects.clear()
	var ids := _colony.get_squad_ids()
	var card_width := 196.0
	var gap := 14.0
	var total_width := ids.size() * card_width + maxi(0, ids.size() - 1) * gap
	var start_x := (720.0 - total_width) * 0.5
	for index in range(ids.size()):
		var squad_id: String = ids[index]
		var squad: Dictionary = _colony.get_squad(squad_id)
		var rect := Rect2(start_x + index * (card_width + gap), 410, card_width, 92)
		_squad_rects[squad_id] = rect
		var selected := squad_id == _selected_squad_id
		draw_rect(rect, COLOR_PANEL_LIGHT if selected else COLOR_PANEL)
		if selected:
			draw_rect(Rect2(rect.position, Vector2(card_width, 3)), COLOR_GOLD)
		var squad_color: Color = _color_for(String(squad["color"]))
		_draw_color_mark(rect.position + Vector2(30, 35), String(squad["color"]), 13.0)
		draw_string(font, rect.position + Vector2(54, 34), String(squad["color"]).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, squad_color)
		var state := "ON FIELD" if squad["deployed"] else "READY"
		var carried := int(squad["carried"])
		var capacity := int(squad["capacity"])
		var load_text := "%d / %d carried" % [carried, capacity]
		draw_string(font, rect.position + Vector2(18, 68), state + "  ·  " + load_text, HORIZONTAL_ALIGNMENT_LEFT, card_width - 28, 12, COLOR_MUTED)
		var meter := Rect2(rect.position + Vector2(18, 79), Vector2(card_width - 36, 4))
		draw_rect(meter, Color("#17231d"))
		if carried > 0 and capacity > 0:
			draw_rect(Rect2(meter.position, Vector2(meter.size.x * float(carried) / float(capacity), meter.size.y)), squad_color)


func _draw_board(font: Font) -> void:
	var board_width: float = _board.width * CELL_SIZE + maxi(0, _board.width - 1) * CELL_GAP
	var board_height: float = _board.height * CELL_SIZE + maxi(0, _board.height - 1) * CELL_GAP
	_board_origin = Vector2((720.0 - board_width) * 0.5, 570.0 + (340.0 - board_height) * 0.5)
	_board_cell_size = CELL_SIZE
	_board_gap = CELL_GAP

	draw_string(font, Vector2(44, 548), "FORAGING GROUND", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, COLOR_MUTED)
	draw_string(font, Vector2(676, 548), "%d SEEDS LEFT" % _board.remaining_resources, HORIZONTAL_ALIGNMENT_RIGHT, -1, 14, COLOR_GOLD)

	var board_frame := Rect2(_board_origin - Vector2(14, 14), Vector2(board_width, board_height) + Vector2(28, 28))
	draw_rect(board_frame, Color("#182820"))
	draw_rect(board_frame, Color("#405744"), false, 2.0)
	for y in range(_board.height):
		for x in range(_board.width):
			var cell := Vector2i(x, y)
			var rect := _cell_rect(cell)
			var inset := rect.grow(-3.0)
			var fill := Color("#22352b") if (x + y) % 2 == 0 else Color("#263a2f")
			if not _board.is_walkable(cell):
				fill = Color("#303b32")
			draw_rect(rect, Color("#17251e"))
			draw_rect(inset, fill)
			draw_rect(inset, Color("#3b5141"), false, 1.0)
			_draw_ground_detail(rect, cell)
			if cell == _board.start:
				_draw_nest(rect.get_center())
			elif _board.has_resource(cell):
				var resource_color := _board.resource_color_at(cell)
				_draw_resource(rect.get_center(), resource_color)
			elif not _board.is_walkable(cell):
				_draw_rock(rect.get_center())

	if not _last_path.is_empty():
		var previous := _last_path_start if _board.is_inside(_last_path_start) else _board.start
		for step in _last_path:
			draw_line(_cell_rect(previous).get_center(), _cell_rect(step).get_center(), COLOR_GOLD, 4.0)
			previous = step
		if _last_target != Vector2i(-1, -1):
			draw_circle(_cell_rect(_last_target).get_center(), 6.0, COLOR_TEXT)
		# A compact three-ant team reads as a living squad rather than a cursor.
		for ant_index in range(3):
			var ant_progress := clampf(_ant_progress - float(ant_index) * 0.045, 0.0, 1.0)
			var ant_position := _position_along_last_path(ant_progress)
			ant_position.y += float(ant_index - 1) * 8.0
			_draw_ant(ant_position, _selected_squad_color(), 1.0 - float(ant_index) * 0.06)
		# Show a carried seed beside the lead worker after pickup and on the return trip.
		var selected_squad := _colony.get_squad(_selected_squad_id) if not _selected_squad_id.is_empty() else {}
		if not selected_squad.is_empty() and int(selected_squad.get("carried", 0)) > 0:
			var lead_position := _position_along_last_path(clampf(_ant_progress, 0.0, 1.0))
			var seed_tint := _color_for(String(selected_squad.get("color", "amber")))
			draw_circle(lead_position + Vector2(19, -15), 7.0, Color("#18231c"))
			draw_circle(lead_position + Vector2(19, -17), 5.0, seed_tint)
			draw_line(lead_position + Vector2(21, -21), lead_position + Vector2(25, -26), Color("#9bc88e"), 1.5)

	if _board.is_inside(_feedback_cell) and _feedback_progress < 1.0:
		var pulse_color := COLOR_GOLD
		pulse_color.a = 1.0 - _feedback_progress
		draw_arc(_cell_rect(_feedback_cell).get_center(), 14.0 + _feedback_progress * 22.0, 0.0, TAU, 32, pulse_color, 3.0)


func _draw_status(font: Font) -> void:
	var panel := Rect2(42, 1000, 636, 112)
	var completed := TurnResolverScript.is_level_complete(_board, _colony)
	var blocked := TurnResolverScript.is_level_blocked(_board, _colony)
	var panel_color := Color("#20382d") if completed else Color("#392a26") if blocked else COLOR_PANEL
	var accent_color := Color("#91c99a") if completed else Color("#e58b70") if blocked else COLOR_GOLD
	draw_rect(panel, panel_color)
	draw_rect(Rect2(panel.position, Vector2(4, panel.size.y)), accent_color)
	var heading := "FIELD CLEARED" if completed else "FIELD BLOCKED" if blocked else "COLONY LOG"
	draw_string(font, Vector2(64, 1035), heading, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, accent_color)
	draw_string(font, Vector2(64, 1070), _status, HORIZONTAL_ALIGNMENT_LEFT, 580, 17, COLOR_TEXT)
	var delivered := _colony.delivered_resources
	draw_string(font, Vector2(64, 1094), "DELIVERED  %d / %d" % [delivered, _board.total_resources], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, COLOR_MUTED)


func _draw_level_picker(font: Font) -> void:
	draw_string(font, Vector2(44, 1150), "TEST LEVEL", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, COLOR_MUTED)
	_level_rects.clear()
	var level_button_width := 78.0
	var level_button_gap := 10.0
	var retry_gap := 16.0
	var level_group_width := LEVEL_PATHS.size() * level_button_width + maxi(0, LEVEL_PATHS.size() - 1) * level_button_gap
	var controls_width := level_group_width + retry_gap + _restart_rect.size.x
	var controls_start_x := (720.0 - controls_width) * 0.5
	for index in range(LEVEL_PATHS.size()):
		var rect := Rect2(controls_start_x + index * (level_button_width + level_button_gap), 1140, level_button_width, 58)
		_level_rects.append(rect)
		draw_rect(rect, COLOR_GOLD if index == _level_index else COLOR_PANEL)
		draw_string(font, rect.position + Vector2(0, 37), "%02d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 20, COLOR_BG if index == _level_index else COLOR_TEXT)
	_restart_rect.position = Vector2(controls_start_x + level_group_width + retry_gap, 1140)
	draw_rect(_restart_rect, COLOR_PANEL_LIGHT)
	draw_string(font, _restart_rect.position + Vector2(0, 36), "RETRY", HORIZONTAL_ALIGNMENT_CENTER, _restart_rect.size.x, 16, COLOR_TEXT)
	draw_string(font, Vector2(360, 1240), "ONE COLONY  ·  MANY SMALL DECISIONS", HORIZONTAL_ALIGNMENT_CENTER, 720, 12, COLOR_MUTED)


func _gui_input(event: InputEvent) -> void:
	var pressed := false
	var point := Vector2.ZERO
	if event is InputEventScreenTouch and event.pressed:
		pressed = true
		point = event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressed = true
		point = event.position
	if not pressed:
		return
	var virtual_point := (point - _ui_offset) / _ui_scale
	_handle_tap(virtual_point)
	accept_event()


func _handle_tap(point: Vector2) -> void:
	if _is_animating:
		return
	for index in range(_level_rects.size()):
		if _level_rects[index].has_point(point):
			_load_level(index)
			return
	if _restart_rect.has_point(point):
		_load_level(_level_index)
		return
	# Terminal fields accept only an explicit level change or retry.
	if TurnResolverScript.is_level_complete(_board, _colony) or TurnResolverScript.is_level_blocked(_board, _colony):
		return

	for squad_id in _squad_rects:
		if _squad_rects[squad_id].has_point(point):
			_select_or_deploy(String(squad_id))
			return

	var cell := _cell_at(point)
	if cell == Vector2i(-1, -1):
		return
	if cell == _board.start:
		_return_selected_squad()
		return
	if _board.has_resource(cell):
		_collect_selected_squad(cell)


func _load_level(index: int) -> void:
	if _animation_tween != null and _animation_tween.is_running():
		_animation_tween.kill()
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()
	_feedback_progress = 1.0
	_feedback_cell = Vector2i(-1, -1)
	_is_animating = false
	_returning_to_nest = false
	_ant_progress = 0.0
	_level_index = clampi(index, 0, LEVEL_PATHS.size() - 1)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEVEL_PATHS[_level_index]))
	if typeof(parsed) != TYPE_DICTIONARY:
		_status = "This field file could not be read."
		queue_redraw()
		return
	_level_data = parsed
	var result: Dictionary = LevelLoaderScript.load_into(_level_data, _board, _colony)
	_selected_squad_id = ""
	_last_path.clear()
	_last_target = Vector2i(-1, -1)
	_last_path_start = _board.start
	_status = "Choose a squad to begin." if result["valid"] else str(result["errors"])
	queue_redraw()


func _select_or_deploy(squad_id: String) -> void:
	var squad: Dictionary = _colony.get_squad(squad_id)
	if squad.is_empty():
		return
	_selected_squad_id = squad_id
	_last_path.clear()
	if squad["deployed"]:
		_status = "%s is on the ground. Tap a matching seed or the nest." % squad_id.replace("_", " ")
	else:
		var result: Dictionary = _colony.deploy_squad(squad_id)
		if result["valid"]:
			_status = "%s deployed. Tap a matching seed." % squad_id.replace("_", " ")
		else:
			_status = String(result["errors"][0])
	queue_redraw()


func _collect_selected_squad(cell: Vector2i) -> void:
	if _selected_squad_id.is_empty():
		_status = "Choose a worker squad first."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad["deployed"]:
		_status = "Deploy the selected squad first."
		queue_redraw()
		return
	var squad_position: Vector2i = squad.get("position", Vector2i(-1, -1))
	_last_path_start = squad_position if _board.is_inside(squad_position) else _board.start
	var preview: Dictionary = TurnResolverScript.preview_collection(
		_colony, _board, _selected_squad_id, _last_path_start, cell
	)
	if not preview["valid"]:
		_status = String(preview["errors"][0])
		queue_redraw()
		return
	_last_path = preview["path"]
	_last_target = cell
	_ant_progress = 0.0
	_returning_to_nest = false
	_is_animating = true
	_status = "Workers are following the trail..."
	_start_path_animation(1.0, false)
	queue_redraw()


func _return_selected_squad() -> void:
	if _selected_squad_id.is_empty():
		_status = "Select a deployed squad before returning."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad["deployed"]:
		_status = "No selected squad is on the ground."
		queue_redraw()
		return
	var squad_position: Vector2i = squad.get("position", Vector2i(-1, -1))
	_last_path_start = squad_position if _board.is_inside(squad_position) else _board.start
	_last_path = _board.find_path(_last_path_start, _board.start)
	_last_target = _board.start
	_ant_progress = 0.0
	if _last_path.is_empty():
		_finish_squad_return()
		return
	_returning_to_nest = true
	_is_animating = true
	_status = "Workers are following the trail home..."
	_start_path_animation(1.0, true)
	queue_redraw()


func _start_path_animation(target_progress: float, returning: bool) -> void:
	if _animation_tween != null and _animation_tween.is_running():
		_animation_tween.kill()
	var duration := maxf(0.24, float(_last_path.size()) * 0.16)
	_animation_tween = create_tween()
	_animation_tween.set_trans(Tween.TRANS_SINE)
	_animation_tween.set_ease(Tween.EASE_IN_OUT)
	_animation_tween.tween_property(self, "_ant_progress", target_progress, duration)
	_animation_tween.finished.connect(_on_path_animation_finished.bind(returning))


func _on_path_animation_finished(returning: bool) -> void:
	_is_animating = false
	if returning:
		_finish_squad_return()
	else:
		var result: Dictionary = TurnResolverScript.apply_collection(
			_colony, _board, _selected_squad_id, _last_path_start, _last_target
		)
		if not result["valid"]:
			_status = String(result["errors"][0])
			_last_path.clear()
		else:
			_trigger_feedback(_last_target)
			var squad: Dictionary = _colony.get_squad(_selected_squad_id)
			if squad.get("carried", 0) >= squad.get("capacity", 1):
				_status = "Load full. Tap the nest to deliver and free the slot."
			else:
				_status = "Seed collected. Tap another matching seed or return to the nest."
		_check_terminal_state()
	queue_redraw()


func _finish_squad_return() -> void:
	var result: Dictionary = _colony.return_squad(_selected_squad_id)
	if result["valid"]:
		_status = "%d seed(s) delivered. Deployment slot is free." % result["delivered"]
		_trigger_feedback(_board.start)
		_selected_squad_id = ""
		_last_path.clear()
		_last_target = Vector2i(-1, -1)
		_ant_progress = 0.0
	_returning_to_nest = false
	_is_animating = false
	_check_terminal_state()
	queue_redraw()


func _position_along_last_path(progress: float) -> Vector2:
	if _last_path.is_empty():
		return _cell_rect(_board.start).get_center()
	var clamped_progress := clampf(progress, 0.0, 1.0)
	var distance := clamped_progress * _last_path.size()
	var segment_index := mini(floori(distance), _last_path.size() - 1)
	var segment_progress := distance - segment_index
	var path_start := _last_path_start if _board.is_inside(_last_path_start) else _board.start
	var from_position := _cell_rect(path_start if segment_index == 0 else _last_path[segment_index - 1]).get_center()
	var to_position := _cell_rect(_last_path[segment_index]).get_center()
	return from_position.lerp(to_position, clampf(segment_progress, 0.0, 1.0))


func _draw_ant(center: Vector2, tint: Color, scale: float = 1.0) -> void:
	# Three-part silhouette; the squad is animated as a short, readable formation.
	var body_scale := Vector2.ONE * scale
	draw_circle(center + Vector2(-7, 0) * body_scale, 5.5 * scale, Color("#251d16"))
	draw_circle(center + Vector2(1, 0) * body_scale, 7.0 * scale, tint)
	draw_circle(center + Vector2(10, -1) * body_scale, 4.5 * scale, Color("#251d16"))
	draw_line(center + Vector2(-2, -4) * body_scale, center + Vector2(-7, -10) * body_scale, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(-2, 4) * body_scale, center + Vector2(-7, 10) * body_scale, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(4, -4) * body_scale, center + Vector2(7, -10) * body_scale, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(4, 4) * body_scale, center + Vector2(7, 10) * body_scale, Color("#251d16"), 2.0 * scale)


func _trigger_feedback(cell: Vector2i) -> void:
	_feedback_cell = cell
	_feedback_progress = 0.0
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_CUBIC)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	_feedback_tween.tween_property(self, "_feedback_progress", 1.0, 0.46)


func _selected_squad_color() -> Color:
	if _selected_squad_id.is_empty():
		return COLOR_GOLD
	var squad := _colony.get_squad(_selected_squad_id)
	if squad.is_empty():
		return COLOR_GOLD
	return _color_for(String(squad["color"]))


func _check_terminal_state() -> void:
	if TurnResolverScript.is_level_complete(_board, _colony):
		_status = "Field cleared! Every seed is safely home."
	elif TurnResolverScript.is_level_blocked(_board, _colony):
		_status = "No available squad can reach the remaining seeds. Retry this field."


func _cell_at(point: Vector2) -> Vector2i:
	for y in range(_board.height):
		for x in range(_board.width):
			if _cell_rect(Vector2i(x, y)).has_point(point):
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _cell_rect(cell: Vector2i) -> Rect2:
	var stride := _board_cell_size + _board_gap
	return Rect2(_board_origin + Vector2(cell.x, cell.y) * stride, Vector2(_board_cell_size, _board_cell_size))


func _slot_is_occupied(slot_index: int) -> bool:
	return not _slot_occupant(slot_index).is_empty()


func _slot_occupant(slot_index: int) -> String:
	for squad_id in _colony.get_squad_ids():
		var squad: Dictionary = _colony.get_squad(squad_id)
		if squad["deployed"] and squad["slot_index"] == slot_index:
			return squad_id.replace("_", " ").to_upper()
	return ""


func _color_for(color_name: String) -> Color:
	match color_name:
		"amber":
			return COLOR_AMBER
		"teal":
			return COLOR_TEAL
		"coral":
			return COLOR_CORAL
		"violet":
			return COLOR_VIOLET
	return COLOR_TEXT


func _symbol_for(color_name: String) -> String:
	match color_name:
		"amber":
			return "A"
		"teal":
			return "T"
		"coral":
			return "C"
		"violet":
			return "V"
	return "?"


func _draw_nest(center: Vector2) -> void:
	# Layered earthen nest entrance with a warm rim and a readable dark opening.
	draw_circle(center, 25.0, Color("#6c5738"))
	draw_circle(center, 20.0, Color("#b28a4d"))
	draw_circle(center, 14.0, Color("#493b2b"))
	draw_arc(center, 23.0, PI * 0.12, PI * 0.88, 24, Color("#e2c27c"), 2.5)
	draw_circle(center + Vector2(0, 1), 7.0, Color("#211f18"))
	draw_circle(center + Vector2(-2, -3), 2.0, Color("#d9b76e"))


func _draw_resource(center: Vector2, color_name: String) -> void:
	# Distinct seed body plus a small leaf; color is reinforced by shape labels.
	var tint := _color_for(color_name)
	draw_circle(center + Vector2(0, 2), 20.0, Color("#17231c"))
	draw_circle(center, 17.0, tint)
	draw_circle(center + Vector2(-5, -5), 5.0, Color(1.0, 1.0, 1.0, 0.28))
	draw_line(center + Vector2(5, -12), center + Vector2(12, -20), Color("#8fc28a"), 3.0)
	draw_string(ThemeDB.fallback_font, center + Vector2(-17, 26), _symbol_for(color_name), HORIZONTAL_ALIGNMENT_CENTER, 34, 11, COLOR_BG)


func _draw_rock(center: Vector2) -> void:
	# A small clustered stone silhouette reads more naturally than a flat blocked square.
	draw_circle(center + Vector2(1, 4), 22.0, Color("#1a241e"))
	draw_circle(center + Vector2(-7, 2), 12.0, Color("#657064"))
	draw_circle(center + Vector2(7, -4), 14.0, Color("#788474"))
	draw_circle(center + Vector2(0, -12), 9.0, Color("#8b9684"))
	draw_line(center + Vector2(-8, -4), center + Vector2(-2, -10), Color("#aab39f"), 2.0)


func _draw_ground_detail(rect: Rect2, cell: Vector2i) -> void:
	# Quiet, deterministic meadow marks add texture without competing with game pieces.
	var base := rect.position
	var variant := posmod(cell.x * 3 + cell.y * 5, 3)
	var tint := Color("#38513b")
	if variant == 0:
		var root := base + Vector2(12, 53)
		draw_line(root, root + Vector2(-3, -6), tint, 1.5)
		draw_line(root, root + Vector2(2, -8), tint, 1.5)
		draw_line(root, root + Vector2(6, -5), tint, 1.5)
	elif variant == 1:
		var root := base + Vector2(54, 14)
		draw_line(root, root + Vector2(-4, -5), tint, 1.5)
		draw_line(root, root + Vector2(1, -8), tint, 1.5)
		draw_line(root, root + Vector2(5, -4), tint, 1.5)
	else:
		draw_circle(base + Vector2(53, 53), 1.5, tint)
		draw_circle(base + Vector2(58, 48), 1.0, tint)


func _draw_color_mark(center: Vector2, color_name: String, radius: float) -> void:
	var tint := _color_for(color_name)
	match color_name:
		"teal":
			var diamond := PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, 0),
				center + Vector2(0, radius),
				center + Vector2(-radius, 0),
			])
			draw_colored_polygon(diamond, tint)
		"coral":
			var triangle := PackedVector2Array([
				center + Vector2(0, -radius),
				center + Vector2(radius, radius),
				center + Vector2(-radius, radius),
			])
			draw_colored_polygon(triangle, tint)
		"violet":
			draw_rect(Rect2(center - Vector2(radius, radius), Vector2(radius * 2.0, radius * 2.0)), tint)
		_:
			draw_circle(center, radius, tint)
