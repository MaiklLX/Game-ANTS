class_name BoardModel
extends RefCounted
## Deterministic rectangular board and shortest-path search.
## Paths contain movement steps: the start cell is excluded and the goal is included.

const DIRECTIONS: Array[Vector2i] = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

var width: int = 0
var height: int = 0
var _blocked: Dictionary = {}


func configure(board_width: int, board_height: int) -> void:
	width = maxi(0, board_width)
	height = maxi(0, board_height)
	_blocked.clear()


func set_blocked_cells(cells: Array[Vector2i]) -> void:
	_blocked.clear()
	for cell in cells:
		if is_inside(cell):
			_blocked[cell] = true


func is_inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < width and cell.y < height


func is_walkable(cell: Vector2i) -> bool:
	return is_inside(cell) and not _blocked.has(cell)


func find_path(start: Vector2i, goal: Vector2i) -> Array[Vector2i]:
	var empty_path: Array[Vector2i] = []
	if not is_walkable(start) or not is_walkable(goal):
		return empty_path
	if start == goal:
		return empty_path

	var frontier: Array[Vector2i] = [start]
	var frontier_index := 0
	var came_from: Dictionary = {start: start}

	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1

		if current == goal:
			break

		for direction in DIRECTIONS:
			var next_cell: Vector2i = current + direction
			if not is_walkable(next_cell) or came_from.has(next_cell):
				continue
			came_from[next_cell] = current
			frontier.append(next_cell)

	if not came_from.has(goal):
		return empty_path

	var path: Array[Vector2i] = []
	var cursor: Vector2i = goal
	while cursor != start:
		path.push_front(cursor)
		cursor = came_from[cursor]
	return path
