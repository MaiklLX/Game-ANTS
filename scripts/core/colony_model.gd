class_name ColonyModel
extends RefCounted
## Deterministic squad roster and limited deployment-slot state.

const VALID_COLORS := ["amber", "teal", "coral", "violet"]

var slot_capacity: int = 0
var delivered_resources: int = 0
var _squads: Dictionary = {}


func configure(max_slots: int) -> void:
	slot_capacity = maxi(0, max_slots)
	delivered_resources = 0
	_squads.clear()


func register_squad(squad_id: String, color: String, carry_capacity: int) -> Dictionary:
	if squad_id.strip_edges().is_empty():
		return _failure("squad_id must not be empty.")
	if _squads.has(squad_id):
		return _failure("squad_id is already registered.")
	if not VALID_COLORS.has(color):
		return _failure("Unsupported squad color: %s." % color)
	if carry_capacity < 1:
		return _failure("carry_capacity must be at least one.")

	_squads[squad_id] = {
		"id": squad_id,
		"color": color,
		"capacity": carry_capacity,
		"carried": 0,
		"deployed": false,
		"slot_index": -1,
	}
	return _success()


func deploy_squad(squad_id: String) -> Dictionary:
	if not _squads.has(squad_id):
		return _failure("Unknown squad: %s." % squad_id)

	var squad: Dictionary = _squads[squad_id]
	if squad["deployed"]:
		return _failure("Squad is already deployed.")

	var occupied: Dictionary = {}
	for current in _squads.values():
		if current["deployed"]:
			occupied[current["slot_index"]] = true

	for slot_index in range(slot_capacity):
		if occupied.has(slot_index):
			continue
		squad["deployed"] = true
		squad["slot_index"] = slot_index
		squad["carried"] = 0
		_squads[squad_id] = squad
		return {
			"valid": true,
			"errors": [],
			"slot_index": slot_index,
		}

	return _failure("No deployment slot is available.")


func collect_resource(squad_id: String, cell: Vector2i, board: BoardModel) -> Dictionary:
	if not _squads.has(squad_id):
		return _failure("Unknown squad: %s." % squad_id)

	var squad: Dictionary = _squads[squad_id]
	if not squad["deployed"]:
		return _failure("Squad must be deployed before collecting.")
	if squad["carried"] >= squad["capacity"]:
		return _failure("Squad carrying capacity is full.")
	if not board.has_resource(cell):
		return _failure("No resource is available at the target cell.")
	if board.resource_color_at(cell) != squad["color"]:
		return _failure("Resource color does not match the squad.")

	if not board.collect_resource(cell, squad["color"]):
		return _failure("Resource could not be collected.")

	squad["carried"] += 1
	_squads[squad_id] = squad
	return {
		"valid": true,
		"errors": [],
		"carried": squad["carried"],
		"remaining_capacity": squad["capacity"] - squad["carried"],
	}


func return_squad(squad_id: String) -> Dictionary:
	if not _squads.has(squad_id):
		return _failure("Unknown squad: %s." % squad_id)

	var squad: Dictionary = _squads[squad_id]
	if not squad["deployed"]:
		return _failure("Squad is not deployed.")

	var delivered: int = squad["carried"]
	delivered_resources += delivered
	squad["carried"] = 0
	squad["deployed"] = false
	squad["slot_index"] = -1
	_squads[squad_id] = squad
	return {
		"valid": true,
		"errors": [],
		"delivered": delivered,
		"delivered_total": delivered_resources,
	}


func get_squad(squad_id: String) -> Dictionary:
	if not _squads.has(squad_id):
		return {}
	return _squads[squad_id].duplicate(true)


func get_active_slot_count() -> int:
	var count := 0
	for squad in _squads.values():
		if squad["deployed"]:
			count += 1
	return count


func _success() -> Dictionary:
	return {"valid": true, "errors": []}


func _failure(message: String) -> Dictionary:
	return {"valid": false, "errors": [message]}
