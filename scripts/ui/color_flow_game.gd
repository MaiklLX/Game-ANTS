extends Control
## First continuous Color Flow Arcade prototype. Simulation owns pixel clearing.

const BoardScript = preload("res://scripts/core/color_flow_board.gd")
const BASE_SIZE := Vector2(720.0, 1280.0)
const COLORS := {"teal": Color("#43c9b5"), "coral": Color("#f07868"), "gold": Color("#efbd62")}
const LABELS := {"teal": "БИРЮЗА", "coral": "КОРАЛЛ", "gold": "ЗОЛОТО"}
const CELL := 23.0
const GAP := 4.0
const BOARD_TOP := 330.0
const NEST := Vector2(360.0, 842.0)
const BUTTONS := {"teal": Rect2(36, 970, 204, 142), "coral": Rect2(258, 970, 204, 142), "gold": Rect2(480, 970, 204, 142)}
const PAUSE := Rect2(38, 178, 116, 54)
const SPEED := Rect2(566, 178, 116, 54)
const BG := Color("#111b1b")
const PANEL := Color("#1b2929")
const EDGE := Color("#334848")
const TXT := Color("#e7eee8")
const MUTED := Color("#91a7a0")

var board
var ants: Array[Dictionary] = []
var claimed: Dictionary = {}
var stock: Dictionary = {}
var next_id := 1
var paused := false
var speed := 1.0
var won := false
var status := "Выбери цвет — муравьи начнут разбирать мозаику."
var ui_scale := 1.0
var ui_offset := Vector2.ZERO


func _ready() -> void:
	board = BoardScript.new()
	board.configure_default()
	for color in COLORS:
		stock[color] = int(board.initial_counts[color])
	mouse_filter = Control.MOUSE_FILTER_STOP


func _process(delta: float) -> void:
	if not paused and not won:
		_simulate(delta * speed)
	queue_redraw()


func _simulate(delta: float) -> void:
	for i in range(ants.size() - 1, -1, -1):
		var ant: Dictionary = ants[i]
		var color := String(ant.color)
		var target: Vector2i = ant.target
		if not board.pixels.has(target):
			_release(target, int(ant.id))
			target = _find_target(color, ant.position, int(ant.id))
			ant.target = target
		if target.x < 0:
			ants.remove_at(i)
			continue
		var destination := _cell_center(target)
		var position: Vector2 = ant.position
		var distance := position.distance_to(destination)
		if distance <= float(ant.speed) * delta + 2.0:
			position = destination
			if board.clear_pixel(target, color):
				_release(target, int(ant.id))
				ant.position = position
				ant.target = _find_target(color, position, int(ant.id))
				if ant.target.x < 0:
					ants.remove_at(i)
					continue
			else:
				_release(target, int(ant.id))
				ant.target = _find_target(color, position, int(ant.id))
		else:
			position += (destination - position).normalized() * float(ant.speed) * delta
		ant.position = position
		ant.phase = float(ant.phase) + delta * 12.0
		ants[i] = ant
	if board.is_complete() and ants.is_empty():
		won = true
		status = "Мозаика очищена! Отличная работа."


func _find_target(color: String, from: Vector2, ant_id: int) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_distance := INF
	for cell in board.get_cells_for_color(color):
		if claimed.has(cell) and int(claimed[cell]) != ant_id:
			continue
		var distance := from.distance_squared_to(_cell_center(cell))
		if distance < best_distance:
			best_distance = distance
			best = cell
	if best.x >= 0:
		claimed[best] = ant_id
	return best


func _release(cell: Vector2i, ant_id: int) -> void:
	if claimed.has(cell) and int(claimed[cell]) == ant_id:
		claimed.erase(cell)


func _spawn_batch(color: String) -> void:
	if paused or won:
		return
	var count := mini(3, int(stock.get(color, 0)))
	if count <= 0:
		status = "Этот цвет уже закончился."
		return
	var launched := 0
	for n in range(count):
		var id := next_id
		next_id += 1
		var spawn := NEST + Vector2((n - (count - 1) * 0.5) * 18.0, 0)
		var target := _find_target(color, spawn, id)
		if target.x < 0:
			continue
		ants.append({"id": id, "color": color, "position": spawn, "target": target, "speed": 175.0 + float((id * 17) % 35), "phase": float(id)})
		launched += 1
	stock[color] = int(stock[color]) - launched
	status = "Отправлено муравьёв: %d · %s" % [launched, String(LABELS[color])] if launched > 0 else "Для этого цвета сейчас нет доступных пикселей."


func _cell_center(cell: Vector2i) -> Vector2:
	var width := float(board.width) * CELL + float(board.width - 1) * GAP
	return Vector2((720.0 - width) * 0.5 + float(cell.x) * (CELL + GAP) + CELL * 0.5, BOARD_TOP + float(cell.y) * (CELL + GAP) + CELL * 0.5)


func _draw() -> void:
	ui_scale = minf(size.x / BASE_SIZE.x, size.y / BASE_SIZE.y)
	if ui_scale <= 0.0:
		ui_scale = 1.0
	ui_offset = Vector2((size.x - 720.0 * ui_scale) * 0.5, (size.y - 1280.0 * ui_scale) * 0.5)
	draw_rect(Rect2(Vector2.ZERO, size), BG)
	draw_set_transform(ui_offset, 0.0, Vector2(ui_scale, ui_scale))
	var font: Font = ThemeDB.fallback_font
	_draw_header(font)
	_draw_board(font)
	_draw_progress(font)
	_draw_nest(font)
	_draw_ants()
	_draw_controls(font)
	if won:
		_draw_victory(font)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_header(font: Font) -> void:
	draw_string(font, Vector2(40, 34), "МУРАВЬИШКИ", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)
	draw_string(font, Vector2(40, 104), "ЦВЕТОВОЙ ПОТОК", HORIZONTAL_ALIGNMENT_LEFT, -1, 34, TXT)
	draw_string(font, Vector2(42, 139), "СОБИРАЙ МОЗАИКУ ЦВЕТ ЗА ЦВЕТОМ", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, MUTED)
	_pill(PAUSE, "Ⅱ  ПАУЗА" if not paused else "▶  ИГРАТЬ", font)
	_pill(SPEED, "×2" if speed > 1.5 else "×1", font)
	draw_line(Vector2(38, 250), Vector2(682, 250), EDGE, 2.0)


func _draw_board(font: Font) -> void:
	var width := float(board.width) * CELL + float(board.width - 1) * GAP
	var height := float(board.height) * CELL + float(board.height - 1) * GAP
	var frame := Rect2((720.0 - width) * 0.5 - 20, BOARD_TOP - 20, width + 40, height + 40)
	draw_rect(frame, Color("#172625"), true)
	draw_rect(frame, EDGE, false, 2.0, true)
	for cell in board.pixels:
		var color_name := String(board.pixels[cell])
		var rect := Rect2(_cell_center(cell) - Vector2(CELL, CELL) * 0.5, Vector2(CELL, CELL))
		draw_rect(rect, COLORS[color_name], true)
		draw_rect(Rect2(rect.position + Vector2(3, 3), Vector2(CELL - 6, 4)), Color(1, 1, 1, 0.16), true, 2.0)
	draw_string(font, Vector2(40, 294), "ПИКСЕЛЬНАЯ МОЗАИКА", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, MUTED)
	draw_string(font, Vector2(40, 294), "%d ОСТАЛОСЬ" % board.get_remaining_count(), HORIZONTAL_ALIGNMENT_RIGHT, 640, 14, TXT)


func _draw_progress(font: Font) -> void:
	var total := 0
	for value in board.initial_counts.values():
		total += int(value)
	var ratio := float(total - board.get_remaining_count()) / float(maxi(1, total))
	draw_rect(Rect2(40, 730, 640, 12), Color("#263737"), true, 6.0)
	draw_rect(Rect2(40, 730, 640.0 * ratio, 12), Color("#67c8a9"), true, 6.0)
	draw_string(font, Vector2(40, 766), "ПРОГРЕСС", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, MUTED)
	draw_string(font, Vector2(40, 766), "%d%%" % int(round(ratio * 100.0)), HORIZONTAL_ALIGNMENT_RIGHT, 640, 15, TXT)


func _draw_nest(font: Font) -> void:
	draw_circle(NEST, 38, Color("#253b37"))
	draw_arc(NEST, 42, 0.0, TAU, 48, Color("#5b8f7e"), 3.0, true)
	draw_circle(NEST, 22, Color("#d3a85d"))
	draw_circle(NEST + Vector2(-7, -3), 4, Color("#182522"))
	draw_circle(NEST + Vector2(7, -3), 4, Color("#182522"))
	draw_string(font, Vector2(360, 904), "МУРАВЕЙНИК", HORIZONTAL_ALIGNMENT_CENTER, -1, 13, MUTED)
	draw_string(font, Vector2(360, 929), "В ПОТОКЕ: %d" % ants.size(), HORIZONTAL_ALIGNMENT_CENTER, -1, 14, TXT)


func _draw_ants() -> void:
	for ant in ants:
		var color: Color = COLORS[String(ant.color)]
		var position: Vector2 = ant.position
		var phase := float(ant.phase)
		var target: Vector2i = ant.target
		var direction := (_cell_center(target) - position).normalized() if target.x >= 0 else Vector2.UP
		var side := Vector2(-direction.y, direction.x)
		draw_line(position - direction * 8.0, position - direction * 15.0 + side * sin(phase) * 2.0, Color(color, 0.28), 2.0)
		draw_circle(position, 5.0, color)
		draw_circle(position + direction * 6.0, 3.2, color.lightened(0.22))
		draw_circle(position + direction * 7.0 + side * 2.0, 1.0, Color("#14201d"))
		draw_circle(position + direction * 7.0 - side * 2.0, 1.0, Color("#14201d"))


func _draw_controls(font: Font) -> void:
	draw_string(font, Vector2(40, 958), "ЗАПУСК ПО ЦВЕТАМ", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, MUTED)
	for color in COLORS:
		var rect: Rect2 = BUTTONS[color]
		var tint: Color = COLORS[color]
		var enabled := int(stock[color]) > 0 and not paused and not won
		draw_rect(rect, Color("#233434") if enabled else Color("#1a2828"), true)
		draw_rect(rect, Color(tint, 0.85) if enabled else EDGE, false, 2.0, true)
		draw_circle(rect.position + Vector2(26, 29), 7, tint)
		draw_string(font, rect.position + Vector2(46, 34), String(LABELS[color]), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, TXT if enabled else MUTED)
		draw_string(font, rect.position + Vector2(20, 83), "%02d" % int(stock[color]), HORIZONTAL_ALIGNMENT_LEFT, -1, 32, tint if enabled else MUTED)
		draw_string(font, rect.position + Vector2(20, 115), "МУРАВЬИ", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, MUTED)
		draw_string(font, rect.position + Vector2(178, 84), "+3", HORIZONTAL_ALIGNMENT_RIGHT, -1, 16, tint)
	draw_string(font, Vector2(40, 1168), status, HORIZONTAL_ALIGNMENT_LEFT, 640, 15, TXT)
	draw_string(font, Vector2(40, 1222), "КАСАЙСЯ ЦВЕТА, ЧТОБЫ ВЫПУСТИТЬ ДО ТРЁХ МУРАВЬЁВ", HORIZONTAL_ALIGNMENT_LEFT, 640, 11, MUTED)


func _pill(rect: Rect2, label: String, font: Font) -> void:
	draw_rect(rect, PANEL, true)
	draw_rect(rect, EDGE, false, 2.0, true)
	draw_string(font, rect.position + Vector2(rect.size.x * 0.5, 34), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 8, 15, TXT)


func _draw_victory(font: Font) -> void:
	draw_rect(Rect2(42, 470, 636, 280), Color("#142321"), true)
	draw_rect(Rect2(42, 470, 636, 280), Color("#67c8a9"), false, 2.0, true)
	draw_string(font, Vector2(360, 560), "МОЗАИКА ОЖИЛА!", HORIZONTAL_ALIGNMENT_CENTER, -1, 30, TXT)
	draw_string(font, Vector2(360, 606), "Все пиксели очищены", HORIZONTAL_ALIGNMENT_CENTER, -1, 17, MUTED)
	draw_string(font, Vector2(360, 686), "КОСНИСЬ, ЧТОБЫ СЫГРАТЬ ЕЩЁ", HORIZONTAL_ALIGNMENT_CENTER, -1, 14, Color("#67c8a9"))


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_touch(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_handle_touch(event.position)


func _handle_touch(position: Vector2) -> void:
	var point := (position - ui_offset) / ui_scale
	if won:
		_restart_level()
		return
	if PAUSE.has_point(point):
		paused = not paused
		status = "Поток остановлен." if paused else "Поток снова движется."
		return
	if SPEED.has_point(point):
		speed = 2.0 if speed < 1.5 else 1.0
		status = "Скорость потока: ×%d" % int(speed)
		return
	for color in BUTTONS:
		if BUTTONS[color].has_point(point):
			_spawn_batch(String(color))
			return


func _restart_level() -> void:
	board.configure_default()
	ants.clear()
	claimed.clear()
	next_id = 1
	for color in COLORS:
		stock[color] = int(board.initial_counts[color])
	won = false
	paused = false
	speed = 1.0
	status = "Новый поток готов. Выбери первый цвет."
