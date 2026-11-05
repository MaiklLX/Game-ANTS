extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const StrategicTurnEngineScript = preload("res://scripts/core/strategic_turn_engine.gd")

var failures: Array[String] = []


func _initialize() -> void:
	var sample: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_001.json"))
	_check(typeof(sample) == TYPE_DICTIONARY, "tutorial level JSON should parse")

	var board = BoardModelScript.new()
	_check(board.load_level(sample)["valid"], "tutorial board should load")
	var colony = ColonyModelScript.new()
	colony.configure(1, board.start)
	_check(colony.register_squad("amber_worker", "amber", 1)["valid"], "worker should register")
	var engine = StrategicTurnEngineScript.new()
	engine.configure(10)
	_check(colony.deploy_squad("amber_worker")["valid"], "worker should deploy")

	var order: Dictionary = engine.set_collect_order(colony, board, "amber_worker", Vector2i(4, 2))
	_check(order["valid"] and order["turn_cost"] == 4, "explicit target should return a four-step preview")
	_check(board.has_resource(Vector2i(4, 2)), "assigning an order must not collect")
	var first: Dictionary = engine.advance_turn(colony, board)
	_check(first["valid"] and first["day_remaining"] == 9, "one committed turn spends one shared day point")
	_check(colony.get_squad("amber_worker")["position"] == Vector2i(1, 2), "a squad moves exactly one cell per turn")

	_check(engine.cancel_order("amber_worker")["valid"], "player can cancel a route between turns")
	_check(engine.set_collect_order(colony, board, "amber_worker", Vector2i(4, 2))["valid"], "player can issue a revised route")
	for _step in range(3):
		_check(engine.advance_turn(colony, board)["valid"], "collection route step should resolve")
	_check(not board.has_resource(Vector2i(4, 2)), "resource is collected only on arrival")
	_check(colony.get_squad("amber_worker")["carried"] == 1, "cargo is updated on collection")
	_check(not engine.has_order("amber_worker"), "squad waits after collection; no auto-dispatch")

	var return_order: Dictionary = engine.set_return_order(colony, board, "amber_worker")
	_check(return_order["valid"] and return_order["turn_cost"] == 4, "return order should preview the route")
	for _step in range(4):
		_check(engine.advance_turn(colony, board)["valid"], "return route step should resolve")
	_check(colony.delivered_resources == 1, "cargo is delivered at the nest")
	_check(engine.get_outcome() == "won", "delivering the objective wins")
	_check(engine.day_remaining == 2, "unused day points remain after victory")
	_check(not engine.advance_turn(colony, board)["valid"], "finished level rejects more turns")

	var empty_engine = StrategicTurnEngineScript.new()
	empty_engine.configure(2)
	_check(not empty_engine.advance_turn(colony, board)["valid"], "no order means no turn can be spent")
	_check(empty_engine.day_remaining == 2, "invalid empty turn preserves the day")

	var short_board = BoardModelScript.new()
	_check(short_board.load_level(sample)["valid"], "independent day-expiry board should load")
	var short_colony = ColonyModelScript.new()
	short_colony.configure(1, short_board.start)
	_check(short_colony.register_squad("amber_short", "amber", 1)["valid"], "short-test squad registers")
	_check(short_colony.deploy_squad("amber_short")["valid"], "short-test squad deploys")
	var short_engine = StrategicTurnEngineScript.new()
	short_engine.configure(1)
	_check(short_engine.set_collect_order(short_colony, short_board, "amber_short", Vector2i(4, 2))["valid"], "short-test route is assigned")
	var loss: Dictionary = short_engine.advance_turn(short_colony, short_board)
	_check(loss["outcome"] == "lost" and short_engine.day_remaining == 0, "day expiry before delivery loses")


	var parallel_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_004.json"))
	var parallel_board = BoardModelScript.new()
	_check(parallel_board.load_level(parallel_data)["valid"], "two-squad puzzle should load")
	var parallel_colony = ColonyModelScript.new()
	parallel_colony.configure(2, parallel_board.start)
	_check(parallel_colony.register_squad("amber_scouts", "amber", 1)["valid"], "amber scout registers")
	_check(parallel_colony.register_squad("teal_gatherers", "teal", 1)["valid"], "teal gatherer registers")
	_check(parallel_colony.deploy_squad("amber_scouts")["valid"], "amber scout deploys")
	_check(parallel_colony.deploy_squad("teal_gatherers")["valid"], "teal gatherer deploys")
	var parallel_engine = StrategicTurnEngineScript.new()
	parallel_engine.configure(20)
	_check(parallel_engine.set_collect_order(parallel_colony, parallel_board, "amber_scouts", Vector2i(5, 0))["valid"], "amber target order is valid")
	_check(parallel_engine.set_collect_order(parallel_colony, parallel_board, "teal_gatherers", Vector2i(5, 4))["valid"], "teal target order is valid")
	var parallel_turn: Dictionary = parallel_engine.advance_turn(parallel_colony, parallel_board)
	_check(parallel_turn["valid"] and parallel_turn["moved"].size() == 2, "both squads should advance during the same global turn")
	_check(parallel_turn["day_remaining"] == 19, "parallel movement spends only one shared day point")

	# Complete a full two-squad expedition: both harvest, wait without auto-dispatch,
	# then receive explicit return orders and deliver independently.
	var parallel_collected: Dictionary = {}
	var parallel_guard := 0
	while (parallel_engine.has_order("amber_scouts") or parallel_engine.has_order("teal_gatherers")) and parallel_guard < 20:
		var parallel_step: Dictionary = parallel_engine.advance_turn(parallel_colony, parallel_board)
		_check(parallel_step["valid"], "parallel collection route step should resolve")
		for collected_id in parallel_step.get("collected", []):
			parallel_collected[String(collected_id)] = true
		parallel_guard += 1
	_check(parallel_collected.has("amber_scouts") and parallel_collected.has("teal_gatherers"), "both squads should collect their own resources")
	_check(not parallel_engine.has_order("amber_scouts") and not parallel_engine.has_order("teal_gatherers"), "collected squads should wait for explicit return orders")
	_check(parallel_engine.set_return_order(parallel_colony, parallel_board, "amber_scouts")["valid"], "amber return order should be accepted")
	_check(parallel_engine.set_return_order(parallel_colony, parallel_board, "teal_gatherers")["valid"], "teal return order should be accepted")
	var parallel_delivered: Dictionary = {}
	parallel_guard = 0
	while (parallel_engine.has_order("amber_scouts") or parallel_engine.has_order("teal_gatherers")) and parallel_guard < 20:
		var return_step: Dictionary = parallel_engine.advance_turn(parallel_colony, parallel_board)
		_check(return_step["valid"], "parallel return route step should resolve")
		for delivered_id in return_step.get("delivered", []):
			parallel_delivered[String(delivered_id)] = true
		parallel_guard += 1
	_check(parallel_delivered.has("amber_scouts") and parallel_delivered.has("teal_gatherers"), "both squads should deliver their cargo at the nest")
	_check(parallel_colony.delivered_resources == 2, "parallel delivery should count both resources exactly once")
	_check(parallel_engine.get_outcome() == "won", "parallel expedition should finish only after both deliveries")

	if failures.is_empty():
		print("StrategicTurnEngine tests passed.")
		quit(0)
	else:
		for failure in failures:
			push_error("StrategicTurnEngine test failed: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
