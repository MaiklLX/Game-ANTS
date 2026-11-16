class_name LevelDefinition
extends RefCounted
## Validation for the versioned, JSON-backed campaign level format.

const CURRENT_SCHEMA_VERSION := 1
const MAX_BOARD_DIMENSION := 32
const VALID_TILE_TYPES := ["empty", "resource", "obstacle", "nest"]
const VALID_RESOURCE_COLORS := ["amber", "teal", "coral", "violet"]


static func validate(data: Dictionary) -> Dictionary:
	var errors: Array[String] = []

	var schema_version: Variant = data.get("schema_version")
	if not _is_integer_number(schema_version):
		errors.append("schema_version must be an integer.")
	elif int(schema_version) != CURRENT_SCHEMA_VERSION:
		errors.append("Unsupported schema_version: %s." % schema_version)

	var level_id: Variant = data.get("id")
	if typeof(level_id) != TYPE_STRING or String(level_id).strip_edges().is_empty():
		errors.append("id must be a non-empty string.")

	var width: Variant = data.get("width")
	var height: Variant = data.get("height")
	var dimensions_valid := _is_integer_number(width) and _is_integer_number(height)
	var safe_width := int(width) if dimensions_valid else 0
	var safe_height := int(height) if dimensions_valid else 0
	if not dimensions_valid:
		errors.append("width and height must be integers.")
	else:
		if safe_width < 1 or safe_width > MAX_BOARD_DIMENSION:
			errors.append("width must be between 1 and %d." % MAX_BOARD_DIMENSION)
		if safe_height < 1 or safe_height > MAX_BOARD_DIMENSION:
			errors.append("height must be between 1 and %d." % MAX_BOARD_DIMENSION)


	var has_roster := data.has("deployment_slots") or data.has("squads")
	if has_roster:
		var deployment_slots: Variant = data.get("deployment_slots")
		if not _is_integer_number(deployment_slots) or int(deployment_slots) < 1 or int(deployment_slots) > 4:
			errors.append("deployment_slots must be an integer from 1 to 4.")
		var squads: Variant = data.get("squads")
		if typeof(squads) != TYPE_ARRAY or squads.is_empty() or squads.size() > 8:
			errors.append("squads must be an array containing 1 to 8 squad definitions.")
		else:
			var squad_ids: Dictionary = {}
			for squad_index in range(squads.size()):
				var squad: Variant = squads[squad_index]
				if typeof(squad) != TYPE_DICTIONARY:
					errors.append("squads[%d] must be an object." % squad_index)
					continue
				var squad_id: Variant = squad.get("id")
				var squad_color: Variant = squad.get("color")
				var squad_capacity: Variant = squad.get("capacity")
				if typeof(squad_id) != TYPE_STRING or String(squad_id).strip_edges().is_empty():
					errors.append("squads[%d].id must be a non-empty string." % squad_index)
				elif squad_ids.has(squad_id):
					errors.append("Duplicate squad id: %s." % squad_id)
				else:
					squad_ids[squad_id] = true
				if typeof(squad_color) != TYPE_STRING or not VALID_RESOURCE_COLORS.has(squad_color):
					errors.append("squads[%d].color is unsupported." % squad_index)
				if not _is_integer_number(squad_capacity) or int(squad_capacity) < 1 or int(squad_capacity) > 9:
					errors.append("squads[%d].capacity must be an integer from 1 to 9." % squad_index)

	var start: Vector2i = _read_position(data.get("start"), "start", errors, dimensions_valid, safe_width, safe_height)
	var goal: Vector2i = _read_position(data.get("goal"), "goal", errors, dimensions_valid, safe_width, safe_height)

	var resource_count := 0
	var obstacle_cells: Dictionary = {}
	var seen_cells: Dictionary = {}
	var tiles: Variant = data.get("tiles")
	if typeof(tiles) != TYPE_ARRAY:
		errors.append("tiles must be an array.")
	else:
		for index in range(tiles.size()):
			var tile: Variant = tiles[index]
			if typeof(tile) != TYPE_DICTIONARY:
				errors.append("tiles[%d] must be an object." % index)
				continue

			var x: Variant = tile.get("x")
			var y: Variant = tile.get("y")
			var tile_type: Variant = tile.get("type")
			if not _is_integer_number(x) or not _is_integer_number(y):
				errors.append("tiles[%d] x and y must be integers." % index)
				continue
			if not dimensions_valid or safe_width < 1 or safe_height < 1:
				continue
			var cell := Vector2i(int(x), int(y))
			if cell.x < 0 or cell.y < 0 or cell.x >= safe_width or cell.y >= safe_height:
				errors.append("tiles[%d] is outside the board." % index)
				continue
			if seen_cells.has(cell):
				errors.append("Duplicate tile coordinate at (%d, %d)." % [cell.x, cell.y])
				continue
			seen_cells[cell] = true

			if typeof(tile_type) != TYPE_STRING or not VALID_TILE_TYPES.has(tile_type):
				errors.append("tiles[%d] has an unsupported type." % index)
				continue
			if tile_type == "resource":
				var resource_color: Variant = tile.get("color")
				if typeof(resource_color) != TYPE_STRING or not VALID_RESOURCE_COLORS.has(resource_color):
					errors.append("tiles[%d] resource color must be one of: %s." % [index, ", ".join(VALID_RESOURCE_COLORS)])
				else:
					resource_count += 1
			elif tile_type == "obstacle":
				obstacle_cells[cell] = true

	if obstacle_cells.has(start):
		errors.append("start cannot be placed on an obstacle.")
	if obstacle_cells.has(goal):
		errors.append("goal cannot be placed on an obstacle.")

	return {
		"valid": errors.is_empty(),
		"errors": errors,
		"resource_count": resource_count,
	}


static func _is_integer_number(value: Variant) -> bool:
	if typeof(value) == TYPE_INT:
		return true
	if typeof(value) == TYPE_FLOAT:
		return is_finite(value) and floor(value) == value
	return false


static func _read_position(
	value: Variant,
	field_name: String,
	errors: Array[String],
	dimensions_valid: bool,
	width: int,
	height: int
) -> Vector2i:
	if typeof(value) != TYPE_ARRAY or value.size() != 2:
		errors.append("%s must be a two-item [x, y] array." % field_name)
		return Vector2i(-1, -1)
	if not _is_integer_number(value[0]) or not _is_integer_number(value[1]):
		errors.append("%s coordinates must be integers." % field_name)
		return Vector2i(-1, -1)

	var position := Vector2i(int(value[0]), int(value[1]))
	if dimensions_valid and (position.x < 0 or position.y < 0 or position.x >= width or position.y >= height):
		errors.append("%s is outside the board." % field_name)
		return Vector2i(-1, -1)
	return position
