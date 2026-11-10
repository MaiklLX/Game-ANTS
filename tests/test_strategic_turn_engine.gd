extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const StrategicTurnEngineScript = preload("res://scripts/core/strategic_turn_engine.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	var board = BoardModelScript.new()
	var sample: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_001.json"))
	_check(typeof(sample) == TYPE_DICTIONARY and board.load_level(sample)["valid"], "tutorial board should load")

	var colony = ColonyModelScript.new()
	colony.configure(1, board.start)
	_check(colony.register_squad("amber_worker", "amber", 1)["valid"], "worker should register")
	var engine = StrategicTurnEngineScript.new()
	engine.configure(10)

	_check(colony.deploy_squad("amber_worker")["valid"], "worker should deploy")
	var order: Dictionary = engine.set_collect_order(colony, board, "amber_worker", Vector2i(4, 2))
	_check(order["valid"], "explicit collection order should be accepted")
	_check(order["turn_cost"] == 4, "route preview should report four movement turns")
	_check(engine.get_order("amber_worker")["path"].size() == 4, "order should retain its path")
	_check(board.has_resource(Vector2i(4, 2)), "assigning an order must not collect a resource")

	var first_turn: Dictionary = engine.advance_turn(colony, board)
	_check(first_turn["valid"] and first_turn["day_remaining"] == 9, "one committed turn should spend one global day point")
	_check(colony.get_squad("amber_worker")["position"] == Vector2i(1, 2), "squad should move only one cell per turn")
	_check(board.has_resource(Vector2i(4, 2)), "resource should remain until the squad reaches it")

	_check(engine.cancel_order("amber_worker")["valid"], "player should be able to cancel a pending order between turns")
	_check(not engine.has_order("amber_worker"), "cancel should clear the route")
	_check(engine.set_collect_order(colony, board, "amber_worker", Vector2i(4, 2))["valid"], "squad should accept a revised route")
	for _step in range(3):
		var step_result: Dictionary = engine.advance_turn(colony, board)
		_check(step_result["valid"], "each route step should resolve")
	_check(not board.has_resource(Vector2i(4, 2)), "resource should be collected only on arrival")
	_check(colony.get_squad("amber_worker")["carried"] == 1, "arrival should update cargo")
	_check(not engine.has_order("amber_worker"), "collection order should end at the resource without auto-dispatch")

	_check(engine.set_return_order(colony, board, "amber_worker")["valid"], "player should explicitly order the return")
	var return_preview: Dictionary = engine.get_order("amber_worker")
	_check(return_preview["path"].size() == 4, "return preview should report the remaining route")
	for _step in range(4):
		var return_result: Dictionary = engine.advance_turn(colony, board)
		_check(return_result["valid"], "return route should resolve")
	_check(colony.delivered_resources == 1, "cargo should be delivered only at the nest")
	_check(engine.get_outcome() == "won", "delivering the final resource should win the level")
	_check(engine.day_remaining == 2, "win should preserve the unused day budget")
	_check(not engine.advance_turn(colony, board)["valid"], "finished level must reject further turns")

	var empty_engine = StrategicTurnEngineScript.new()
	empty_engine.configure(2)
	_check(not empty_engine.advance_turn(colony, board)["valid"], "turn without orders must not consume time")
	_check(empty_engine.day_remaining == 2, "invalid empty turn must preserve day budget")

	var short_engine = StrategicTurnEngineScript.new()
	short_engine.configure(1)
	var short_colony = ColonyModelScript.new()
	short_colony.configure(1, board.start)
	_check(short_colony.register_squad("amber_short", "amber", 1)["valid"], "short-test squad should register")
	_check(short_colony.deploy_squad("amber_short")["valid"], "short-test squad should deploy")
	_check(short_engine.set_collect_order(short_colony, board, "amber_short", Vector2i(4, 2))["valid"], "short-test route should be assigned")
	var loss: Dictionary = short_engine.advance_turn(short_colony, board)
	_check(loss["outcome"] == "lost" and short_engine.day_remaining == 0, "exhausting the day before completion should lose")

	if _failures.is_empty():
		print("StrategicTurnEngine tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("StrategicTurnEngine test failed: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
