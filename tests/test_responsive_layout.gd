extends SceneTree
## Guards responsive transforms and the minimum physical hit-area dimensions at common phone sizes.

const LayoutScript = preload("res://scripts/ui/responsive_layout.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	_check_viewport(Vector2(360, 800), 0.5, 320.0, "compact Android portrait")
	_check_viewport(Vector2(390, 844), 390.0 / 720.0, 278.1538, "standard iPhone portrait")
	_check_viewport(Vector2(412, 915), 412.0 / 720.0, 319.0291, "large Android portrait")
	_check_viewport(Vector2(720, 1280), 1.0, 0.0, "reference 9:16 viewport")
	_check_viewport(Vector2(480, 800), 0.625, 0.0, "short portrait viewport")
	_check_viewport(Vector2(320, 568), 0.44375, 0.0, "extra-narrow compact portrait viewport")

	var compact_scale := float(LayoutScript.calculate(Vector2(360, 800))["scale"])
	var narrow_scale := float(LayoutScript.calculate(Vector2(320, 568))["scale"])
	_check(LayoutScript.levels_per_page(narrow_scale) == 4, "extra-narrow phones must show four level buttons per page")
	_check(LayoutScript.level_button_size(narrow_scale) == 100.0, "extra-narrow level buttons must grow to 100 logical px")
	_check(LayoutScript.level_controls_width(narrow_scale) <= 720.0, "extra-narrow level picker must fit the design width")
	_check(LayoutScript.level_controls_width(compact_scale) <= 720.0, "compact level picker must fit the design width")
	_check(LayoutScript.levels_per_page(compact_scale) == 5, "standard compact phones must retain five level buttons per page")
	_check(LayoutScript.font_size(12, narrow_scale) == 20, "extra-narrow phones must scale small labels up to a readable physical size")
	_check(LayoutScript.font_size(12, compact_scale) == 17, "compact phones must preserve small-label legibility")
	_check(LayoutScript.font_size(12, 1.0) == 12, "reference-size screens must retain authored typography")
	_check(not LayoutScript.show_footer(narrow_scale), "extra-narrow phones must hide the decorative footer to protect the level controls")
	_check(LayoutScript.show_footer(compact_scale), "standard compact phones must retain the decorative footer")
	_check(float(LayoutScript.font_size(12, narrow_scale)) * narrow_scale >= 8.5, "extra-narrow label text must meet the minimum physical size")
	_check(float(LayoutScript.font_size(12, compact_scale)) * compact_scale >= 8.5, "compact label text must meet the minimum physical size")
	_check(LayoutScript.is_touch_target_usable(Vector2(100, 100), narrow_scale), "extra-narrow level controls must remain at least 44 physical px")
	_check(LayoutScript.is_touch_target_usable(Vector2(106, LayoutScript.status_action_height()), narrow_scale), "status actions must remain usable on extra-narrow phones")
	_check(LayoutScript.is_touch_target_usable(Vector2(156, LayoutScript.squad_card_height()), narrow_scale), "squad cards must remain usable on extra-narrow phones")
	_check(LayoutScript.squad_row_width(4) <= 720.0, "four squad cards must fit the reference portrait width")
	_check(LayoutScript.is_touch_target_usable(Vector2(LayoutScript.squad_card_width(4), LayoutScript.squad_card_height()), compact_scale), "four-squad cards must retain a usable mobile hit area")
	_check(LayoutScript.is_touch_target_usable(Vector2(196, LayoutScript.squad_card_height()), compact_scale), "squad cards must remain at least 44 px tall on compact phones")
	_check(LayoutScript.is_touch_target_usable(Vector2(106, LayoutScript.status_action_height()), compact_scale), "tutorial skip must remain at least 44 px tall on compact phones")
	_check(LayoutScript.is_touch_target_usable(Vector2(88, 88), compact_scale), "level buttons must meet the 44 px target on compact phones")
	_check(absf(LayoutScript.shifted_y(1000.0, 320.0, 0.68) - 1217.6) <= 0.01, "status panel anchor must use its vertical expansion weight")

	_finish()


func _check_viewport(viewport: Vector2, expected_scale: float, expected_extra: float, label: String) -> void:
	var layout: Dictionary = LayoutScript.calculate(viewport)
	_check(is_equal_approx(float(layout["scale"]), expected_scale), label + ": unexpected scale")
	_check(absf(float(layout["extra_height"]) - expected_extra) <= 0.01, label + ": unexpected extra height")
	var virtual_size: Vector2 = layout["virtual_size"]
	_check(is_equal_approx(virtual_size.x * float(layout["scale"]), viewport.x), label + ": virtual width must map to viewport")
	_check(is_equal_approx(virtual_size.y * float(layout["scale"]), viewport.y), label + ": virtual height must map to viewport")


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("Responsive portrait layout contract tests passed.")
		quit(0)
		return
	for failure in _failures:
		push_error("Responsive portrait layout contract failed: " + failure)
	quit(1)
