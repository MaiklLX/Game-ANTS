extends RefCounted
## Deterministic pixel-board state for the continuous color-flow prototype.

const DEFAULT_PATTERN: Array[String] = [
	"....TTT...TTT.....",
	"...TTTTT.TTTTT....",
	"..TTTTTTTTTTTTT...",
	".TTTTTTTTTTTTTTT..",
	"TTTTTTTGTTTTTTTTT",
	"TTTTCCCTGTCCCTTTT",
	".TTTCCCTGCCCTTT..",
	"..TTTTTTGTTTTT...",
	"...TTTTTGTTTT....",
	"....TTTTGTTT.....",
	".....TTT.TTT......",
	"......T...T.......",
	"......T...T......."
]

const COLOR_VALUES := {
	"T": "teal",
	"C": "coral",
	"G": "gold"
}

var width: int = 0
var height: int = 0
var pixels: Dictionary = {}
var initial_counts: Dictionary = {}


func configure_default() -> void:
	pixels.clear()
	initial_counts = {"teal": 0, "coral": 0, "gold": 0}
	height = DEFAULT_PATTERN.size()
	width = DEFAULT_PATTERN[0].length()
	for y in range(height):
		var row: String = DEFAULT_PATTERN[y]
		for x in range(width):
			var symbol := row.substr(x, 1)
			if not COLOR_VALUES.has(symbol):
				continue
			var color: String = COLOR_VALUES[symbol]
			pixels[Vector2i(x, y)] = color
			initial_counts[color] = int(initial_counts[color]) + 1


func get_color_at(cell: Vector2i) -> String:
	return String(pixels.get(cell, ""))


func get_remaining_count(color: String = "") -> int:
	if color.is_empty():
		return pixels.size()
	var count := 0
	for value in pixels.values():
		if String(value) == color:
			count += 1
	return count


func get_cells_for_color(color: String) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in pixels.keys():
		if String(pixels[cell]) == color:
			result.append(cell)
	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.y == b.y:
			return a.x < b.x
		return a.y < b.y
	)
	return result


func clear_pixel(cell: Vector2i, ant_color: String) -> bool:
	if not pixels.has(cell):
		return false
	if String(pixels[cell]) != ant_color:
		return false
	pixels.erase(cell)
	return true


func is_complete() -> bool:
	return pixels.is_empty()
