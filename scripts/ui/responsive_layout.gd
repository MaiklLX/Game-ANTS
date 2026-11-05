extends RefCounted
## Shared portrait viewport transform. Extra vertical room is consumed by the screen layout
## instead of shrinking the entire 720x1280 interface into a letterboxed rectangle.

const BASE_SIZE := Vector2(720.0, 1280.0)


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
