extends SceneTree
## Guards responsive transforms and the minimum physical hit-area dimensions at common phone sizes.

const LayoutScript = preload("res://scripts/ui/responsive_layout.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	_check_viewport(Vector2(360, 800), 0.5, 320.0, "compact Android portrait")
	_check_viewport(Vector2(390, 844), 390.0 / 720.0, 278.1538, "standard iPhone portrait")
	_check_viewport(Vector2(412, 915), 412.0 / 720.0, 319.0291, "large Android portrait")
	_check_viewport(Vector2(720, 1280), 1.0, 0.0, "reference 9:16 viewport")
	_check_viewport(Vector2(480, 800), 480.0 / 720.0, 0.0, "short portrait viewport")

	var compact_scale := float(LayoutScript.calculate(Vector2(360, 800))["scale"])
	_check(LayoutScript.is_touch_target_usable(Vector2(196, 96), compact_scale), "squad cards must remain at least 44 px tall on compact phones")
	_check(LayoutScript.is_touch_target_usable(Vector2(106, 44), compact_scale), "tutorial skip must remain at least 44 px tall on compact phones")
	_check(not LayoutScript.is_touch_target_usable(Vector2(54, 84), compact_scale), "narrow level buttons must not be misreported as 44 px wide")
	_check(is_equal_approx(LayoutScript.shifted_y(1000.0, 320.0, 0.68), 1217.6), "status panel anchor must use its vertical expansion weight")

	_finish()


func _check_viewport(viewport: Vector2, expected_scale: float, expected_extra: float, label: String) -> void:
	var layout: Dictionary = LayoutScript.calculate(viewport)
	_check(is_equal_approx(float(layout["scale"]), expected_scale), label + ": unexpected scale")
	_check(is_equal_approx(float(layout["extra_height"]), expected_extra, 0.01), label + ": unexpected extra height")
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
