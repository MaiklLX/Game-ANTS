extends RefCounted
## Shared portrait viewport transform. Extra vertical room is consumed by the screen layout
## instead of shrinking the entire 720x1280 interface into a letterboxed rectangle.

const BASE_SIZE := Vector2(720.0, 1280.0)


static func safe_viewport_rect(viewport_size: Vector2, safe_area: Rect2i, screen_size: Vector2i) -> Rect2:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0 or screen_size.x <= 0 or screen_size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	var screen_rect := Rect2i(Vector2i.ZERO, screen_size)
	var clipped_safe_area := safe_area.intersection(screen_rect)
	if clipped_safe_area.size.x <= 0 or clipped_safe_area.size.y <= 0:
		return Rect2(Vector2.ZERO, viewport_size)
	var screen_scale := viewport_size / Vector2(screen_size)
	return Rect2(Vector2(clipped_safe_area.position) * screen_scale, Vector2(clipped_safe_area.size) * screen_scale)


static func calculate(viewport_size: Vector2) -> Dictionary:
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return {
			"scale": 1.0,
			"offset": Vector2.ZERO,
			"virtual_size": BASE_SIZE,
			"extra_height": 0.0,
		}
	var scale := minf(viewport_size.x / BASE_SIZE.x, viewport_size.y / BASE_SIZE.y)
	var virtual_size := viewport_size / scale
	var offset := Vector2((viewport_size.x - BASE_SIZE.x * scale) * 0.5, 0.0)
	return {
		"scale": scale,
		"offset": offset,
		"virtual_size": virtual_size,
		"extra_height": maxf(0.0, virtual_size.y - BASE_SIZE.y),
	}


static func shifted_y(base_y: float, extra_height: float, weight: float) -> float:
	return base_y + maxf(0.0, extra_height) * clampf(weight, 0.0, 1.0)


static func is_touch_target_usable(rect_size: Vector2, scale: float, minimum_pixels: float = 44.0) -> bool:
	if scale <= 0.0:
		return false
	return rect_size.x * scale >= minimum_pixels and rect_size.y * scale >= minimum_pixels


static func squad_card_width(squad_count: int) -> float:
	return 156.0 if squad_count >= 4 else 196.0


static func squad_card_gap(squad_count: int) -> float:
	return 8.0 if squad_count >= 4 else 14.0


static func squad_row_width(squad_count: int) -> float:
	if squad_count <= 0:
		return 0.0
	return squad_count * squad_card_width(squad_count) + (squad_count - 1) * squad_card_gap(squad_count)


static func levels_per_page(scale: float) -> int:
	return 4 if scale < 0.48 else 5


static func level_button_size(scale: float) -> float:
	return 100.0 if scale < 0.48 else 88.0


static func squad_card_height() -> float:
	return 100.0


static func status_action_height() -> float:
	return 100.0


static func level_controls_width(scale: float) -> float:
	var count := levels_per_page(scale)
	var button := level_button_size(scale)
	return count * button + (count - 1) * 4.0 + button * 2.0 + 16.0


static func font_size(base_size: int, scale: float, minimum_physical: float = 8.5) -> int:
	if scale <= 0.0:
		return base_size
	return maxi(base_size, ceili(minimum_physical / scale))


static func show_footer(scale: float) -> bool:
	return scale >= 0.48
