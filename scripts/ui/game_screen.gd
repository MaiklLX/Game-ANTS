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
const StrategicTurnEngineScript = preload("res://scripts/core/strategic_turn_engine.gd")
const SettingsStoreScript = preload("res://scripts/core/settings_store.gd")

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
var _strategic_engine: StrategicTurnEngine
var _turn_animation_progress: float = 1.0
var _turn_animation_moves: Dictionary = {}
var _turn_animation_tween: Tween
var _auto_run_timer: Timer
var _auto_run_active: bool = false
var _level_data: Dictionary = {}
var _level_index: int = 0
var _level_page_start: int = 0
var _campaign_levels: Array[Dictionary] = []
var _ru_localization: Dictionary = {}
var _progress_store
var _settings_store
var _settings: Dictionary = {"reduced_motion": false, "haptics_enabled": true}
var _settings_warning: String = ""
var _app_screen: String = "menu"
var _settings_return_screen: String = "menu"
var _chapter_rects: Array[Rect2] = []
var _chapter_records: Array[Dictionary] = []
var _menu_continue_rect := Rect2()
var _menu_new_rect := Rect2()
var _menu_chapters_rect := Rect2()
var _menu_settings_rect := Rect2()
var _settings_motion_rect := Rect2()
var _settings_haptics_rect := Rect2()
var _settings_back_rect := Rect2()
var _chapters_back_rect := Rect2()
var _pause_continue_rect := Rect2()
var _pause_restart_rect := Rect2()
var _pause_settings_rect := Rect2()
var _pause_menu_rect := Rect2()
var _result_next_rect := Rect2()
var _result_retry_rect := Rect2()
var _result_menu_rect := Rect2()
var _result_undo_rect := Rect2()
var _undo_rect := Rect2()
var _undo_snapshot: Dictionary = {}
var _pause_rect := Rect2()
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
var _feedback_kind: String = "harvest"
var _feedback_tween: Tween
var _is_animating: bool = false
var _auto_dispatch: bool = false
var _ant_wiggle: float = 0.0
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
	if OS.get_name() == "Android":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_auto_run_timer = Timer.new()
	_auto_run_timer.wait_time = 0.38
	_auto_run_timer.one_shot = false
	_auto_run_timer.timeout.connect(_on_auto_run_tick)
	add_child(_auto_run_timer)
	_load_ru_localization()
	_settings_store = SettingsStoreScript.new()
	var settings_result: Dictionary = _settings_store.load_settings()
	_settings = _settings_store.get_settings()
	_settings_warning = String(settings_result.get("warning", ""))
	_board = BoardModelScript.new()
	_colony = ColonyModelScript.new()
	_strategic_engine = StrategicTurnEngineScript.new()
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
		_progress_warning = _error_ru(String(progress_result.get("warning", "Не удалось загрузить прогресс.")))
	else:
		_progress_warning = _error_ru(String(progress_result.get("warning", "")))
	var initial_index := 0
	var saved_level_id: String = _progress_store.get_last_selected_level_id()
	for index in range(_campaign_levels.size()):
		if String(_campaign_levels[index]["id"]) == saved_level_id:
			initial_index = index
			break
	_load_level(initial_index)
	_app_screen = "menu"
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		if _app_screen == "game" and _has_active_orders():
			_stop_auto_run()
			_app_screen = "pause"
			_status = "Экспедиция остановлена: приложение было свёрнуто."
			queue_redraw()


func _process(delta: float) -> void:
	if (_is_animating or _turn_animation_progress < 1.0) and not bool(_settings.get("reduced_motion", false)):
		_ant_wiggle += delta * 13.0
	if _is_animating or _turn_animation_progress < 1.0 or _feedback_progress < 1.0:
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
	if _app_screen == "menu":
		_draw_main_menu(font)
	elif _app_screen == "chapters":
		_draw_chapters_screen(font)
	elif _app_screen == "settings":
		_draw_settings_screen(font)
	else:
		_draw_header(font)
		_draw_slots(font)
		_draw_squads(font)
		_draw_board(font)
		_draw_status(font)
		_draw_level_picker(font)
		if _app_screen == "pause":
			_draw_pause_overlay(font)
		elif _app_screen == "result":
			_draw_result_overlay(font)

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_main_menu(font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COLOR_BG)
	draw_circle(Vector2(360, 330), 190.0, Color("#1b3027"))
	draw_circle(Vector2(360, 330), 148.0, Color("#263d2f"))
	var menu_art_scale := _ui_scale * 2.5
	draw_set_transform(_ui_offset + Vector2(360, 330) * _ui_scale, 0.0, Vector2(menu_art_scale, menu_art_scale))
	_draw_nest(Vector2.ZERO)
	_draw_ant(Vector2(-48, -18), COLOR_AMBER, 1.2)
	_draw_ant(Vector2(54, 24), COLOR_TEAL, 1.0)
	draw_set_transform(_ui_offset, 0.0, Vector2(_ui_scale, _ui_scale))
	draw_string(font, Vector2(0, 590), "МУРАВЬИШКИ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(46, _ui_scale), COLOR_GOLD)
	draw_string(font, Vector2(0, 634), "МАЛЕНЬКАЯ КОЛОНИЯ  ·  БОЛЬШИЕ ПРИКЛЮЧЕНИЯ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	var button_width := 440.0
	var button_height := ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 88.0)
	var button_gap := 14.0
	var button_x := (720.0 - button_width) * 0.5
	var button_y := 700.0
	_menu_continue_rect = Rect2(button_x, button_y, button_width, button_height)
	_menu_new_rect = Rect2(button_x, button_y + button_height + button_gap, button_width, button_height)
	_menu_chapters_rect = Rect2(button_x, button_y + (button_height + button_gap) * 2.0, button_width, button_height)
	_menu_settings_rect = Rect2(button_x, button_y + (button_height + button_gap) * 3.0, button_width, button_height)
	_draw_shell_button(font, _menu_continue_rect, "ПРОДОЛЖИТЬ", true)
	_draw_shell_button(font, _menu_new_rect, "НАЧАТЬ СНАЧАЛА")
	_draw_shell_button(font, _menu_chapters_rect, "ГЛАВЫ КАМПАНИИ")
	_draw_shell_button(font, _menu_settings_rect, "НАСТРОЙКИ")
	draw_string(font, Vector2(0, 1192), "ИГРА РАБОТАЕТ ОФЛАЙН  ·  ПРОГРЕСС СОХРАНЯЕТСЯ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)


func _draw_chapters_screen(font: Font) -> void:
	draw_string(font, Vector2(44, 100), "ПУТЕШЕСТВИЕ КОЛОНИИ", HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(30, _ui_scale), COLOR_GOLD)
	draw_string(font, Vector2(44, 138), "Выберите место для следующей экспедиции", HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(15, _ui_scale), COLOR_MUTED)
	_chapter_rects.clear()
	_chapter_records.clear()
	for record in _campaign_levels:
		var chapter_id := String(record.get("chapter_id", ""))
		var chapter_index := -1
		for existing_index in range(_chapter_records.size()):
			if String(_chapter_records[existing_index].get("id", "")) == chapter_id:
				chapter_index = existing_index
				break
		if chapter_index < 0:
			_chapter_records.append({
				"id": chapter_id,
				"title": String(record.get("chapter_title", chapter_id)),
				"first": int(record.get("global_index", 0)),
				"count": 1,
			})
		else:
			_chapter_records[chapter_index]["count"] = int(_chapter_records[chapter_index]["count"]) + 1
	var y := 220.0
	for chapter in _chapter_records:
		var rect := Rect2(44, y, 632, 170)
		_chapter_rects.append(rect)
		draw_rect(rect, COLOR_PANEL)
		draw_rect(Rect2(rect.position, Vector2(6, rect.size.y)), _chapter_color(_chapter_rects.size() - 1))
		draw_string(font, rect.position + Vector2(28, 48), _chapter_title_ru(String(chapter["title"])), HORIZONTAL_ALIGNMENT_LEFT, 570, ResponsiveLayoutScript.font_size(22, _ui_scale), COLOR_TEXT)
		draw_string(font, rect.position + Vector2(28, 84), "%d УРОВНЕЙ  ·  НАЧАТЬ С %03d" % [int(chapter["count"]), int(chapter["first"]) + 1], HORIZONTAL_ALIGNMENT_LEFT, 560, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
		draw_string(font, rect.position + Vector2(28, 132), "ОТКРЫТЬ ГЛАВУ  →", HORIZONTAL_ALIGNMENT_LEFT, 560, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_GOLD)
		y += 190.0
	_chapters_back_rect = Rect2(44, 1120, 260, ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 88.0))
	_draw_shell_button(font, _chapters_back_rect, "НАЗАД")


func _draw_settings_screen(font: Font) -> void:
	draw_string(font, Vector2(44, 100), "НАСТРОЙКИ", HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(34, _ui_scale), COLOR_GOLD)
	draw_string(font, Vector2(44, 142), "Комфорт управления и движения", HORIZONTAL_ALIGNMENT_LEFT, 630, ResponsiveLayoutScript.font_size(15, _ui_scale), COLOR_MUTED)
	_settings_motion_rect = Rect2(44, 250, 632, 112)
	_settings_haptics_rect = Rect2(44, 386, 632, 112)
	draw_rect(_settings_motion_rect, COLOR_PANEL)
	draw_rect(_settings_haptics_rect, COLOR_PANEL)
	draw_string(font, Vector2(72, 294), "УМЕНЬШИТЬ АНИМАЦИЮ", HORIZONTAL_ALIGNMENT_LEFT, 430, ResponsiveLayoutScript.font_size(18, _ui_scale), COLOR_TEXT)
	draw_string(font, Vector2(72, 326), "Более короткие и спокойные переходы", HORIZONTAL_ALIGNMENT_LEFT, 450, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	draw_string(font, Vector2(610, 318), "ВКЛ" if bool(_settings.get("reduced_motion", false)) else "ВЫКЛ", HORIZONTAL_ALIGNMENT_RIGHT, 44, ResponsiveLayoutScript.font_size(15, _ui_scale), COLOR_GOLD)
	draw_string(font, Vector2(72, 430), "ТАКТИЛЬНЫЙ ОТКЛИК", HORIZONTAL_ALIGNMENT_LEFT, 430, ResponsiveLayoutScript.font_size(18, _ui_scale), COLOR_TEXT)
	draw_string(font, Vector2(72, 462), "Лёгкая вибрация при важных действиях", HORIZONTAL_ALIGNMENT_LEFT, 450, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	draw_string(font, Vector2(610, 454), "ВКЛ" if bool(_settings.get("haptics_enabled", true)) else "ВЫКЛ", HORIZONTAL_ALIGNMENT_RIGHT, 44, ResponsiveLayoutScript.font_size(15, _ui_scale), COLOR_GOLD)
	if not _settings_warning.is_empty():
		draw_string(font, Vector2(48, 560), _settings_warning, HORIZONTAL_ALIGNMENT_LEFT, 620, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_CORAL)
	_settings_back_rect = Rect2(44, 1120, 260, ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 88.0))
	_draw_shell_button(font, _settings_back_rect, "НАЗАД")


func _draw_pause_overlay(font: Font) -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("#07100d", 0.78))
	draw_rect(Rect2(76, 330, 568, 620), COLOR_PANEL)
	draw_string(font, Vector2(0, 420), "ЭКСПЕДИЦИЯ НА ПАУЗЕ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(27, _ui_scale), COLOR_GOLD)
	draw_string(font, Vector2(0, 466), "Муравьишки ждут ваших приказов", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	var pause_button_height := ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 88.0)
	var pause_button_gap := 12.0
	var pause_button_y := 510.0
	_pause_continue_rect = Rect2(140, pause_button_y, 440, pause_button_height)
	_pause_restart_rect = Rect2(140, pause_button_y + pause_button_height + pause_button_gap, 440, pause_button_height)
	_pause_settings_rect = Rect2(140, pause_button_y + (pause_button_height + pause_button_gap) * 2.0, 440, pause_button_height)
	_pause_menu_rect = Rect2(140, pause_button_y + (pause_button_height + pause_button_gap) * 3.0, 440, pause_button_height)
	_draw_shell_button(font, _pause_continue_rect, "ПРОДОЛЖИТЬ", true)
	_draw_shell_button(font, _pause_restart_rect, "ПЕРЕЗАПУСТИТЬ УРОВЕНЬ")
	_draw_shell_button(font, _pause_settings_rect, "НАСТРОЙКИ")
	_draw_shell_button(font, _pause_menu_rect, "ГЛАВНОЕ МЕНЮ")


func _draw_result_overlay(font: Font) -> void:
	var won := _strategic_engine.get_outcome() == "won"
	draw_rect(Rect2(Vector2.ZERO, size), Color("#07100d", 0.82))
	draw_rect(Rect2(60, 220, 600, 860), COLOR_PANEL)
	draw_rect(Rect2(60, 220, 6, 860), COLOR_GOLD if won else COLOR_CORAL)
	if won:
		draw_circle(Vector2(360, 340), 72.0, Color("#e3bd70", 0.12))
		_draw_nest(Vector2(360, 340))
		draw_string(font, Vector2(0, 460), "УРА! ВСЕ СЕМЕНА ДОМА", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(25, _ui_scale), COLOR_GOLD)
		draw_string(font, Vector2(0, 500), "Колония справилась с экспедицией!", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	else:
		draw_string(font, Vector2(0, 450), "ДЕНЬ ЗАКОНЧИЛСЯ", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(28, _ui_scale), COLOR_CORAL)
		draw_string(font, Vector2(0, 492), "Попробуйте другой план экспедиции", HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
	draw_string(font, Vector2(0, 550), "ДОСТАВЛЕНО  %d / %d" % [_colony.delivered_resources, _board.total_resources], HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(18, _ui_scale), COLOR_TEXT)
	if won:
		draw_string(font, Vector2(0, 582), "ОСТАЛОСЬ ДНЕЙ  %d" % _strategic_engine.day_remaining, HORIZONTAL_ALIGNMENT_CENTER, 720, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	var button_height := ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 88.0)
	var button_gap := 8.0
	var button_y := 630.0 if not _undo_snapshot.is_empty() else 660.0
	_result_undo_rect = Rect2(140, button_y, 440, button_height) if not _undo_snapshot.is_empty() else Rect2()
	_result_next_rect = Rect2(140, button_y + (button_height + button_gap if not _undo_snapshot.is_empty() else 0.0), 440, button_height)
	_result_retry_rect = Rect2(140, _result_next_rect.position.y + button_height + button_gap, 440, button_height)
	_result_menu_rect = Rect2(140, _result_retry_rect.position.y + button_height + button_gap, 440, button_height)
	var next_label := "СЛЕДУЮЩИЙ УРОВЕНЬ" if _level_index + 1 < _campaign_levels.size() else "ВЫБРАТЬ ГЛАВУ"
	if not won:
		next_label = "ВЫБРАТЬ ДРУГОЙ УРОВЕНЬ"
	if not _undo_snapshot.is_empty():
		_draw_shell_button(font, _result_undo_rect, "ВЕРНУТЬ ПОСЛЕДНИЙ ХОД")
	_draw_shell_button(font, _result_next_rect, next_label, true)
	_draw_shell_button(font, _result_retry_rect, "ПОВТОРИТЬ УРОВЕНЬ")
	_draw_shell_button(font, _result_menu_rect, "ГЛАВНОЕ МЕНЮ")


func _handle_result_tap(point: Vector2) -> void:
	if not _undo_snapshot.is_empty() and _result_undo_rect.has_point(point):
		_undo_last_turn()
		return
	if _result_next_rect.has_point(point):
		if _strategic_engine.get_outcome() == "won" and _level_index + 1 < _campaign_levels.size():
			_load_level(_level_index + 1)
			_app_screen = "game"
		else:
			_app_screen = "chapters"
	elif _result_retry_rect.has_point(point):
		_load_level(_level_index)
		_app_screen = "game"
	elif _result_menu_rect.has_point(point):
		_app_screen = "menu"
	queue_redraw()


func _draw_shell_button(font: Font, rect: Rect2, label: String, primary: bool = false) -> void:
	draw_rect(rect, COLOR_GOLD if primary else COLOR_PANEL_LIGHT)
	draw_rect(Rect2(rect.position, Vector2(4, rect.size.y)), COLOR_AMBER if primary else COLOR_GRID)
	draw_string(font, rect.position + Vector2(0, rect.size.y * 0.62), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, ResponsiveLayoutScript.font_size(16, _ui_scale), COLOR_BG if primary else COLOR_TEXT)


func _chapter_color(index: int) -> Color:
	match index:
		0: return COLOR_TEAL
		1: return COLOR_AMBER
		2: return COLOR_CORAL
		_: return COLOR_VIOLET


func _handle_menu_tap(point: Vector2) -> void:
	if _menu_continue_rect.has_point(point):
		_app_screen = "game"
	elif _menu_new_rect.has_point(point):
		_load_level(0)
		_app_screen = "game"
	elif _menu_chapters_rect.has_point(point):
		_app_screen = "chapters"
	elif _menu_settings_rect.has_point(point):
		_settings_return_screen = "menu"
		_app_screen = "settings"
	queue_redraw()


func _handle_chapters_tap(point: Vector2) -> void:
	if _chapters_back_rect.has_point(point):
		_app_screen = "menu"
		queue_redraw()
		return
	for index in range(_chapter_rects.size()):
		if _chapter_rects[index].has_point(point):
			_load_level(int(_chapter_records[index].get("first", 0)))
			_app_screen = "game"
			queue_redraw()
			return


func _handle_settings_tap(point: Vector2) -> void:
	if _settings_motion_rect.has_point(point):
		var result: Dictionary = _settings_store.set_setting("reduced_motion", not bool(_settings.get("reduced_motion", false)))
		_settings = _settings_store.get_settings()
		_settings_warning = String(result.get("warning", ""))
	elif _settings_haptics_rect.has_point(point):
		var result: Dictionary = _settings_store.set_setting("haptics_enabled", not bool(_settings.get("haptics_enabled", true)))
		_settings = _settings_store.get_settings()
		_settings_warning = String(result.get("warning", ""))
	elif _settings_back_rect.has_point(point):
		_app_screen = _settings_return_screen
	queue_redraw()


func _handle_pause_tap(point: Vector2) -> void:
	if _pause_continue_rect.has_point(point):
		_app_screen = "game"
	elif _pause_restart_rect.has_point(point):
		_load_level(_level_index)
		_app_screen = "game"
	elif _pause_settings_rect.has_point(point):
		_settings_return_screen = "pause"
		_app_screen = "settings"
	elif _pause_menu_rect.has_point(point):
		_stop_auto_run()
		_app_screen = "menu"
	queue_redraw()


func _undo_last_turn() -> void:
	if _undo_snapshot.is_empty():
		_status = "Пока нечего отменять. Сначала завершите ход."
		queue_redraw()
		return
	var restore_result: Dictionary = _strategic_engine.restore_snapshot(_undo_snapshot, _colony, _board)
	if not restore_result.get("valid", false):
		_status = _error_ru(String(restore_result.get("errors", ["Не удалось отменить ход."])[0]))
		queue_redraw()
		return
	_undo_snapshot.clear()
	_is_animating = false
	_turn_animation_progress = 1.0
	_turn_animation_moves.clear()
	if _turn_animation_tween != null and _turn_animation_tween.is_running():
		_turn_animation_tween.kill()
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()
	_feedback_progress = 1.0
	_feedback_cell = Vector2i(-1, -1)
	_app_screen = "game"
	_status = "Последний ход отменён. Можно изменить приказы и попробовать иначе."
	_trigger_haptic(18)
	queue_redraw()


func _open_pause() -> void:
	_stop_auto_run()
	_app_screen = "pause"
	queue_redraw()


func _trigger_haptic(duration_ms: int) -> void:
	if not bool(_settings.get("haptics_enabled", true)):
		return
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		Input.vibrate_handheld(duration_ms)


func _draw_header(font: Font) -> void:
	draw_string(font, Vector2(42, 62), "МУРАВЬИШКИ", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(32, _ui_scale), COLOR_GOLD)
	var chapter_title := String(_campaign_levels[_level_index].get("chapter_title", "КАМПАНИЯ")) if not _campaign_levels.is_empty() else "ДАННЫЕ КАМПАНИИ"
	var chapter_label := _chapter_title_ru(chapter_title)
	if _ui_scale < 0.48 and chapter_label == "Сердце колонии: первый рассвет":
		chapter_label = "Сердце колонии"
	var chapter_subtitle := chapter_label if _ui_scale < 0.48 else "ПОЛЕВЫЕ ЗАМЕТКИ  /  " + chapter_label
	draw_string(font, Vector2(44, 91), chapter_subtitle, HORIZONTAL_ALIGNMENT_LEFT, 420, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_MUTED)
	var control_size := ResponsiveLayoutScript.minimum_touch_extent(_ui_scale, 64.0)
	_undo_rect = Rect2(720.0 - control_size * 2.0 - 30.0, 18.0, control_size, control_size)
	_pause_rect = Rect2(720.0 - control_size - 16.0, 18.0, control_size, control_size)
	draw_string(font, Vector2(330, 62), "%03d / %03d" % [_level_index + 1, _campaign_levels.size()], HORIZONTAL_ALIGNMENT_RIGHT, 138, ResponsiveLayoutScript.font_size(17, _ui_scale), COLOR_TEXT)
	draw_rect(_undo_rect, COLOR_PANEL_LIGHT if not _undo_snapshot.is_empty() else Color("#1a251f"))
	draw_string(font, _undo_rect.position + Vector2(0, control_size * 0.65), "↶", HORIZONTAL_ALIGNMENT_CENTER, _undo_rect.size.x, ResponsiveLayoutScript.font_size(24, _ui_scale), COLOR_GOLD if not _undo_snapshot.is_empty() else COLOR_GRID)
	draw_rect(_pause_rect, COLOR_PANEL_LIGHT)
	draw_string(font, _pause_rect.position + Vector2(0, control_size * 0.65), "Ⅱ", HORIZONTAL_ALIGNMENT_CENTER, _pause_rect.size.x, ResponsiveLayoutScript.font_size(22, _ui_scale), COLOR_TEXT)

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
	if objective.length() <= 56:
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
		"The level has already ended.":
			return "Экспедиция уже завершена."
		"Deploy the squad before assigning a target.":
			return "Сначала отправьте отряд в поле."
		"The squad's carrying capacity is full.":
			return "Отряд уже несёт полный груз."
		"Target must be reachable and different from the squad's current cell.":
			return "Выберите доступное семя на другой клетке."
		"Another squad already has an order for this resource.":
			return "Это семя уже назначено другому отряду."
		"Only a deployed squad can return.":
			return "Вернуть можно только отряд в поле."
		"The squad is already at the nest or the nest is unreachable.":
			return "Отряд уже у муравейника или путь домой закрыт."
		"Assign at least one squad order before ending the turn.":
			return "Сначала назначьте приказ хотя бы одному отряду."
	return value

func _draw_slots(font: Font) -> void:
	var occupied_slots := _colony.get_active_slot_count()
	var slot_summary := "МЕСТА ДЛЯ ОТРЯДОВ  ·  %d / %d ЗАНЯТО" % [occupied_slots, _colony.slot_capacity]
	draw_string(font, Vector2(44, 258 + _layout_extra * 0.08), slot_summary, HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
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
	draw_string(font, Vector2(44, 392 + _layout_extra * 0.18), "ВЫБЕРИТЕ ОТРЯД, ЗАТЕМ НАЗНАЧЬТЕ ЕМУ ЦЕЛЬ", HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), COLOR_MUTED)
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
		draw_string(font, rect.position + Vector2(54, 34), _color_name_short_ru(String(squad["color"])), HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(14, _ui_scale), squad_color)
		var state := "В ПОЛЕ" if squad["deployed"] else "ГОТОВ"
		if _strategic_engine != null and _strategic_engine.has_order(squad_id):
			var active_order: Dictionary = _strategic_engine.get_order(squad_id)
			state = "ВОЗВРАЩАЕТСЯ" if active_order.get("kind", "") == "return" else "ИДЁТ К ЦЕЛИ"
		var carried := int(squad["carried"])
		var capacity := int(squad["capacity"])
		var load_text := "%d/%d" % [carried, capacity]
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
	var resource_label := "СЕМЯН: %d" % _board.remaining_resources
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

	if _strategic_engine != null:
		for squad_id in _colony.get_squad_ids():
			var order: Dictionary = _strategic_engine.get_order(squad_id)
			var squad: Dictionary = _colony.get_squad(squad_id)
			if order.is_empty() or squad.is_empty():
				continue
			var route: Array = order.get("path", [])
			var previous: Vector2i = squad.get("position", _board.start)
			var is_return_route := String(order.get("kind", "")) == "return"
			var route_tint := _color_for(String(squad.get("color", "amber"))).lightened(0.25)
			for route_cell in route:
				_draw_route_segment(_cell_rect(previous).get_center(), _cell_rect(route_cell).get_center(), route_tint, is_return_route)
				previous = route_cell
			if not route.is_empty():
				draw_circle(_cell_rect(route.back()).get_center(), 5.0, _color_for(String(squad.get("color", "amber"))))
		for squad_id in _colony.get_squad_ids():
			var squad: Dictionary = _colony.get_squad(squad_id)
			if not squad.get("deployed", false):
				continue
			var ant_position: Vector2 = _cell_rect(squad.get("position", _board.start)).get_center()
			if _turn_animation_progress < 1.0 and _turn_animation_moves.has(squad_id):
				var move: Dictionary = _turn_animation_moves[squad_id]
				var from_pos: Vector2 = _cell_rect(move["from"]).get_center()
				var to_pos: Vector2 = _cell_rect(move["to"]).get_center()
				ant_position = from_pos.lerp(to_pos, _turn_animation_progress)
			_draw_ant(ant_position, _color_for(String(squad.get("color", "amber"))), 0.95)
			var carried := int(squad.get("carried", 0))
			if carried > 0:
				_draw_carried_load(ant_position, _color_for(String(squad.get("color", "amber"))), carried)
	# Strategic squads and routes are rendered from active turn orders above.

	if _board.is_inside(_feedback_cell) and _feedback_progress < 1.0:
		var pulse_color := COLOR_GOLD
		pulse_color.a = 1.0 - _feedback_progress
		var feedback_center := _cell_rect(_feedback_cell).get_center()
		if _feedback_kind == "delivery":
			draw_arc(feedback_center, 18.0 + _feedback_progress * 34.0, 0.0, TAU, 36, pulse_color, 3.5)
			draw_arc(feedback_center, 10.0 + _feedback_progress * 20.0, 0.0, TAU, 28, pulse_color.lightened(0.25), 2.0)
		else:
			draw_arc(feedback_center, 14.0 + _feedback_progress * 22.0, 0.0, TAU, 32, pulse_color, 3.0)
			for particle_index in range(6):
				var angle := TAU * float(particle_index) / 6.0
				var particle_distance := 7.0 + _feedback_progress * 27.0
				var particle := feedback_center + Vector2.RIGHT.rotated(angle) * particle_distance
				draw_circle(particle, 2.8 * (1.0 - _feedback_progress * 0.65), pulse_color)


func _draw_status(font: Font) -> void:
	var panel := Rect2(42, 1000 + _layout_extra * 0.68, 636, 124)
	var completed := _strategic_engine.get_outcome() == "won"
	var blocked := _strategic_engine.get_outcome() == "lost"
	var panel_color := Color("#20382d") if completed else Color("#392a26") if blocked else COLOR_PANEL
	var accent_color := Color("#91c99a") if completed else Color("#e58b70") if blocked else COLOR_GOLD
	draw_rect(panel, panel_color)
	draw_rect(Rect2(panel.position, Vector2(4, panel.size.y)), accent_color)

	var heading := "ЭКСПЕДИЦИЯ ЗАВЕРШЕНА" if completed else "ДЕНЬ ЗАКОНЧИЛСЯ" if blocked else "ПЕРВАЯ ЭКСПЕДИЦИЯ" if _tutorial_active else "ЖУРНАЛ КОЛОНИИ"
	draw_string(font, Vector2(64, 1035 + _layout_extra * 0.68), heading, HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(13, _ui_scale), accent_color if not _tutorial_active else COLOR_GOLD)
	var action_width := ResponsiveLayoutScript.status_action_width(_ui_scale)
	var action_height := ResponsiveLayoutScript.status_action_height(_ui_scale)
	var action_x := panel.position.x + panel.size.x - action_width - 24.0
	if _tutorial_active:
		_restart_rect = Rect2(action_x, panel.position.y + 12, action_width, action_height)
		_tutorial_skip_rect = _restart_rect
		draw_rect(_restart_rect, COLOR_PANEL_LIGHT)
		var tutorial_action := ("ПАУЗА" if _auto_run_active else ("СТАРТ" if _ui_scale < 0.48 else "ЗАПУСК")) if _has_active_orders() else ("ПРОПУСК" if _ui_scale < 0.48 else "ПРОПУСТИТЬ")
		draw_string(font, _restart_rect.position + Vector2(0, 58), tutorial_action, HORIZONTAL_ALIGNMENT_CENTER, _restart_rect.size.x, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_TEXT)
		draw_string(font, Vector2(64, 1070 + _layout_extra * 0.68), _tutorial_instruction_for_display(), HORIZONTAL_ALIGNMENT_LEFT, 460, ResponsiveLayoutScript.font_size(16, _ui_scale), COLOR_TEXT)
	else:
		_restart_rect = Rect2(action_x, panel.position.y + 12, action_width, action_height)
		draw_rect(_restart_rect, COLOR_PANEL_LIGHT)
		draw_string(font, Vector2(64, 1070 + _layout_extra * 0.68), _status_for_display(), HORIZONTAL_ALIGNMENT_LEFT, 460, ResponsiveLayoutScript.font_size(17, _ui_scale), COLOR_TEXT)
		var action_label := ("ПАУЗА" if _auto_run_active else "ЗАПУСК") if _has_active_orders() else "ПОВТОРИТЬ" if blocked else "ДАЛЬШЕ" if completed and _level_index + 1 < _campaign_levels.size() else "ГЛАВЫ" if completed else "ВЫБЕРИТЕ ОТРЯД"
		if _ui_scale < 0.48:
			match action_label:
				"ЗАПУСК": action_label = "СТАРТ"
				"ПОВТОРИТЬ": action_label = "ЗАНОВО"
				"ДАЛЬШЕ": action_label = "ДАЛЕЕ"
				"ВЫБЕРИТЕ ОТРЯД": action_label = "ОТРЯД"
		draw_string(font, _restart_rect.position + Vector2(0, 56), action_label, HORIZONTAL_ALIGNMENT_CENTER, _restart_rect.size.x, ResponsiveLayoutScript.font_size(13, _ui_scale), COLOR_TEXT)
	var delivered := _colony.delivered_resources
	draw_string(font, Vector2(64, 1110 + _layout_extra * 0.68), "ДОСТАВЛЕНО  %d / %d     ДЕНЬ  %d / %d" % [delivered, _board.total_resources, _strategic_engine.day_remaining, _strategic_engine.day_limit], HORIZONTAL_ALIGNMENT_LEFT, -1, ResponsiveLayoutScript.font_size(12, _ui_scale), COLOR_MUTED)
 

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
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_ESCAPE or event.keycode == KEY_BACK):
		if _app_screen == "game":
			_open_pause()
			accept_event()
			return
		elif _app_screen == "pause":
			_app_screen = "game"
			queue_redraw()
			accept_event()
			return
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
	if _app_screen == "menu":
		_handle_menu_tap(point)
		return
	if _app_screen == "chapters":
		_handle_chapters_tap(point)
		return
	if _app_screen == "settings":
		_handle_settings_tap(point)
		return
	if _app_screen == "pause":
		_handle_pause_tap(point)
		return
	if _app_screen == "result":
		_handle_result_tap(point)
		return
	if _undo_rect.has_point(point):
		if _is_animating:
			return
		_stop_auto_run()
		_undo_last_turn()
		return
	if _pause_rect.has_point(point):
		_open_pause()
		return
	if _auto_run_active and _restart_rect.has_point(point):
		_stop_auto_run()
		return
	if _is_animating:
		return
	if _auto_run_active:
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
		if _has_active_orders():
			if _auto_run_active:
				_stop_auto_run()
			else:
				_start_auto_run()
		elif _tutorial_active:
			_complete_tutorial()
		elif _strategic_engine.get_outcome() == "lost":
			_load_level(_level_index)
		elif _strategic_engine.get_outcome() == "won":
			if _level_index + 1 < _campaign_levels.size():
				_load_level(_level_index + 1)
			else:
				_app_screen = "chapters"
				queue_redraw()
		else:
			_status = "Выберите отряд и назначьте следующий приказ."
			queue_redraw()
		return
	if _tutorial_active and _tutorial_skip_rect.has_point(point):
		_complete_tutorial()
		return
	# Terminal fields accept only an explicit level change or retry.
	if _strategic_engine.get_outcome() != "playing":
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
	_stop_auto_run()
	if _animation_tween != null and _animation_tween.is_running():
		_animation_tween.kill()
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()
	_feedback_progress = 1.0
	_feedback_cell = Vector2i(-1, -1)
	_undo_snapshot.clear()
	_is_animating = false
	_returning_to_nest = false
	_ant_progress = 0.0
	_turn_animation_progress = 1.0
	_turn_animation_moves.clear()
	if _turn_animation_tween != null and _turn_animation_tween.is_running():
		_turn_animation_tween.kill()
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
	var day_budget := int(_level_data.get("day_budget", maxi(24, _board.width * _board.height)))
	_strategic_engine.configure(day_budget)
	_selected_squad_id = ""
	_last_path.clear()
	_last_target = Vector2i(-1, -1)
	_last_path_start = _board.start
	_status = "Выберите отряд, затем семя или муравейник. Нажмите «Следующий ход»." if result["valid"] else _error_ru(str(result["errors"]))
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
	var was_selected := _selected_squad_id == squad_id
	_selected_squad_id = squad_id
	if not squad.get("deployed", false):
		var result: Dictionary = _colony.deploy_squad(squad_id)
		if not result.get("valid", false):
			_status = _error_ru(String(result.get("errors", ["Не удалось отправить отряд."])[0]))
			queue_redraw()
			return
		_status = "%s отряд готов. Выберите подходящее семя." % _color_name_ru(String(squad.get("color", "")))
		_trigger_haptic(18)
		if _tutorial_active and _tutorial_step == 0 and squad_id == "amber_workers":
			_tutorial_step = 1
	else:
		var order: Dictionary = _strategic_engine.get_order(squad_id)
		if not order.is_empty() and was_selected:
			_strategic_engine.cancel_order(squad_id)
			_status = "Приказ отменён. Выберите новую цель или назначьте возвращение."
		elif not order.is_empty():
			_status = "Приказ активен: %d ход(а/ов). Повторное касание отменит приказ." % order.get("path", []).size()
		elif int(squad.get("carried", 0)) > 0:
			_status = "Отряд несёт груз. Коснитесь муравейника, чтобы назначить возвращение."
		else:
			_status = "Отряд выбран. Коснитесь доступного семени своего цвета."
	queue_redraw()


func _collect_selected_squad(cell: Vector2i) -> void:
	if _selected_squad_id.is_empty():
		_status = "Сначала выберите отряд рабочих."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad.get("deployed", false):
		_status = "Сначала выберите и отправьте отряд в поле."
		queue_redraw()
		return
	var result: Dictionary = _strategic_engine.set_collect_order(_colony, _board, _selected_squad_id, cell)
	if not result.get("valid", false):
		_status = _error_ru(String(result.get("errors", ["Нельзя назначить эту цель."])[0]))
	else:
		_trigger_haptic(12)
		_last_path_start = squad.get("position", _board.start)
		_last_target = cell
		_last_path = result.get("path", [])
		_status = "Маршрут назначен: %d ход(а/ов). Нажмите «Следующий ход»." % int(result.get("turn_cost", 0))
		if _tutorial_active and _tutorial_step == 1:
			_tutorial_step = 2
	queue_redraw()


func _return_selected_squad() -> void:
	if _selected_squad_id.is_empty():
		_status = "Выберите отряд в поле, затем коснитесь муравейника."
		queue_redraw()
		return
	var squad: Dictionary = _colony.get_squad(_selected_squad_id)
	if squad.is_empty() or not squad.get("deployed", false):
		_status = "Выбранный отряд ещё не находится в поле."
		queue_redraw()
		return
	var result: Dictionary = _strategic_engine.set_return_order(_colony, _board, _selected_squad_id)
	if not result.get("valid", false):
		_status = _error_ru(String(result.get("errors", ["Не удалось назначить возвращение."])[0]))
	else:
		_last_target = _board.start
		_status = "Возвращение назначено: %d ход(а/ов). Нажмите «Следующий ход»." % int(result.get("turn_cost", 0))
	queue_redraw()


func _has_active_orders() -> bool:
	if _strategic_engine == null or _colony == null:
		return false
	for squad_id in _colony.get_squad_ids():
		if _strategic_engine.has_order(squad_id):
			return true
	return false



func _start_auto_run() -> void:
	if not _has_active_orders() or _strategic_engine.get_outcome() != "playing":
		return
	_auto_run_active = true
	_status = "Экспедиция в пути. Нажмите «Пауза», чтобы остановить отряды."
	if _auto_run_timer != null:
		_auto_run_timer.start()
	queue_redraw()


func _stop_auto_run() -> void:
	_auto_run_active = false
	if _auto_run_timer != null:
		_auto_run_timer.stop()
	queue_redraw()


func _on_auto_run_tick() -> void:
	if not _auto_run_active:
		return
	if _is_animating:
		return
	if not _has_active_orders():
		_stop_auto_run()
		return
	_advance_strategic_turn()


func _advance_strategic_turn() -> void:
	if not _has_active_orders():
		_status = "Сначала назначьте приказ хотя бы одному отряду."
		queue_redraw()
		return
	var previous_positions: Dictionary = {}
	for squad_id in _colony.get_squad_ids():
		var squad: Dictionary = _colony.get_squad(squad_id)
		if squad.get("deployed", false):
			previous_positions[squad_id] = squad.get("position", _board.start)
	var undo_candidate: Dictionary = _strategic_engine.create_snapshot(_colony, _board)
	var result: Dictionary = _strategic_engine.advance_turn(_colony, _board)
	if not result.get("valid", false):
		_status = _error_ru(String(result.get("errors", ["Не удалось завершить ход."])[0]))
		queue_redraw()
		return
	_undo_snapshot = undo_candidate
	_turn_animation_moves.clear()
	for squad_id in result.get("moved", []):
		var squad_after: Dictionary = _colony.get_squad(String(squad_id))
		if squad_after.is_empty() or not squad_after.get("deployed", false):
			continue
		var old_cell: Vector2i = previous_positions.get(String(squad_id), squad_after.get("position", _board.start))
		var new_cell: Vector2i = squad_after.get("position", old_cell)
		_turn_animation_moves[String(squad_id)] = {"from": old_cell, "to": new_cell}
	_turn_animation_progress = 0.0 if not _turn_animation_moves.is_empty() else 1.0
	if _turn_animation_tween != null and _turn_animation_tween.is_running():
		_turn_animation_tween.kill()
	if _turn_animation_progress < 1.0:
		_is_animating = true
		_turn_animation_tween = create_tween()
		_turn_animation_tween.set_trans(Tween.TRANS_CUBIC)
		_turn_animation_tween.set_ease(Tween.EASE_OUT)
		var movement_duration := 0.12 if bool(_settings.get("reduced_motion", false)) else 0.34
		_turn_animation_tween.tween_property(self, "_turn_animation_progress", 1.0, movement_duration)
		_turn_animation_tween.finished.connect(_on_turn_animation_finished)
	else:
		_is_animating = false
		_turn_animation_moves.clear()
	# Give harvest and delivery a clear visual punctuation instead of silently changing counters.
	for collected_id in result.get("collected", []):
		var collected_squad: Dictionary = _colony.get_squad(String(collected_id))
		if not collected_squad.is_empty():
			_trigger_feedback(collected_squad.get("position", _board.start), "harvest")
			_trigger_haptic(24)
	for delivered_id in result.get("delivered", []):
		_trigger_feedback(_board.start, "delivery")
		_trigger_haptic(36)
	if _tutorial_active and not result.get("delivered", []).is_empty():
		_complete_tutorial()
	if result.get("outcome", "playing") != "playing" or not result.get("collected", []).is_empty() or not result.get("delivered", []).is_empty() or not result.get("blocked", []).is_empty():
		_stop_auto_run()
	if result.get("outcome", "playing") == "won":
		_status = "Победа! Все семена доставлены домой."
		_mark_level_completed()
		_app_screen = "result"
	elif result.get("outcome", "playing") == "lost":
		_status = "День закончился. Не хватило ходов — попробуйте другой план."
		_app_screen = "result"
	elif not result.get("collected", []).is_empty():
		_status = "Семя собрано. Отряд ждёт следующего приказа."
	elif not result.get("delivered", []).is_empty():
		_status = "Груз доставлен. Можно назначать новые приказы."
		if _tutorial_active and _tutorial_step == 2:
			_complete_tutorial()
	else:
		_status = "Ход %d. Осталось ходов дня: %d." % [int(result.get("turn", 0)), int(result.get("day_remaining", 0))]
	queue_redraw()


func _on_turn_animation_finished() -> void:
	_is_animating = false
	_turn_animation_moves.clear()
	queue_redraw()


func _mark_level_completed() -> void:
	var level_id := String(_campaign_levels[_level_index]["id"])
	if _progress_store != null and not _progress_store.is_level_completed(level_id):
		var save_result: Dictionary = _progress_store.mark_level_completed(level_id)
		if not save_result.get("valid", false):
			_progress_warning = String(save_result.get("warning", "Не удалось сохранить прогресс."))
	if _progress_store != null and _level_index + 1 < _campaign_levels.size():
		var next_level_id := String(_campaign_levels[_level_index + 1]["id"])
		var continue_result: Dictionary = _progress_store.set_last_selected_level(next_level_id)
		if not continue_result.get("valid", false):
			_progress_warning = String(continue_result.get("warning", "Не удалось сохранить следующий уровень."))


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


func _draw_route_segment(from_point: Vector2, to_point: Vector2, tint: Color, is_return_route: bool) -> void:
	if not is_return_route:
		draw_line(from_point, to_point, tint, 3.0)
		return
	# Return routes use a dashed trail so the player can read the expedition phase at a glance.
	var delta := to_point - from_point
	var distance := delta.length()
	if distance <= 0.1:
		return
	var direction := delta / distance
	var cursor := 0.0
	while cursor < distance:
		var dash_end := minf(cursor + 9.0, distance)
		draw_line(from_point + direction * cursor, from_point + direction * dash_end, tint.lightened(0.18), 3.5)
		cursor += 15.0


func _draw_carried_load(center: Vector2, tint: Color, carried: int) -> void:
	# Each seed is a distinct little payload rather than an abstract counter dot.
	for index in range(carried):
		var bob := sin(_ant_wiggle * 1.35 + float(index) * 0.8) * 1.8 if _is_animating else 0.0
		var seed_center := center + Vector2(13.0 + float(index) * 10.0, -14.0 + bob)
		draw_circle(seed_center + Vector2(1.0, 2.0), 6.0, Color("#101812", 0.7))
		draw_circle(seed_center, 5.2, tint.lightened(0.12))
		draw_arc(seed_center + Vector2(-0.5, -0.5), 3.8, PI * 1.08, PI * 1.82, 10, Color("#fff1c9", 0.85), 1.1)
		draw_line(seed_center + Vector2(1.0, -4.0), seed_center + Vector2(4.0, -8.0), Color("#9bc88b"), 1.5)


func _draw_ant(center: Vector2, tint: Color, scale: float = 1.0) -> void:
	# Three-part silhouette; the squad is animated as a short, readable formation.
	center.y += sin(_ant_wiggle + center.x * 0.035) * 1.8 * scale if _is_animating else 0.0
	var body_scale := Vector2.ONE * scale
	draw_circle(center + Vector2(1, 7) * body_scale, 12.0 * scale, Color("#101812", 0.72))
	draw_circle(center + Vector2(-7, 0) * body_scale, 5.5 * scale, Color("#251d16"))
	draw_circle(center + Vector2(1, 0) * body_scale, 7.0 * scale, tint)
	draw_circle(center + Vector2(10, -1) * body_scale, 4.5 * scale, Color("#251d16"))
	draw_arc(center + Vector2(1, 0) * body_scale, 5.5 * scale, PI * 1.08, PI * 1.82, 12, tint.lightened(0.3), 1.5 * scale)
	draw_circle(center + Vector2(11, -2) * body_scale, 1.1 * scale, Color("#fff1c9"))
	draw_line(center + Vector2(12, -4) * body_scale, center + Vector2(16, -9) * body_scale, Color("#251d16"), 1.4 * scale)
	draw_line(center + Vector2(12, 1) * body_scale, center + Vector2(18, 0) * body_scale, Color("#251d16"), 1.4 * scale)
	var leg_swing := sin(_ant_wiggle * 1.7) * 4.0 if _is_animating else 0.0
	var rear_upper := Vector2(-7, -10 + leg_swing) * body_scale
	var rear_lower := Vector2(-7, 10 - leg_swing) * body_scale
	var front_upper := Vector2(7, -10 - leg_swing) * body_scale
	var front_lower := Vector2(7, 10 + leg_swing) * body_scale
	draw_line(center + Vector2(-2, -4) * body_scale, center + rear_upper, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(-2, 4) * body_scale, center + rear_lower, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(4, -4) * body_scale, center + front_upper, Color("#251d16"), 2.0 * scale)
	draw_line(center + Vector2(4, 4) * body_scale, center + front_lower, Color("#251d16"), 2.0 * scale)


func _trigger_feedback(cell: Vector2i, kind: String = "harvest") -> void:
	_feedback_cell = cell
	_feedback_kind = kind
	_feedback_progress = 0.0
	if _feedback_tween != null and _feedback_tween.is_running():
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.set_trans(Tween.TRANS_CUBIC)
	_feedback_tween.set_ease(Tween.EASE_OUT)
	var feedback_duration := 0.24 if bool(_settings.get("reduced_motion", false)) else 0.46
	_feedback_tween.tween_property(self, "_feedback_progress", 1.0, feedback_duration)


func _selected_squad_color() -> Color:
	if _selected_squad_id.is_empty():
		return COLOR_GOLD
	var squad := _colony.get_squad(_selected_squad_id)
	if squad.is_empty():
		return COLOR_GOLD
	return _color_for(String(squad["color"]))


func _check_terminal_state() -> void:
	if _strategic_engine.get_outcome() == "won":
		_status = "Победа! Все семена доставлены домой."
	elif _strategic_engine.get_outcome() == "lost":
		_status = "День закончился. Попробуйте другой план."


func _tutorial_instruction() -> String:
	match _tutorial_step:
		0:
			return "1 / 3  Выберите карточку янтарного отряда."
		1:
			return "2 / 3  Выберите янтарное семя, чтобы назначить маршрут."
		2:
			return "3 / 3  Назначьте возвращение у муравейника и завершите ход."
	return "Выполните шаги, чтобы завершить первую экспедицию."


func _tutorial_instruction_for_display() -> String:
	if _ui_scale >= 0.48:
		return _tutorial_instruction()
	match _tutorial_step:
		0:
			return "1 / 3  Выберите ЯНТАРНЫЙ отряд."
		1:
			return "2 / 3  Коснитесь янтарного семени."
		2:
			return "3 / 3  Назначьте возврат и завершите ход."
	return "Выполните все шаги."


func _status_for_display() -> String:
	if _ui_scale >= 0.48:
		return _status
	if _status.begins_with("Выберите отряд, затем семя"):
		return "Выберите отряд и семя."
	if _status.begins_with("Выберите отряд в поле"):
		return "Выберите отряд для возвращения."
	if _status.begins_with("Отряд выбран"):
		return "Выберите семя своего цвета."
	if _status.begins_with("Маршрут назначен"):
		return "Маршрут готов. Запустите ход."
	if _status.begins_with("Последний ход отменён"):
		return "Ход отменён. Измените приказ."
	if _status.begins_with("Экспедиция в пути"):
		return "Экспедиция идёт. Пауза — справа."
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
			_progress_warning = _error_ru(String(save_result.get("warning", "Не удалось сохранить завершение обучения.")))
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



func _color_name_short_ru(color_name: String) -> String:
	match color_name:
		"amber":
			return "ЯНТАРЬ"
		"teal":
			return "БИРЮЗА"
		"coral":
			return "КОРАЛЛ"
		"violet":
			return "ФИОЛЕТ"
	return _color_name_ru(color_name)

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
	# Delivery briefly wakes the nest entrance; the effect sleeps between deliveries.
	var delivery_active := _feedback_kind == "delivery" and _feedback_cell == _board.start and _feedback_progress < 1.0
	var delivery_strength := 1.0 - _feedback_progress if delivery_active else 0.0
	if delivery_active:
		var entrance_glow := Color("#f2c978", 0.20 * delivery_strength)
		draw_circle(center, 31.0 + _feedback_progress * 7.0, entrance_glow)
		draw_arc(center, 29.0 + _feedback_progress * 5.0, 0.0, TAU, 36, Color("#f2c978", 0.72 * delivery_strength), 2.0)
	# Layered earthen nest entrance with a warm rim and a readable dark opening.
	draw_circle(center, 25.0, Color("#6c5738"))
	draw_circle(center, 20.0, Color("#b28a4d"))
	draw_circle(center, 14.0, Color("#493b2b"))
	draw_arc(center + Vector2(-1, -2), 18.0, PI * 1.08, PI * 1.9, 20, Color("#d6b36d"), 2.0)
	draw_arc(center, 23.0, PI * 0.12, PI * 0.88, 24, Color("#e2c27c"), 2.5)
	if delivery_active:
		var inner_glow := Color("#f5d58f", 0.62 * delivery_strength)
		draw_arc(center + Vector2(0, 1), 9.0 + _feedback_progress * 2.0, PI * 0.08, PI * 0.92, 20, inner_glow, 2.8)
		draw_circle(center + Vector2(-13.0 - _feedback_progress * 8.0, -7.0), 2.0 * delivery_strength, inner_glow)
		draw_circle(center + Vector2(13.0 + _feedback_progress * 8.0, -7.0), 2.0 * delivery_strength, inner_glow)
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
