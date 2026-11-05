class_name BoardModel
extends RefCounted
## Deterministic board state, level loading, resource collection, and shortest paths.
## Paths contain movement steps: the start cell is excluded and the goal is included.

const LevelDefinitionScript = preload("res://scripts/core/level_definition.gd")
const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

var width: int = 0
var height: int = 0
var level_id: String = ""
var start: Vector2i = Vector2i(-1, -1)
var goal: Vector2i = Vector2i(-1, -1)
var remaining_resources: int = 0
var _blocked: Dictionary = {}
var _resources: Dictionary = {}


func configure(board_width: int, board_height: int) -> void:
	width = maxi(0, board_width)
	height = maxi(0, board_height)
	level_id = ""
	start = Vector2i(-1, -1)
	goal = Vector2i(-1, -1)
	remaining_resources = 0
	_blocked.clear()
	_resources.clear()


func load_level(data: Dictionary) -> Dictionary:
	var validation: Dictionary = LevelDefinitionScript.validate(data)
	if not validation["valid"]:
		return {
			"valid": false,
			"errors": validation["errors"],
		}

	# Apply only after validation succeeds, so a malformed level cannot
	# partially overwrite the currently loaded board.
	configure(data["width"], data["height"])
	level_id = data["id"]
	start = Vector2i(data["start"][0], data["start"][1])
	goal = Vector2i(data["goal"][0], data["goal"][1])

	for tile in data["tiles"]:
		var cell := Vector2i(tile["x"], tile["y"])
		match tile["type"]:
			"obstacle":
				_blocked[cell] = true
			"resource":
				_resources[cell] = tile["color"]

	remaining_resources = _resources.size()
	return {
		"valid": true,
		"errors": [],
	}


func set_blocked_cells(cells: Array[Vector2i]) -> void:
	_blocked.clear()
	for cell in cells:
		if is_inside(cell):
			_blocked[cell] = true


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func is_walkable(cell: Vector2i) -> bool:
	return is_inside(cell) and not _blocked.has(cell)


func has_resource(cell: Vector2i) -> bool:
	return _resources.has(cell)


func resource_color_at(cell: Vector2i) -> String:
	if not _resources.has(cell):
		return ""
	return _resources[cell]


func collect_resource(cell: Vector2i, expected_color: String = "") -> bool:
	if not is_inside(cell) or not _resources.has(cell):
		return false
	if not expected_color.is_empty() and _resources[cell] != expected_color:
		return false
	_resources.erase(cell)
	remaining_resources -= 1
	return true


func find_path(start_cell: Vector2i, goal_cell: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if not is_walkable(start_cell) or not is_walkable(goal_cell):
		return empty_path
	if start_cell == goal_cell:
		return empty_path

	var frontier: Array[Vector2i] = [start_cell]
	var frontier_index := 0
	var came_from: Dictionary = {start_cell: start_cell}

	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1

		if current == goal_cell:
			break

		for direction in DIRECTIONS:
			var next_cell: Vector2i = current + direction
			if not is_walkable(next_cell) or came_from.has(next_cell):
				continue
			came_from[next_cell] = current
			frontier.append(next_cell)

	if not came_from.has(goal_cell):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = goal_cell
	while cursor != start_cell:
		path.push_front(cursor)
		cursor = came_from[cursor]
	return path
