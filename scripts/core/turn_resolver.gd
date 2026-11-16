class_name TurnResolver
extends RefCounted
## Validates and applies deterministic player actions without presentation dependencies.


static func preview_collection(
	colony: ColonyModel,
	board: BoardModel,
	squad_id: String,
	from_cell: Vector2i,
	target_cell: Vector2i
) -> Dictionary:
	var squad: Dictionary = colony.get_squad(squad_id)
	if squad.is_empty():
		return _failure("Unknown squad: %s." % squad_id)
	if not squad["deployed"]:
		return _failure("Squad must occupy a deployment slot.")
	if squad["carried"] >= squad["capacity"]:
		return _failure("Squad carrying capacity is full.")
	if not board.has_resource(target_cell):
		return _failure("No resource is available at the target cell.")

	var resource_color := board.resource_color_at(target_cell)
	if resource_color != squad["color"]:
		return _failure("Resource color does not match the squad.")

	var squad_position: Vector2i = squad.get("position", Vector2i(-1, -1))
	var route_start := squad_position if board.is_inside(squad_position) else from_cell
	var path: Array[Vector2i] = board.find_path(route_start, target_cell)
	if path.is_empty():
		return _failure("Target resource is not reachable.")

	return {
		"valid": true,
		"errors": [],
		"path": path,
		"resource_color": resource_color,
		"carried_after": squad["carried"] + 1,
		"remaining_capacity_after": squad["capacity"] - squad["carried"] - 1,
	}


static func apply_collection(
	colony: ColonyModel,
	board: BoardModel,
	squad_id: String,
	from_cell: Vector2i,
	target_cell: Vector2i
) -> Dictionary:
	var preview: Dictionary = preview_collection(colony, board, squad_id, from_cell, target_cell)
	if not preview["valid"]:
		return preview

	var result: Dictionary = colony.collect_resource(squad_id, from_cell, target_cell, board)
	if not result["valid"]:
		return result
	result["path"] = preview["path"]
	result["resource_color"] = preview["resource_color"]
	result["remaining_capacity"] = preview["remaining_capacity_after"]
	return result


static func is_level_complete(board: BoardModel, colony: ColonyModel) -> bool:
	return (
		board.remaining_resources == 0
		and colony.delivered_resources == board.total_resources
		and colony.get_active_slot_count() == 0
	)


static func is_level_blocked(board: BoardModel, colony: ColonyModel) -> bool:
	if board.remaining_resources == 0:
		return false
	if colony.get_active_slot_count() > 0:
		return false

	for squad_id in colony.get_squad_ids():
		var squad: Dictionary = colony.get_squad(squad_id)
		if squad["deployed"] or squad["capacity"] < 1:
			continue
		for cell in board.get_resource_cells():
			if board.resource_color_at(cell) != squad["color"]:
				continue
			if not board.find_path(board.start, cell).is_empty():
				return false

	return true


static func _failure(message: String) -> Dictionary:
	return {"valid": false, "errors": [message]}
