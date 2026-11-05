extends Control
## First playable portrait graybox. Rules remain in the tested core models.

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const LevelLoaderScript = preload("res://scripts/core/level_loader.gd")
const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")
const ProgressStoreScript = preload("res://scripts/core/progress_store.gd")
const LevelGuidanceScript = preload("res://scripts/ui/level_guidance.gd")
const ResponsiveLayoutScript = preload("res://scripts/ui/responsive_layout.gd")
const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")

const CAMPAIGN_MANIFEST_PATH := "res://campaign/campaign_manifest.json"
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

const HINT_TRANSLATIONS := {
  "A slot is occupied. Return that team before sending this color out.": "Место занято. Верните отряд, прежде чем отправлять этот цвет.",
  "Seed aboard. Return to the nest to free the only slot for the other color.": "Семя уже у отряда. Вернитесь в муравейник, чтобы освободить место для другого цвета.",
  "This squad collects only its matching color. Find that seed, then bring it home.": "Этот отряд собирает только семена своего цвета. Найдите подходящее и доставьте его домой.",
  "A squad is still out. Select it to collect or return it before switching colors.": "Один отряд ещё в поле. Выберите его для сбора или возвращения, прежде чем менять цвет.",
  "One seed is home. The free slot is ready for the squad matching the other color.": "Одно семя уже дома. Свободное место ждёт отряд другого цвета.",
  "One slot, two colors: match each squad to its seed, then return before switching teams.": "Одно место и два цвета: подберите каждому отряду своё семя и возвращайтесь перед сменой команды.",
  "The only slot is occupied. Return that squad before sending this carrier.": "Единственное место занято. Верните отряд, прежде чем отправлять этого носильщика.",
  "Amber load full. Return to deliver both seeds and free the only slot.": "Янтарный груз собран. Вернитесь с двумя семенами и освободите единственное место.",
  "Amber carries two. Collect both amber seeds before returning for one full haul.": "Янтарный отряд несёт два семени. Соберите оба и возвращайтесь с полным грузом.",
  "Teal seed aboard. Return home; amber's pair needs a separate two-seed trip.": "Бирюзовое семя собрано. Возвращайтесь: за янтарной парой нужен отдельный рейс.",
  "Teal carries one. Collect its seed, return, then send amber for the pair.": "Бирюзовый отряд несёт одно семя. Доставьте его, затем отправляйте янтарный за парой.",
  "A carrier is still out. Select it to harvest or return it before switching squads.": "Носильщик ещё в поле. Выберите его для сбора или возвращения, прежде чем менять отряд.",
  "A load is home. Use the free slot for the other color's remaining seeds.": "Груз доставлен. Используйте свободное место для оставшихся семян другого цвета.",
  "Amber carries two: make one full two-seed trip, then send teal on its separate run.": "Янтарный отряд несёт два семени: завершите полный рейс, затем отправьте бирюзовый отдельно.",
  "A slot is occupied. Return a team before deploying this squad.": "Место занято. Верните отряд, прежде чем отправлять этот.",
  "Both squads can work in the field. Match each squad to its own color, then return them.": "Оба отряда могут работать. Направьте каждого к семенам своего цвета, затем возвращайтесь.",
  "Seed secured. The second slot is free—the other color can deploy before returning.": "Семя собрано. Второе место свободно — отправьте отряд другого цвета до возвращения.",
  "One slot is free. Deploy the other color so both teams can work before returning.": "Одно место свободно. Отправьте отряд другого цвета, чтобы оба работали одновременно.",
  "Two slots and one narrow pass: deploy amber and teal before bringing either team home.": "Два места и узкий проход: отправьте янтарный и бирюзовый отряды, прежде чем возвращать любой из них.",
  "Both slots are busy. Select a team to collect or return it before changing squads.": "Оба места заняты. Выберите отряд для сбора или возвращения, прежде чем менять команду.",
  "One squad is already out. Deploy the other color into the free slot before returning.": "Один отряд уже в поле. Отправьте другой цвет на свободное место, прежде чем возвращаться.",
  "Three colors, two slots. Amber carries its pair; teal and coral each need their own trip.": "Три цвета и два места. Янтарный забирает пару, бирюзовый и коралловый идут отдельными рейсами.",
  "Both slots are busy. Select a team to harvest or return; the third color waits.": "Оба места заняты. Выберите отряд для сбора или возвращения; третий цвет подождёт.",
  "One team is out. Use the free slot for a second color; the third waits for a return.": "Один отряд в поле. Используйте свободное место для второго цвета, третий дождётся возвращения.",
  "A return has freed a slot. Rotate the remaining colors; amber can carry its pair together.": "Возвращение освободило место. Чередуйте оставшиеся цвета; янтарный может забрать пару за раз.",
  "Both slots are occupied. Return a deployed team before sending this color out.": "Оба места заняты. Верните отряд, прежде чем отправлять этот цвет.",
  "One slot is free. Deploy this color now; the third team waits for a return.": "Одно место свободно. Отправьте этот цвет сейчас, третий отряд дождётся возвращения.",
  "Amber load is full. Deliver both seeds, then rotate in the waiting color.": "Янтарный груз собран. Доставьте оба семени, затем отправьте ожидающий цвет.",
  "Amber can carry both seeds. Fill its second space before returning; the third color waits.": "Янтарный отряд может нести два семени. Заполните второе место; третий цвет подождёт.",
  "One amber seed aboard. Collect its partner; the free slot can run teal or coral.": "Одно янтарное семя уже собрано. Заберите пару; свободное место займёт бирюзовый или коралловый.",
  "Amber can carry both seeds in one trip. Use the other slot for teal or coral.": "Янтарный отряд заберёт оба семени за один рейс. Второе место отдайте бирюзовому или коралловому.",
  "Load aboard. Return a team to rotate in the third color.": "Груз собран. Верните отряд, чтобы отправить третий цвет.",
  "Seed aboard. Use the free slot for another color before rotating the third.": "Семя собрано. Используйте свободное место для другого цвета, прежде чем менять третий.",
  "Both slots are occupied. Return a team before deploying the third color.": "Оба места заняты. Верните отряд, прежде чем отправлять третий цвет.",
  "One slot is free. Deploy another color; the third team waits for a return.": "Одно место свободно. Отправьте другой цвет, третий отряд дождётся возвращения.",
  "Seed aboard. Both slots are in use; return this team to free one.": "Семя собрано. Оба места заняты — верните этот отряд, чтобы освободить одно.",
  "Seed secured. The second slot is free—deploy the other color before returning.": "Семя собрано. Второе место свободно — отправьте отряд другого цвета до возвращения."
}

func _hint_ru(value: String) -> String:
	return String(HINT_TRANSLATIONS.get(value, value))

var _board: BoardModel
var _colony: ColonyModel
var _level_data: Dictionary = {}
var _level_index: int = 0
var _level_page_start: int = 0
var _campaign_levels: Array[Dictionary] = []
var _ru_localization: Dictionary = {}
var _progress_store
var _progress_warning: String = ""
var _tutorial_active: bool = false
var _tutorial_step: int = -1
var _tutorial_skip_rect := Rect2()
var _selected_squad_id: String = ""
var _status: String = "Выберите отряд, чтобы начать."
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
var _layout_extra: float = 0.0
var _board_origin: Vector2 = Vector2.ZERO
var _board_cell_size: float = CELL_SIZE
var _board_gap: float = CELL_GAP
var _slot_rects: Array[Rect2] = []
var _squad_rects: Dictionary = {}
var _level_rects: Array[Rect2] = []
var _previous_page_rect := Rect2()
var _next_page_rect := Rect2()
var _restart_rect := Rect2(548, 1152, 100, 58)


func _ready() -> void:
	_load_ru_localization()
	_board = BoardModelScript.new()
	_colony = ColonyModelScript.new()
	var catalog_result: Dictionary = CampaignCatalogScript.load_catalog(CAMPAIGN_MANIFEST_PATH)
	if not catalog_result["valid"]:
		_status = "Ошибка данных кампании: " + "; ".join(catalog_result["errors"])
		push_error(_status)
		queue_redraw()
		return
	_campaign_levels = catalog_result["levels"]
	var level_ids: Array[String] = []
	for level_record in _campaign_levels:
		level_ids.append(String(level_record["id"]))
	_progress_store = ProgressStoreScript.new()
	var progress_result: Dictionary = _progress_store.load_progress(level_ids)
	if not progress_result.get("valid", false):
		_progress_warning = String(progress_result.get("warning", "Не удалось загрузить прогресс."))
	else:
		_progress_warning = String(progress_result.get("warning", ""))
	var initial_index := 0
	var saved_level_id: String = _progress_store.get_last_selected_level_id()
	for index in range(_campaign_levels.size()):
		if String(_campaign_levels[index]["id"]) == saved_level_id:
			initial_index = index
			break
	_load_level(initial_index)
	queue_redraw()


func _process(_delta: float) -> void:
	# CanvasItem drawing is event-driven; request frames while tweens are moving.
	if _is_animating or _feedback_progress < 1.0:
		queue_redraw()


func _draw() -> void:
	var font: Font = ThemeDB.fallback_font
	var safe_rect := Rect2(Vector2.ZERO, size)
	var platform := OS.get_name()
	if platform == "Android" or platform == "iOS":
		safe_rect = ResponsiveLayoutScript.safe_viewport_rect(
			size,
			DisplayServer.get_display_safe_area(),
			DisplayServer.screen_get_size()
		)
	var layout: Dictionary = ResponsiveLayoutScript.calculate(safe_rect.size)
	_ui_scale = float(layout["scale"])
	_ui_offset = safe_rect.position + layout["offset"]
	_layout_extra = float(layout["extra_height"])
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BG)
	draw_set_transform(_ui_offset, 0.0, Vector2(_ui_scale, _ui_scale))
	_draw_header(font)
	_draw_slots(font)
	_draw_squads(font)
	_draw_board(font)
	_draw_status(font)
	_draw_level_picker(font)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_header(font: Font) -> void:
	draw_string(font, Vector2(42, 62), "МУРАВЕЙНИК", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(32, _ui_scale), COLOR_GOLD)
	var chapter_title := String(_campaign_levels[_level_index].get("chapter_title", "КАМПАНИЯ")) if not _campaign_levels.is_empty() else "ДАННЫЕ КАМПАНИИ"
	draw_string(font, Vector2(44, 91), "ПОЛЕВЫЕ ЗАМЕТКИ  /  " + _chapter_title_ru(chapter_title), HORIZONTAL_ALIGNMENT_LEFT, 570, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	draw_string(font, Vector2(560, 62), "%03d / %03d" % [_level_index + 1, _campaign_levels.size()], HORIZONTAL_ALIGNMENT_RIGHT, 118, ResponsiveLayoutScript.font_size(18, _ui_scale), COLOR_TEXT)

	var level_id := String(_campaign_levels[_level_index].get("id", "")) if not _campaign_levels.is_empty() else ""
	var translated_level: Dictionary = _ru_localization.get("levels", {}).get(level_id, {})
	var title := String(translated_level.get("title", _level_data.get("title", "Новое поле")))
	var objective := _objective_for_display(String(translated_level.get("objective", _level_data.get("objective", ""))))
	draw_string(font, Vector2(42, 155), title, HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(30, _ui_scale), COLOR_TEXT)
	draw_string(font, Vector2(44, 190), objective, HORIZONTAL_ALIGNMENT_LEFT, 632, ResponsiveLayoutScript.font_size(17, _ui_scale), COLOR_MUTED)
	var field_hint := _contextual_hint()
	if not field_hint.is_empty():
		draw_string(font, Vector2(44, 219), field_hint, HORIZONTAL_ALIGNMENT_LEFT, 632, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_AMBER)
		draw_line(Vector2(42, 236), Vector2(678, 236), COLOR_GRID, 2.0)
	else:
		draw_line(Vector2(42, 216), Vector2(678, 216), COLOR_GRID, 2.0)



func _load_ru_localization() -> void:
	var path := "res://localization/ru.json"
	if not FileAccess.file_exists(path):
		push_warning("Russian localization file is missing: " + path)
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) == TYPE_DICTIONARY:
		_ru_localization = parsed
	else:
		push_warning("Russian localization file is invalid.")


func _chapter_title_ru(value: String) -> String:
	var chapters: Dictionary = _ru_localization.get("chapter_titles", {})
	return String(chapters.get(value, value))


func _color_name_ru(value: String) -> String:
	match value:
		"amber":
			return "ЯНТАРНЫЙ"
		"teal":
			return "БИРЮЗОВЫЙ"
		"coral":
			return "КОРАЛЛОВЫЙ"
		"violet":
			return "ФИОЛЕТОВЫЙ"
	return value.to_upper()


func _objective_for_display(objective: String) -> String:
	if _ui_scale >= 0.52 or objective.length() <= 56:
		return objective
	return objective.left(53).strip_edges() + "…"


func _contextual_hint() -> String:
	if _campaign_levels.is_empty() or _tutorial_active:
		return ""
	var selected_squad: Dictionary = _colony.get_squad(_selected_squad_id) if not _selected_squad_id.is_empty() else {}
	return _hint_ru(LevelGuidanceScript.get_hint(
		String(_campaign_levels[_level_index]["id"]),
		selected_squad,
		_colony.get_active_slot_count(),
		_colony.slot_capacity,
		_colony.delivered_resources
	))


func _error_ru(value: String) -> String:
	match value:
		"No deployment slot is available.":
			return "Нет свободного места для отряда."
		"Squad must be deployed before collecting.":
			return "Сначала отправьте отряд в поле."
		"Squad carrying capacity is full.":
			return "Отряд уже несёт полный груз."
		"No resource is available at the target cell.":
			return "В выбранной клетке нет семени."
		"Resource color does not match the squad.":
			return "Цвет семени не подходит этому отряду."
		"Target resource is not reachable.":
			return "До этого семени нет доступного пути."
		"Resource could not be collected.":
			return "Не удалось собрать семя."
		"Squad is not deployed.":
			return "Этот отряд ещё не отправлен в поле."
		"Squad is already deployed.":
			return "Этот отряд уже находится в поле."
		"Squad must occupy a deployment slot.":
			return "Отряду нужно свободное место для выхода."
		"Progress file could not be opened for reading.":
			return "Не удалось прочитать файл прогресса."
		"Progress saving is disabled.":
			return "Сохранение прогресса временно отключено."
		"Could not open temporary progress file.":
			return "Не удалось создать временный файл прогресса."
		"Could not commit the new progress file.":
			return "Не удалось сохранить новый файл прогресса."
	return value

func _draw_slots(font: Font) -> void:
	draw_string(font, Vector2(44, 258 + _layout_extra * 0.08), "МЕСТА ДЛЯ ОТРЯДОВ", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	_slot_rects.clear()
	var slot_count: int = _colony.slot_capacity
	var slot_gap := 8.0 if slot_count >= 3 else 14.0
	var slot_width := minf(290.0, (636.0 - (slot_count - 1) * slot_gap) / float(slot_count))
	var total_width := slot_count * slot_width + (slot_count - 1) * slot_gap
	var start_x := (720.0 - total_width) * 0.5
	for index in range(slot_count):
		var rect := Rect2(start_x + index * (slot_width + slot_gap), 276 + _layout_extra * 0.08, slot_width, 80)
		_slot_rects.append(rect)
		draw_rect(rect, COLOR_PANEL_LIGHT if _slot_is_occupied(index) else COLOR_PANEL)
		draw_rect(Rect2(rect.position, Vector2(4, rect.size.y)), COLOR_GOLD if _slot_is_occupied(index) else COLOR_GRID)
		var occupant := _slot_occupant(index)
		draw_string(font, rect.position + Vector2(20, 28), "МЕСТО %02d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
		draw_string(font, rect.position + Vector2(20, 53), occupant if not occupant.is_empty() else "СВОБОДНО", HORIZONTAL_ALIGNMENT_LEFT, slot_width - 35, ResponsiveLayoutScript.font_size(17, _ui_scale), COLOR_TEXT if not occupant.is_empty() else COLOR_MUTED)


func _draw_squads(font: Font) -> void:
	draw_string(font, Vector2(44, 392 + _layout_extra * 0.18), "ОТРЯДЫ РАБОЧИХ  ·  НАЖМИТЕ ДЛЯ ВЫХОДА", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	_squad_rects.clear()
	var ids := _colony.get_squad_ids()
	var card_width := ResponsiveLayoutScript.squad_card_width(ids.size())
	var gap := ResponsiveLayoutScript.squad_card_gap(ids.size())
	var total_width := ids.size() * card_width + maxi(0, ids.size() - 1) * gap
	var start_x := (720.0 - total_width) * 0.5
	for index in range(ids.size()):
		var squad_id: String = ids[index]
		var squad: Dictionary = _colony.get_squad(squad_id)
		var rect := Rect2(start_x + index * (card_width + gap), 410 + _layout_extra * 0.18, card_width, ResponsiveLayoutScript.squad_card_height(_ui_scale))
		_squad_rects[squad_id] = rect
		var selected := squad_id == _selected_squad_id
		draw_rect(rect, COLOR_PANEL_LIGHT if selected else COLOR_PANEL)
		if selected:
			draw_rect(Rect2(rect.position, Vector2(card_width, 3)), COLOR_GOLD)
		var squad_color: Color = _color_for(String(squad["color"]))
		_draw_color_mark(rect.position + Vector2(30, 35), String(squad["color"]), 13.0)
		draw_string(font, rect.position + Vector2(54, 34), _color_name_ru(String(squad["color"])), HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), squad_color)
		var state := "В ПОЛЕ" if squad["deployed"] else "ГОТОВ"
		var carried := int(squad["несут"])
		var capacity := int(squad["capacity"])
		var load_text := "%d/%d" % [carried, capacity] if ids.size() >= 4 else "%d / %d собрано" % [carried, capacity]
		var state_label := state
		if ids.size() >= 4:
			state_label = "В ПОЛЕ" if squad["deployed"] else "ГОТОВ"
		draw_string(font, rect.position + Vector2(18, 68), state_label + "  ·  " + load_text, HORIZONTAL_ALIGNMENT_LEFT, card_width - 28, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)
		var meter := Rect2(rect.position + Vector2(18, 79), Vector2(card_width - 36, 4))
		draw_rect(meter, Color("#17231d"))
		if carried > 0 and capacity > 0:
			draw_rect(Rect2(meter.position, Vector2(meter.size.x * float(carried) / float(capacity), meter.size.y)), squad_color)


func _draw_board(font: Font) -> void:
	var board_width: float = _board.width * CELL_SIZE + maxi(0, _board.width - 1) * CELL_GAP
	var board_height: float = _board.height * CELL_SIZE + maxi(0, _board.height - 1) * CELL_GAP
	_board_origin = Vector2((720.0 - board_width) * 0.5, 570.0 + _layout_extra * 0.40 + (340.0 - board_height) * 0.5)
	_board_cell_size = CELL_SIZE
	_board_gap = CELL_GAP

	var board_label_y := _board_origin.y - 22.0
	draw_string(font, Vector2(44, board_label_y), "ПОЛЕ СБОРА", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	var resource_label := "ОСТАЛОСЬ СЕМЯН: %d" % _board.remaining_resources
	draw_string(font, Vector2(498, board_label_y), resource_label, HORIZONTAL_ALIGNMENT_RIGHT, 180, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_GOLD)

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
		if not selected_squad.is_empty() and int(selected_squad.get("несут", 0)) > 0:
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
	var panel := Rect2(42, 1000 + _layout_extra * 0.68, 636, 124)
	var completed := TurnResolverScript.is_level_complete(_board, _colony)
	var blocked := TurnResolverScript.is_level_blocked(_board, _colony)
	var panel_color := Color("#20382d") if completed else Color("#392a26") if blocked else COLOR_PANEL
	var accent_color := Color("#91c99a") if completed else Color("#e58b70") if blocked else COLOR_GOLD
	draw_rect(panel, panel_color)
	draw_rect(Rect2(panel.position, Vector2(4, panel.size.y)), accent_color)

	var heading := "ПОЛЕ ЗАЧИЩЕНО" if completed else "ПУТЬ ЗАБЛОКИРОВАН" if blocked else "ПЕРВАЯ ЭКСПЕДИЦИЯ" if _tutorial_active else "ЖУРНАЛ КОЛОНИИ"
	draw_string(font, Vector2(64, 1035 + _layout_extra * 0.68), heading, HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(13, _ui_scale), accent_color if not _tutorial_active else COLOR_GOLD)
	var action_width := ResponsiveLayoutScript.status_action_width(_ui_scale)
	var action_height := ResponsiveLayoutScript.status_action_height(_ui_scale)
	var action_x := panel.position.x + panel.size.x - action_width - 24.0
	if _tutorial_active:
		_tutorial_skip_rect = Rect2(action_x, panel.position.y + 12, action_width, action_height)
		draw_rect(_tutorial_skip_rect, COLOR_PANEL_LIGHT)
		draw_string(font, _tutorial_skip_rect.position + Vector2(0, 58), "ПРОПУСТИТЬ", HORIZONTAL_ALIGNMENT_CENTER, _tutorial_skip_rect.size.x, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_TEXT)
		draw_string(font, Vector2(64, 1070 + _layout_extra * 0.68), _tutorial_instruction_for_display(), HORIZONTAL_ALIGNMENT_LEFT, 460, ResponsiveLayoutScript.font_size(16, _ui_scale), COLOR_TEXT)
	else:
		_restart_rect = Rect2(action_x, panel.position.y + 12, action_width, action_height)
		draw_rect(_restart_rect, COLOR_PANEL_LIGHT)
		draw_string(font, _restart_rect.position + Vector2(0, 56), "ЗАНОВО", HORIZONTAL_ALIGNMENT_CENTER, _restart_rect.size.x, ResponsiveLayoutScript.font_size(16, _ui_scale), COLOR_TEXT)
		draw_string(font, Vector2(64, 1070 + _layout_extra * 0.68), _status_for_display(), HORIZONTAL_ALIGNMENT_LEFT, 460, ResponsiveLayoutScript.font_size(17, _ui_scale), COLOR_TEXT)
	var delivered := _colony.delivered_resources
	draw_string(font, Vector2(64, 1110 + _layout_extra * 0.68), "ДОСТАВЛЕНО  %d / %d" % [delivered, _board.total_resources], HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)


func _draw_level_picker(font: Font) -> void:
	var page_count := maxi(1, ceili(float(_campaign_levels.size()) / float(_levels_per_page())))
	var page_number := int(_level_page_start / _levels_per_page()) + 1
	var completed_count: int = 0
	if _progress_store != null:
		completed_count = int(_progress_store.get_completed_count())
	draw_string(font, Vector2(44, 1148 + _layout_extra * 0.86), "УРОВНИ  ·  СТР. %02d / %02d  ·  ПРОЙДЕНО %02d / %03d" % [page_number, page_count, completed_count, _campaign_levels.size()], HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)
	_level_rects.clear()

	var button_width := _level_button_size()
	var button_gap := 4.0
	var page_width := _levels_per_page() * button_width + (_levels_per_page() - 1) * button_gap
	var arrow_width := _level_button_size()
	var controls_width := arrow_width + 8.0 + page_width + 8.0 + arrow_width
	var controls_start_x := (720.0 - controls_width) * 0.5

	_previous_page_rect = Rect2(controls_start_x, 1160 + _layout_extra * 0.86, arrow_width, _level_button_size())
	draw_rect(_previous_page_rect, COLOR_PANEL if _level_page_start > 0 else COLOR_BG)
	draw_string(font, _previous_page_rect.position + Vector2(0, 56), "<", HORIZONTAL_ALIGNMENT_CENTER, arrow_width, ResponsiveLayoutScript.font_size(20, _ui_scale), COLOR_TEXT if _level_page_start > 0 else COLOR_GRID)

	var buttons_start_x := controls_start_x + arrow_width + 8.0
	var visible_count := mini(_levels_per_page(), maxi(0, _campaign_levels.size() - _level_page_start))
	for local_index in range(visible_count):
		var global_index := _level_page_start + local_index
		var rect := Rect2(buttons_start_x + local_index * (button_width + button_gap), 1160 + _layout_extra * 0.86, button_width, _level_button_size())
		_level_rects.append(rect)
		var is_selected := global_index == _level_index
		draw_rect(rect, COLOR_GOLD if is_selected else COLOR_PANEL)
		var label_color := COLOR_BG if is_selected else COLOR_TEXT
		draw_string(font, rect.position + Vector2(0, 52), "%03d" % (global_index + 1), HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, ResponsiveLayoutScript.font_size(15, _ui_scale), label_color)
		if _progress_store != null and _progress_store.is_level_completed(String(_campaign_levels[global_index]["id"])):
			draw_circle(rect.position + Vector2(rect.size.x - 7.0, 7.0), 3.0, COLOR_GOLD)

	var next_x := buttons_start_x + page_width + 8.0
	_next_page_rect = Rect2(next_x, 1160 + _layout_extra * 0.86, arrow_width, _level_button_size())
	var has_next_page := _level_page_start + _levels_per_page() < _campaign_levels.size()
	draw_rect(_next_page_rect, COLOR_PANEL if has_next_page else COLOR_BG)
	draw_string(font, _next_page_rect.position + Vector2(0, 56), ">", HORIZONTAL_ALIGNMENT_CENTER, arrow_width, ResponsiveLayoutScript.font_size(20, _ui_scale), COLOR_TEXT if has_next_page else COLOR_GRID)

	if ResponsiveLayoutScript.show_footer(_ui_scale):
		draw_string(font, Vector2(0, 1264 + _layout_extra * 0.95), "ОДНА КОЛОНИЯ  ·  МНОЖЕСТВО РЕШЕНИЙ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)


func _levels_per_page() -> int:
	return ResponsiveLayoutScript.levels_per_page(_ui_scale)


func _level_button_size() -> float:
	return ResponsiveLayoutScript.level_button_size(_ui_scale)


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
	if _previous_page_rect.has_point(point) and _level_page_start > 0:
		_level_page_start = maxi(0, _level_page_start - _levels_per_page())
		queue_redraw()
		return
	if _next_page_rect.has_point(point) and _level_page_start + _levels_per_page() < _campaign_levels.size():
		_level_page_start += _levels_per_page()
		queue_redraw()
		return
	for index in range(_level_rects.size()):
		if _level_rects[index].has_point(point):
			_load_level(_level_page_start + index)
			return
	if _restart_rect.has_point(point):
		_load_level(_level_index)
		return
	if _tutorial_active and _tutorial_skip_rect.has_point(point):
		_complete_tutorial()
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
	if _campaign_levels.is_empty():
		_status = "Нет доступных уровней."
		queue_redraw()
		return
	_level_index = clampi(index, 0, _campaign_levels.size() - 1)
	_level_page_start = int(_level_index / _levels_per_page()) * _levels_per_page()
	_tutorial_active = _level_index == 0 and _progress_store != null and not _progress_store.is_tutorial_completed()
	_tutorial_step = 0 if _tutorial_active else -1
	_level_data = _campaign_levels[_level_index]["data"].duplicate(true)
	var result: Dictionary = LevelLoaderScript.load_into(_level_data, _board, _colony)
	_selected_squad_id = ""
	_last_path.clear()
	_last_target = Vector2i(-1, -1)
	_last_path_start = _board.start
	_status = "Выберите отряд, чтобы начать." if result["valid"] else _error_ru(str(result["errors"]))
	if result["valid"] and _progress_store != null:
		var save_result: Dictionary = _progress_store.set_last_selected_level(String(_campaign_levels[_level_index]["id"]))
		if not save_result.get("valid", false):
			_progress_warning = _error_ru(String(save_result.get("warning", "Не удалось сохранить прогресс.")))
	if result["valid"] and not _progress_warning.is_empty():
		_status = "Примечание к прогрессу: " + _progress_warning
	queue_redraw()


func _select_or_deploy(squad_id: String) -> void:
	var squad: Dictionary = _colony.get_squad(squad_id)
	if squad.is_empty():
		return
	_selected_squad_id = squad_id
	_last_path.clear()
	if squad["deployed"]:
		_status = "%s в поле. Выберите семя своего цвета или муравейник." % _color_name_ru(String(squad.get("color", "")))
	else:
		var result: Dictionary = _colony.deploy_squad(squad_id)
		if result["valid"]:
			_status = "%s отправлен. Выберите семя своего цвета." % squad_id.replace("_", " ")
			if _tutorial_active and squad_id == "amber_workers":
				_tutorial_step = 1
		else:
			_status = _error_ru(String(result["errors"][0]))
	queue_redraw()


func _collect_selected_squad(cell: Vector2i) -> void:
	if _selected_squad_id.is_empty():
		_status = "Сначала выберите отряд рабочих."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad["deployed"]:
		_status = "Сначала отправьте выбранный отряд в поле."
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
	_status = "Рабочие идут по тропе…"
	_start_path_animation(1.0, false)
	queue_redraw()


func _return_selected_squad() -> void:
	if _selected_squad_id.is_empty():
		_status = "Выберите отряд в поле, чтобы вернуть его домой."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad["deployed"]:
		_status = "Выбранный отряд сейчас не в поле."
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
	_status = "Рабочие возвращаются домой…"
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
			if _tutorial_active and _tutorial_step == 1 and _last_target == Vector2i(4, 2):
				_tutorial_step = 2
			var squad: Dictionary = _colony.get_squad(_selected_squad_id)
			if squad.get("несут", 0) >= squad.get("capacity", 1):
				_status = "Отряд загружен. Нажмите на муравейник, чтобы доставить груз."
			else:
				_status = "Семя собрано. Найдите ещё одно подходящего цвета или возвращайтесь домой."
		_check_terminal_state()
	queue_redraw()


func _finish_squad_return() -> void:
	var result: Dictionary = _colony.return_squad(_selected_squad_id)
	if result["valid"]:
		_status = "Доставлено семян: %d. Место для отряда свободно." % result["delivered"]
		if _tutorial_active and _tutorial_step == 2 and result["delivered"] > 0:
			_complete_tutorial()
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
	draw_circle(center + Vector2(1, 7) * body_scale, 12.0 * scale, Color("#101812", 0.72))
	draw_circle(center + Vector2(-7, 0) * body_scale, 5.5 * scale, Color("#251d16"))
	draw_circle(center + Vector2(1, 0) * body_scale, 7.0 * scale, tint)
	draw_circle(center + Vector2(10, -1) * body_scale, 4.5 * scale, Color("#251d16"))
	draw_arc(center + Vector2(1, 0) * body_scale, 5.5 * scale, PI * 1.08, PI * 1.82, 12, tint.lightened(0.3), 1.5 * scale)
	draw_circle(center + Vector2(11, -2) * body_scale, 1.1 * scale, Color("#fff1c9"))
	draw_line(center + Vector2(12, -4) * body_scale, center + Vector2(16, -9) * body_scale, Color("#251d16"), 1.4 * scale)
	draw_line(center + Vector2(12, 1) * body_scale, center + Vector2(18, 0) * body_scale, Color("#251d16"), 1.4 * scale)
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
		var level_id := String(_campaign_levels[_level_index]["id"])
		if _progress_store != null and not _progress_store.is_level_completed(level_id):
			var save_result: Dictionary = _progress_store.mark_level_completed(level_id)
			if not save_result.get("valid", false):
				_progress_warning = String(save_result.get("warning", "Не удалось сохранить прогресс."))
		_status = "Победа! Все семена доставлены домой."
		if not _progress_warning.is_empty():
			_status += "  " + _progress_warning
	elif TurnResolverScript.is_level_blocked(_board, _colony):
		_status = "Ни один отряд не может добраться до оставшихся семян. Попробуйте снова."


func _tutorial_instruction() -> String:
	match _tutorial_step:
		0:
			return "1 / 3  Нажмите на карточку янтарного отряда, чтобы отправить его в поле."
		1:
			return "2 / 3  Нажмите на янтарное семя на дальней стороне поля."
		2:
			return "3 / 3  Нажмите на муравейник, чтобы доставить семя домой."
	return "Выполните шаги, чтобы завершить первую экспедицию."


func _tutorial_instruction_for_display() -> String:
	if _ui_scale >= 0.48:
		return _tutorial_instruction()
	match _tutorial_step:
		0:
			return "1 / 3  Отправьте ЯНТАРНЫЙ отряд."
		1:
			return "2 / 3  Соберите янтарное семя."
		2:
			return "3 / 3  Вернитесь в муравейник."
	return "Выполните все шаги."


func _status_for_display() -> String:
	if _ui_scale >= 0.48:
		return _status
	if _status.begins_with("Груз собран"):
		return "Груз собран. Нажмите на муравейник."
	if _status.begins_with("Семя собрано"):
		return "Семя собрано. Продолжайте сбор или возвращайтесь."
	if _status.begins_with("Доставлено семян:"):
		return _status
	if _status.begins_with("Победа!"):
		return "Победа! Все семена дома."
	if _status.begins_with("Ни один отряд"):
		return "Пути нет. Начните заново."
	if _status.length() > 38:
		return _status.left(35).strip_edges() + "…"
	return _status


func _complete_tutorial() -> void:
	if not _tutorial_active:
		return
	_tutorial_active = false
	_tutorial_step = -1
	if _progress_store != null:
		var save_result: Dictionary = _progress_store.mark_tutorial_completed()
		if not save_result.get("valid", false):
			_progress_warning = String(save_result.get("warning", "Не удалось сохранить завершение обучения."))
			_status = _progress_warning
		else:
			_status = "Первая экспедиция завершена. Колония готова!"
	queue_redraw()

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
			return _color_name_ru(String(_colony.get_squad(squad_id).get("color", "")))
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
			return "Я"
		"teal":
			return "Б"
		"coral":
			return "К"
		"violet":
			return "Ф"
	return "?"


func _draw_nest(center: Vector2) -> void:
	# Layered earthen nest entrance with a warm rim and a readable dark opening.
	draw_circle(center, 25.0, Color("#6c5738"))
	draw_circle(center, 20.0, Color("#b28a4d"))
	draw_circle(center, 14.0, Color("#493b2b"))
	draw_arc(center + Vector2(-1, -2), 18.0, PI * 1.08, PI * 1.9, 20, Color("#d6b36d"), 2.0)
	draw_arc(center, 23.0, PI * 0.12, PI * 0.88, 24, Color("#e2c27c"), 2.5)
	draw_circle(center + Vector2(0, 1), 7.0, Color("#211f18"))
	draw_circle(center + Vector2(-2, -3), 2.0, Color("#d9b76e"))


func _draw_resource(center: Vector2, color_name: String) -> void:
	# Distinct seed body plus a small leaf; color is reinforced by shape labels.
	var tint := _color_for(color_name)
	draw_circle(center + Vector2(1, 5), 21.0, Color("#111c15", 0.72))
	draw_circle(center, 18.0, tint.darkened(0.28))
	draw_circle(center + Vector2(-1, -2), 16.0, tint)
	draw_arc(center + Vector2(-1, -2), 13.0, PI * 1.05, PI * 1.85, 18, tint.lightened(0.34), 2.0)
	draw_circle(center + Vector2(-6, -7), 5.0, Color(1.0, 1.0, 1.0, 0.48))
	draw_circle(center + Vector2(7, 5), 2.0, Color("#fff1c9", 0.62))
	draw_line(center + Vector2(5, -12), center + Vector2(12, -20), Color("#8fc28a"), 3.0)
	draw_string(ThemeDB.fallback_font, center + Vector2(-17, 26), _symbol_for(color_name), HORIZONTAL_ALIGNMENT_CENTER, 34, ResponsiveLayoutScript.font_size(11, _ui_scale), COLOR_BG)


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
	var variant := posmod(cell.x * 7 + cell.y * 11, 5)
	var tint := Color("#456247")
	var glint := Color("#78906a")
	# Layered soil grain and tiny clover/root marks give every tile its own surface.
	draw_circle(base + Vector2(10 + variant * 7, 13 + posmod(cell.y, 3) * 8), 1.6, Color("#17291f", 0.55))
	draw_circle(base + Vector2(49 - variant * 4, 48 - posmod(cell.x, 3) * 7), 1.2, Color("#81916a", 0.45))
	if variant == 0:
		var root := base + Vector2(12, 53)
		draw_line(root, root + Vector2(-3, -7), tint, 2.0)
		draw_line(root, root + Vector2(2, -10), tint, 2.0)
		draw_line(root, root + Vector2(7, -6), tint, 2.0)
		draw_circle(root + Vector2(2, -10), 1.7, glint)
	elif variant == 1:
		var root := base + Vector2(54, 14)
		draw_line(root, root + Vector2(-5, -6), tint, 2.0)
		draw_line(root, root + Vector2(1, -9), tint, 2.0)
		draw_line(root, root + Vector2(6, -5), tint, 2.0)
	elif variant == 2:
		draw_arc(base + Vector2(34, 36), 8.0, 0.2, 2.5, 12, Color("#58734f", 0.65), 1.4)
	else:
		draw_circle(base + Vector2(53, 53), 2.0, glint)
		draw_circle(base + Vector2(58, 48), 1.2, tint)


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
