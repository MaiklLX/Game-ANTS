class_name StrategicTurnEngine
extends RefCounted
## Deterministic, presentation-free strategic turn engine.
## Orders are explicit; one shared day point is spent per committed turn.

const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")

var day_limit: int = 0
var day_remaining: int = 0
var turn_number: int = 0
var _orders: Dictionary = {}
var _finished: bool = false
var _outcome: String = "playing"


func configure(day_budget: int) -> void:
	day_limit = maxi(0, day_budget)
	day_remaining = day_limit
	turn_number = 0
	_orders.clear()
	_finished = day_limit == 0
	_outcome = "lost" if _finished else "playing"


func create_snapshot(colony: ColonyModel, board: BoardModel) -> Dictionary:
	return {
		"day_limit": day_limit,
		"day_remaining": day_remaining,
		"turn_number": turn_number,
		"orders": _orders.duplicate(true),
		"finished": _finished,
		"outcome": _outcome,
		"board": board.create_snapshot(),
		"colony": colony.create_snapshot(),
	}


func restore_snapshot(snapshot: Dictionary, colony: ColonyModel, board: BoardModel) -> Dictionary:
	if typeof(snapshot.get("orders")) != TYPE_DICTIONARY or typeof(snapshot.get("board")) != TYPE_DICTIONARY or typeof(snapshot.get("colony")) != TYPE_DICTIONARY:
		return _failure("Turn snapshot is incomplete.")
	if int(snapshot.get("day_limit", -1)) != day_limit:
		return _failure("Snapshot belongs to a different day budget.")
	var board_result: Dictionary = board.restore_snapshot(snapshot["board"])
	if not board_result.get("valid", false):
		return board_result
	var colony_result: Dictionary = colony.restore_snapshot(snapshot["colony"])
	if not colony_result.get("valid", false):
		return colony_result
	day_remaining = int(snapshot.get("day_remaining", day_remaining))
	turn_number = int(snapshot.get("turn_number", turn_number))
	_orders = snapshot["orders"].duplicate(true)
	_finished = bool(snapshot.get("finished", false))
	_outcome = String(snapshot.get("outcome", "playing"))
	return _success()


func get_outcome() -> String:
	return _outcome


func has_order(squad_id: String) -> bool:
	return _orders.has(squad_id)


func get_order(squad_id: String) -> Dictionary:
	if not _orders.has(squad_id):
		return {}
	return _orders[squad_id].duplicate(true)


func cancel_order(squad_id: String) -> Dictionary:
	if _finished:
		return _failure("The level has already ended.")
	if not _orders.has(squad_id):
		return _failure("This squad has no active order.")
	_orders.erase(squad_id)
	return _success()


func set_collect_order(colony: ColonyModel, board: BoardModel, squad_id: String, target: Vector2i) -> Dictionary:
	if _finished:
		return _failure("The level has already ended.")
	var squad: Dictionary = colony.get_squad(squad_id)
	if squad.is_empty() or not squad.get("deployed", false):
		return _failure("Deploy the squad before assigning a target.")
	if int(squad.get("carried", 0)) >= int(squad.get("capacity", 0)):
		return _failure("The squad's carrying capacity is full.")
	if not board.has_resource(target):
		return _failure("No resource is available at the target cell.")
	if board.resource_color_at(target) != String(squad.get("color", "")):
		return _failure("Resource color does not match the squad.")
	for other_id in _orders:
		if other_id != squad_id and _orders[other_id].get("kind", "") == "collect" and _orders[other_id].get("target") == target:
			return _failure("Another squad already has an order for this resource.")
	var from_cell: Vector2i = squad.get("position", board.start)
	var path: Array[Vector2i] = board.find_path(from_cell, target)
	if path.is_empty():
		return _failure("Target must be reachable and different from the squad's current cell.")
	_orders[squad_id] = {"kind": "collect", "target": target, "path": path}
	return {"valid": true, "errors": [], "path": path.duplicate(), "turn_cost": path.size()}


func set_return_order(colony: ColonyModel, board: BoardModel, squad_id: String) -> Dictionary:
	if _finished:
		return _failure("The level has already ended.")
	var squad: Dictionary = colony.get_squad(squad_id)
	if squad.is_empty() or not squad.get("deployed", false):
		return _failure("Only a deployed squad can return.")
	var from_cell: Vector2i = squad.get("position", board.start)
	var path: Array[Vector2i] = board.find_path(from_cell, board.start)
	if path.is_empty():
		return _failure("The squad is already at the nest or the nest is unreachable.")
	_orders[squad_id] = {"kind": "return", "target": board.start, "path": path}
	return {"valid": true, "errors": [], "path": path.duplicate(), "turn_cost": path.size()}


func advance_turn(colony: ColonyModel, board: BoardModel) -> Dictionary:
	if _finished:
		return _failure("The level has already ended.")
	if _orders.is_empty():
		return _failure("Assign at least one squad order before ending the turn.")
	if day_remaining <= 0:
		_finish("lost")
		return _failure("The day has ended.")

	var moved: Array[String] = []
	var blocked: Array[String] = []
	var collected: Array[String] = []
	var delivered: Array[String] = []
	var ordered_ids: Array[String] = []
	for squad_id in _orders:
		ordered_ids.append(String(squad_id))
	ordered_ids.sort()

	for squad_id in ordered_ids:
		if not _orders.has(squad_id):
			continue
		var order: Dictionary = _orders[squad_id]
		var path: Array = order.get("path", [])
		if path.is_empty():
			_orders.erase(squad_id)
			continue
		var squad: Dictionary = colony.get_squad(squad_id)
		if squad.is_empty() or not squad.get("deployed", false):
			_orders.erase(squad_id)
			continue
		var current: Vector2i = squad.get("position", board.start)
		var next_cell: Vector2i = path[0]
		var move_result: Dictionary = colony.move_squad(squad_id, next_cell, board)
		if not move_result.get("valid", false):
			blocked.append(squad_id)
			continue
		moved.append(squad_id)
		path.pop_front()
		order["path"] = path
		_orders[squad_id] = order

		if path.is_empty():
			if order["kind"] == "collect":
				var collect_result: Dictionary = colony.collect_resource(squad_id, next_cell, next_cell, board)
				if collect_result.get("valid", false):
					collected.append(squad_id)
				_orders.erase(squad_id)
			elif order["kind"] == "return":
				var return_result: Dictionary = colony.return_squad(squad_id)
				if return_result.get("valid", false):
					delivered.append(squad_id)
				_orders.erase(squad_id)

	turn_number += 1
	day_remaining = maxi(0, day_remaining - 1)
	if TurnResolverScript.is_level_complete(board, colony):
		_finish("won")
	elif day_remaining == 0:
		_finish("lost")

	return {
		"valid": true,
		"errors": [],
		"turn": turn_number,
		"day_remaining": day_remaining,
		"moved": moved,
		"blocked": blocked,
		"collected": collected,
		"delivered": delivered,
		"outcome": _outcome,
	}


func _finish(outcome: String) -> void:
	_finished = true
	_outcome = outcome
	_orders.clear()


func _success() -> Dictionary:
	return {"valid": true, "errors": []}


func _failure(message: String) -> Dictionary:
	return {"valid": false, "errors": [message]}
