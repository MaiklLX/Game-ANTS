extends SceneTree

const BoardModelScript = preload("res://scripts/core/board_model.gd")
const ColonyModelScript = preload("res://scripts/core/colony_model.gd")
const LevelDefinitionScript = preload("res://scripts/core/level_definition.gd")
const LevelLoaderScript = preload("res://scripts/core/level_loader.gd")
const TurnResolverScript = preload("res://scripts/core/turn_resolver.gd")

const LEVEL_PATHS := [
	"res://levels/level_001.json",
	"res://levels/level_002.json",
	"res://levels/level_003.json",
	"res://levels/level_004.json",
	"res://levels/level_005.json",
		"res://levels/level_006.json",
		"res://levels/level_007.json",
		"res://levels/level_008.json",
		"res://levels/level_009.json",
		"res://levels/level_010.json",
		"res://levels/level_011.json",
		"res://levels/level_012.json",
		"res://levels/level_013.json",
		"res://levels/level_014.json",
		"res://levels/level_015.json",
		"res://levels/level_016.json",
		"res://levels/level_017.json",
		"res://levels/level_018.json",
		"res://levels/level_019.json",
		"res://levels/level_020.json",
		"res://levels/level_021.json",
		"res://levels/level_022.json",
		"res://levels/level_023.json",
		"res://levels/level_024.json",
		"res://levels/level_025.json",
		"res://levels/level_026.json",
		"res://levels/level_027.json",
		"res://levels/level_028.json",
		"res://levels/level_029.json",
		"res://levels/level_030.json",
	"res://levels/level_031.json",
	"res://levels/level_032.json",
	"res://levels/level_033.json",
	"res://levels/level_034.json",
	"res://levels/level_035.json",
	"res://levels/level_036.json",
	"res://levels/level_037.json",
	"res://levels/level_038.json",
	"res://levels/level_039.json",
	"res://levels/level_040.json",
	"res://levels/level_041.json",
	"res://levels/level_042.json",
	"res://levels/level_043.json",
	"res://levels/level_044.json",
	"res://levels/level_045.json",
	"res://levels/level_046.json",
	"res://levels/level_047.json",
	"res://levels/level_048.json",
	"res://levels/level_049.json",
	"res://levels/level_050.json",
	"res://levels/level_051.json",
	"res://levels/level_052.json",
	"res://levels/level_053.json",
	"res://levels/level_054.json",
	"res://levels/level_055.json",
	"res://levels/level_056.json",
	"res://levels/level_057.json",
	"res://levels/level_058.json",
	"res://levels/level_059.json",
	"res://levels/level_060.json",
	"res://levels/level_061.json",
	"res://levels/level_062.json",
	"res://levels/level_063.json",
	"res://levels/level_064.json",
	"res://levels/level_065.json",
	"res://levels/level_066.json",
	"res://levels/level_067.json",
	"res://levels/level_068.json",
	"res://levels/level_069.json",
	"res://levels/level_070.json",
	"res://levels/level_071.json",
	"res://levels/level_072.json",
	"res://levels/level_073.json",
	"res://levels/level_074.json",
	"res://levels/level_075.json",
	"res://levels/level_076.json",
	"res://levels/level_077.json",
	"res://levels/level_078.json",
	"res://levels/level_079.json",
	"res://levels/level_080.json",
	"res://levels/level_081.json",
	"res://levels/level_082.json",
	"res://levels/level_083.json",
	"res://levels/level_084.json",
	"res://levels/level_085.json",
	"res://levels/level_086.json",
	"res://levels/level_087.json",
	"res://levels/level_088.json",
	"res://levels/level_089.json",
	"res://levels/level_090.json",
	"res://levels/level_091.json",
	"res://levels/level_092.json",
	"res://levels/level_093.json",
	"res://levels/level_094.json",
	"res://levels/level_095.json",
	"res://levels/level_096.json",
	"res://levels/level_097.json",
	"res://levels/level_098.json",
	"res://levels/level_099.json",
	"res://levels/level_100.json",
]


var _failures: Array[String] = []


func _initialize() -> void:
	for level_path in LEVEL_PATHS:
		_test_level(level_path)
	_test_two_squad_deployment()
	_test_three_squad_slot_pressure()
	_test_root_labyrinth_route_shapes()
	_test_colony_heart_finale()
	_test_meadow_route_variants()
	_test_amber_orchard_route_variants()

	if _failures.is_empty():
		print("Campaign level tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("Campaign level test failed: " + failure)
		quit(1)


func _test_level(level_path: String) -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(level_path))
	_check(typeof(parsed) == TYPE_DICTIONARY, "%s should parse as JSON object" % level_path)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	var validation: Dictionary = LevelDefinitionScript.validate(data)
	_check(validation["valid"], "%s should validate: %s" % [level_path, str(validation["errors"])])
	if not validation["valid"]:
		return

	var board = BoardModelScript.new()
	var colony = ColonyModelScript.new()
	var loaded: Dictionary = LevelLoaderScript.load_into(data, board, colony)
	_check(loaded["valid"], "%s should load into board and colony" % level_path)
	_check(colony.slot_capacity == int(data["deployment_slots"]), "%s should apply authored slot count" % level_path)
	_check(colony.get_squad_ids().size() == data["squads"].size(), "%s should load every authored squad" % level_path)

	# Solve each authored level deterministically: send each color-matched squad
	# only to its resources, return it when full or when that color is exhausted.
	for squad_id in colony.get_squad_ids():
		var squad: Dictionary = colony.get_squad(squad_id)
		var matching_cells: Array[Vector2i] = []
		for cell in board.get_resource_cells():
			if board.resource_color_at(cell) == squad["color"]:
				matching_cells.append(cell)

		var cell_index := 0
		while cell_index < matching_cells.size():
			var deploy_result: Dictionary = colony.deploy_squad(squad_id)
			_check(deploy_result["valid"], "%s: squad %s should deploy" % [level_path, squad_id])
			if not deploy_result["valid"]:
				return

			var carried_this_trip := 0
			while cell_index < matching_cells.size() and carried_this_trip < squad["capacity"]:
				var target: Vector2i = matching_cells[cell_index]
				var collect_result: Dictionary = TurnResolverScript.apply_collection(
					colony, board, squad_id, board.start, target
				)
				_check(collect_result["valid"], "%s: squad %s should reach matching resource %s" % [level_path, squad_id, str(target)])
				if not collect_result["valid"]:
					return
				_check(colony.get_squad(squad_id)["position"] == target, "%s: squad position should advance to the collected resource" % level_path)
				if level_path == "res://levels/level_003.json" and carried_this_trip == 1 and int(squad["capacity"]) > 1:
					_check(collect_result["path"].size() == 1, "%s: consecutive pickup should route from the previous resource, not the nest" % level_path)
				cell_index += 1
				carried_this_trip += 1

			var return_result: Dictionary = colony.return_squad(squad_id)
			_check(return_result["valid"], "%s: squad %s should return" % [level_path, squad_id])
			_check(colony.get_squad(squad_id)["position"] == board.start, "%s: returned squad should be back at the nest" % level_path)

	_check(TurnResolverScript.is_level_complete(board, colony), "%s should be completable with its authored roster" % level_path)
	_check(not TurnResolverScript.is_level_blocked(board, colony), "%s should not end in a blocked state" % level_path)


func _test_two_squad_deployment() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_004.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		_check(false, "meadow_004 should parse for simultaneous deployment test")
		return
	var board = BoardModelScript.new()
	var colony = ColonyModelScript.new()
	var loaded: Dictionary = LevelLoaderScript.load_into(parsed, board, colony)
	_check(loaded["valid"], "meadow_004 should load for simultaneous deployment test")
	if not loaded["valid"]:
		return
	var amber_deploy: Dictionary = colony.deploy_squad("amber_scouts")
	var teal_deploy: Dictionary = colony.deploy_squad("teal_gatherers")
	_check(amber_deploy["valid"] and teal_deploy["valid"], "both squads should occupy the two deployment slots at once")
	_check(colony.get_active_slot_count() == 2, "meadow_004 should keep both deployment slots occupied")
	var amber_pickup: Dictionary = TurnResolverScript.apply_collection(colony, board, "amber_scouts", board.start, Vector2i(5, 0))
	var teal_pickup: Dictionary = TurnResolverScript.apply_collection(colony, board, "teal_gatherers", board.start, Vector2i(5, 4))
	_check(amber_pickup["valid"], "amber squad should reach the upper seed while teal squad is deployed")
	_check(teal_pickup["valid"], "teal squad should reach the lower seed while amber squad is deployed")
	var amber_return: Dictionary = colony.return_squad("amber_scouts")
	var teal_return: Dictionary = colony.return_squad("teal_gatherers")
	_check(amber_return["valid"] and teal_return["valid"], "both squads should return independently")
	_check(TurnResolverScript.is_level_complete(board, colony), "meadow_004 should complete after both squads deliver")


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)


func _test_three_squad_slot_pressure() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_005.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		_check(false, "meadow_005 should parse for three-squad slot-pressure test")
		return
	var board = BoardModelScript.new()
	var colony = ColonyModelScript.new()
	var loaded: Dictionary = LevelLoaderScript.load_into(parsed, board, colony)
	_check(loaded["valid"], "meadow_005 should load for three-squad slot-pressure test")
	if not loaded["valid"]:
		return

	var amber_deploy: Dictionary = colony.deploy_squad("amber_carriers")
	var teal_deploy: Dictionary = colony.deploy_squad("teal_gatherers")
	var coral_blocked: Dictionary = colony.deploy_squad("coral_scouts")
	_check(amber_deploy["valid"] and teal_deploy["valid"], "amber and teal squads should fill both slots")
	_check(not coral_blocked["valid"], "third squad must wait while both deployment slots are occupied")

	var amber_first: Dictionary = TurnResolverScript.apply_collection(colony, board, "amber_carriers", board.start, Vector2i(5, 0))
	var amber_second: Dictionary = TurnResolverScript.apply_collection(colony, board, "amber_carriers", Vector2i(5, 0), Vector2i(5, 1))
	var teal_pickup: Dictionary = TurnResolverScript.apply_collection(colony, board, "teal_gatherers", board.start, Vector2i(5, 4))
	_check(amber_first["valid"] and amber_second["valid"], "amber carrier should collect its two-seed load")
	_check(teal_pickup["valid"], "teal squad should collect while amber remains deployed")

	var amber_return: Dictionary = colony.return_squad("amber_carriers")
	var coral_deploy: Dictionary = colony.deploy_squad("coral_scouts")
	_check(amber_return["valid"], "full amber squad should return and free one slot")
	_check(coral_deploy["valid"], "coral squad should deploy as soon as a slot is freed")
	var coral_pickup: Dictionary = TurnResolverScript.apply_collection(colony, board, "coral_scouts", board.start, Vector2i(0, 0))
	_check(coral_pickup["valid"], "coral squad should collect its nearby seed")
	var teal_return: Dictionary = colony.return_squad("teal_gatherers")
	var coral_return: Dictionary = colony.return_squad("coral_scouts")
	_check(teal_return["valid"] and coral_return["valid"], "remaining squads should return independently")
	_check(TurnResolverScript.is_level_complete(board, colony), "meadow_005 should complete after respecting slot pressure")


func _test_root_labyrinth_route_shapes() -> void:
	var route_cases := [
		{"path": "res://levels/level_031.json", "target": Vector2i(5, 0), "minimum_extra_steps": 3},
		{"path": "res://levels/level_033.json", "target": Vector2i(5, 0), "minimum_extra_steps": 3},
		{"path": "res://levels/level_035.json", "target": Vector2i(3, 0), "minimum_extra_steps": 3},
		{"path": "res://levels/level_042.json", "target": Vector2i(4, 0), "minimum_extra_steps": 3},
		{"path": "res://levels/level_048.json", "target": Vector2i(4, 2), "minimum_extra_steps": 3},
		{"path": "res://levels/level_051.json", "target": Vector2i(5, 0), "minimum_extra_steps": 3},
		{"path": "res://levels/level_056.json", "target": Vector2i(5, 0), "minimum_extra_steps": 4},
	]
	for route_case in route_cases:
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(route_case["path"]))
		if typeof(parsed) != TYPE_DICTIONARY:
			_check(false, "%s should parse for route-shape test" % route_case["path"])
			continue
		var board = BoardModelScript.new()
		var loaded: Dictionary = board.load_level(parsed)
		_check(loaded["valid"], "%s should load for route-shape test" % route_case["path"])
		if not loaded["valid"]:
			continue
		var target: Vector2i = route_case["target"]
		var path: Array[Vector2i] = board.find_path(board.start, target)
		var direct_distance := absi(board.start.x - target.x) + absi(board.start.y - target.y)
		_check(not path.is_empty(), "%s should keep its featured harvest reachable" % route_case["path"])
		_check(path.size() >= direct_distance + int(route_case["minimum_extra_steps"]), "%s should require a genuine corridor detour" % route_case["path"])

	var crown_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_045.json"))
	if typeof(crown_data) == TYPE_DICTIONARY:
		var crown_board = BoardModelScript.new()
		var crown_loaded: Dictionary = crown_board.load_level(crown_data)
		_check(crown_loaded["valid"], "The Hollow Crown should load for its single-notch route test")
		_check(int(crown_data["deployment_slots"]) == 2, "The Hollow Crown should limit four crews to two field slots")
		if crown_loaded["valid"]:
			var hollow_cache: Array[Vector2i] = crown_board.find_path(crown_board.start, Vector2i(3, 2))
			_check(not hollow_cache.is_empty(), "Hollow Crown's central coral cache should be reachable")
			_check(hollow_cache.has(Vector2i(3, 1)), "Hollow Crown's central cache should be entered through the upper notch")
			_check(crown_board.resource_color_at(Vector2i(3, 2)) == "coral", "Hollow Crown's single-entry pocket should contain the coral cache")
			_check(not crown_board.find_path(crown_board.start, Vector2i(5, 0)).is_empty(), "Hollow Crown upper corridor should be reachable")
			_check(not crown_board.find_path(crown_board.start, Vector2i(5, 4)).is_empty(), "Hollow Crown lower corridor should be reachable")

	var finale_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_060.json"))
	if typeof(finale_data) == TYPE_DICTIONARY:
		var finale_board = BoardModelScript.new()
		var finale_loaded: Dictionary = finale_board.load_level(finale_data)
		_check(finale_loaded["valid"], "The Labyrinth Unbound should load for finale branch test")
		if finale_loaded["valid"]:
			for target in [Vector2i(5, 0), Vector2i(5, 4), Vector2i(1, 0), Vector2i(1, 4)]:
				_check(not finale_board.find_path(finale_board.start, target).is_empty(), "Labyrinth Unbound should keep all four color routes reachable")

	var weave_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_034.json"))
	if typeof(weave_data) == TYPE_DICTIONARY:
		var weave_board = BoardModelScript.new()
		var weave_loaded: Dictionary = weave_board.load_level(weave_data)
		_check(weave_loaded["valid"], "Root Weave should load for branch test")
		if weave_loaded["valid"]:
			_check(not weave_board.find_path(weave_board.start, Vector2i(5, 0)).is_empty(), "Root Weave upper branch should be reachable")
			_check(not weave_board.find_path(weave_board.start, Vector2i(5, 4)).is_empty(), "Root Weave lower branch should be reachable")

	var fork_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_037.json"))
	if typeof(fork_data) == TYPE_DICTIONARY:
		var fork_board = BoardModelScript.new()
		var fork_loaded: Dictionary = fork_board.load_level(fork_data)
		_check(fork_loaded["valid"], "Forked Roots should load for branch identity test")
		if fork_loaded["valid"]:
			var upper_branch: Array[Vector2i] = fork_board.find_path(fork_board.start, Vector2i(5, 0))
			var lower_branch: Array[Vector2i] = fork_board.find_path(fork_board.start, Vector2i(5, 4))
			_check(not upper_branch.is_empty() and upper_branch.has(Vector2i(3, 0)), "Forked Roots upper branch should pass the north side of the heartwood island")
			_check(not lower_branch.is_empty() and lower_branch.has(Vector2i(3, 4)), "Forked Roots lower branch should pass the south side of the heartwood island")

	var split_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_041.json"))
	if typeof(split_data) == TYPE_DICTIONARY:
		var split_board = BoardModelScript.new()
		var split_loaded: Dictionary = split_board.load_level(split_data)
		_check(split_loaded["valid"], "The Split Crossing should load for bottleneck identity test")
		if split_loaded["valid"]:
			for target in [Vector2i(5, 0), Vector2i(5, 4)]:
				var branch_path: Array[Vector2i] = split_board.find_path(split_board.start, target)
				_check(not branch_path.is_empty(), "The Split Crossing far branches should both be reachable")
				_check(branch_path.has(Vector2i(2, 2)), "Every Split Crossing far route should pass through the single shared gate")

	var turning_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_053.json"))
	if typeof(turning_data) == TYPE_DICTIONARY:
		var turning_board = BoardModelScript.new()
		var turning_loaded: Dictionary = turning_board.load_level(turning_data)
		_check(turning_loaded["valid"], "The Turning Fork should load for intermediate-pickup test")
		if turning_loaded["valid"]:
			var intermediate_path: Array[Vector2i] = turning_board.find_path(turning_board.start, Vector2i(3, 4))
			var far_path: Array[Vector2i] = turning_board.find_path(turning_board.start, Vector2i(5, 0))
			_check(not intermediate_path.is_empty() and intermediate_path.has(Vector2i(2, 4)), "The Turning Fork violet cache should be reached through the lower first gate")
			_check(not far_path.is_empty() and far_path.has(Vector2i(4, 0)), "The Turning Fork far harvest should require the upper second gate")



func _test_colony_heart_finale() -> void:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_100.json"))
	if typeof(parsed) != TYPE_DICTIONARY:
		_check(false, "The Colony Heart should parse for final-gate regression test")
		return
	var board = BoardModelScript.new()
	var loaded: Dictionary = board.load_level(parsed)
	_check(loaded["valid"], "The Colony Heart should load for final-gate regression test")
	if not loaded["valid"]:
		return

	_check(board.get_resource_cells().size() == 8, "The Colony Heart should contain all eight final seeds")
	for color in ["amber", "teal", "coral", "violet"]:
		var left_count := 0
		var right_count := 0
		for cell in board.get_resource_cells():
			if board.resource_color_at(cell) != color:
				continue
			if cell.x == 1:
				left_count += 1
			elif cell.x == 5:
				right_count += 1
		_check(left_count == 1 and right_count == 1, "Each final carrier should have one matching seed on either side of the shared gate")

	for target in [Vector2i(5, 0), Vector2i(5, 1), Vector2i(5, 3), Vector2i(5, 4)]:
		var far_route: Array[Vector2i] = board.find_path(board.start, target)
		_check(not far_route.is_empty(), "Every far-side final seed should remain reachable")
		_check(far_route.has(Vector2i(3, 2)), "Every far-side final route should pass through the single central root gate")



func _test_meadow_route_variants() -> void:
	var shift_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_011.json"))
	if typeof(shift_data) == TYPE_DICTIONARY:
		var shift_board = BoardModelScript.new()
		var shift_loaded: Dictionary = shift_board.load_level(shift_data)
		_check(shift_loaded["valid"], "The Long Amber Shift should load for route-variant test")
		if shift_loaded["valid"]:
			var amber_crossing: Array[Vector2i] = shift_board.find_path(Vector2i(5, 0), Vector2i(5, 4))
			_check(amber_crossing.has(Vector2i(3, 2)), "The Long Amber Shift should force the capacity-two carrier around the far-bank root island")

	var four_colors_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_018.json"))
	if typeof(four_colors_data) == TYPE_DICTIONARY:
		var four_colors_board = BoardModelScript.new()
		var four_colors_loaded: Dictionary = four_colors_board.load_level(four_colors_data)
		_check(four_colors_loaded["valid"], "Four Colors, Two Slots should load for route-variant test")
		if four_colors_loaded["valid"]:
			var upper_far_route: Array[Vector2i] = four_colors_board.find_path(four_colors_board.start, Vector2i(5, 0))
			_check(not upper_far_route.is_empty(), "The upper far seed should remain reachable through the lower passage")
			_check(upper_far_route.has(Vector2i(2, 4)), "The upper far seed should require the lower gate after the upper entrance is blocked")



func _test_amber_orchard_route_variants() -> void:
	var bough_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_078.json"))
	if typeof(bough_data) == TYPE_DICTIONARY:
		var bough_board = BoardModelScript.new()
		var bough_loaded: Dictionary = bough_board.load_level(bough_data)
		_check(bough_loaded["valid"], "The Four Hidden Boughs should load for capacity-route test")
		if bough_loaded["valid"]:
			var amber_cells: Array[Vector2i] = []
			for cell in bough_board.get_resource_cells():
				if bough_board.resource_color_at(cell) == "amber":
					amber_cells.append(cell)
			_check(amber_cells.size() == 2, "The Four Hidden Boughs should give amber a paired harvest")
			if amber_cells.size() == 2:
				var amber_route: Array[Vector2i] = bough_board.find_path(amber_cells[0], amber_cells[1])
				_check(amber_route.has(Vector2i(3, 0)), "The heavy amber carrier should cross the upper corridor between its two boughs")

	var sun_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_083.json"))
	if typeof(sun_data) == TYPE_DICTIONARY:
		var sun_board = BoardModelScript.new()
		var sun_loaded: Dictionary = sun_board.load_level(sun_data)
		_check(sun_loaded["valid"], "The Hidden Sun should load for central-lane test")
		if sun_loaded["valid"]:
			_check(sun_board.resource_color_at(Vector2i(2, 2)) == "coral", "The Hidden Sun coral seed should sit in the central lane")

	var compass_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_084.json"))
	if typeof(compass_data) == TYPE_DICTIONARY:
		_check(int(compass_data["deployment_slots"]) == 1, "The Compass Branches should enforce its single-slot finale variant")


