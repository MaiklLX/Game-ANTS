extends SceneTree
## Non-blocking campaign design audit. Reports repeated board geometry,
## chapter route/workload averages, and the heaviest deterministic test routes.

const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")
const BoardModelScript = preload("res://scripts/core/board_model.gd")


func _initialize() -> void:
	var result: Dictionary = CampaignCatalogScript.load_catalog("res://campaign/campaign_manifest.json")
	if not result.get("valid", false):
		push_error("Campaign uniqueness audit could not load catalogue: %s" % str(result.get("errors", [])))
		quit(1)
		return

	var geometry_groups: Dictionary = {}
	var gameplay_groups: Dictionary = {}
	var route_profile_groups: Dictionary = {}
	var chapter_stats: Dictionary = {}
	var level_workloads: Array[Dictionary] = []
	var levels: Array = result["levels"]

	for level_record in levels:
		var data: Dictionary = level_record["data"]
		var level_id := String(level_record["id"])
		var chapter_id := String(level_record["chapter_id"])
		_add_group(geometry_groups, _geometry_signature(data), level_id)
		_add_group(gameplay_groups, _gameplay_signature(data), level_id)
		_add_group(route_profile_groups, _route_profile_signature(data), level_id)
		var workload: Dictionary = _accumulate_chapter_stats(chapter_stats, chapter_id, data)
		workload["id"] = level_id
		workload["chapter_id"] = chapter_id
		level_workloads.append(workload)

	print("CAMPAIGN DESIGN AUDIT — %d levels across %d chapters" % [levels.size(), chapter_stats.size()])
	_print_chapter_stats(chapter_stats)
	_print_top_workloads(level_workloads, 10)
	_print_progression_bands(level_workloads)
	_print_chapter_workloads(level_workloads, "colony_heart")
	_print_duplicate_groups("Repeated board geometry (review candidates)", geometry_groups)
	_print_duplicate_groups("Exact gameplay signatures (high-priority review)", gameplay_groups)
	_print_duplicate_groups("Resource route profiles (distance + shortest-path multiplicity review candidates)", route_profile_groups)
	print("Audit is informational: shared geometry can be intentional; human design review remains required.")
	quit(0)


func _geometry_signature(data: Dictionary) -> String:
	var obstacles: Array[String] = []
	var resources: Array[String] = []
	for tile in data.get("tiles", []):
		var coordinate := "%d,%d" % [int(tile["x"]), int(tile["y"])]
		if String(tile["type"]) == "obstacle":
			obstacles.append(coordinate)
		elif String(tile["type"]) == "resource":
			resources.append(coordinate)
	obstacles.sort()
	resources.sort()
	return "%d|%d|%s|%s|%s|%s" % [
		int(data["width"]),
		int(data["height"]),
		JSON.stringify(data["start"]),
		JSON.stringify(data["goal"]),
		JSON.stringify(obstacles),
		JSON.stringify(resources),
	]


func _gameplay_signature(data: Dictionary) -> String:
	var resource_cells: Array[String] = []
	var obstacles: Array[String] = []
	var squads: Array[String] = []
	for tile in data.get("tiles", []):
		var coordinate := "%d,%d" % [int(tile["x"]), int(tile["y"])]
		if String(tile["type"]) == "obstacle":
			obstacles.append(coordinate)
		elif String(tile["type"]) == "resource":
			resource_cells.append("%s:%s" % [coordinate, String(tile["color"])])
	for squad in data.get("squads", []):
		squads.append("%s:%d" % [String(squad["color"]), int(squad["capacity"])])
	obstacles.sort()
	resource_cells.sort()
	squads.sort()
	return "%d|%d|%s|%s|%s|%s|%d|%s" % [
		int(data["width"]),
		int(data["height"]),
		JSON.stringify(data["start"]),
		JSON.stringify(data["goal"]),
		JSON.stringify(obstacles),
		JSON.stringify(resource_cells),
		int(data["deployment_slots"]),
		JSON.stringify(squads),
	]


func _route_profile_signature(data: Dictionary) -> String:
	var board = BoardModelScript.new()
	var loaded: Dictionary = board.load_level(data)
	if not loaded.get("valid", false):
		return "invalid"
	var blocked: Dictionary = {}
	for tile in data.get("tiles", []):
		if String(tile["type"]) == "obstacle":
			blocked[Vector2i(int(tile["x"]), int(tile["y"]))] = true
	var resource_routes: Array[String] = []
	for tile in data.get("tiles", []):
		if String(tile["type"]) != "resource":
			continue
		var target := Vector2i(int(tile["x"]), int(tile["y"]))
		var metrics: Dictionary = _shortest_route_metrics(data, board.start, target, blocked)
		resource_routes.append("%s:%d:%d" % [String(tile["color"]), int(metrics["distance"]), int(metrics["paths"])])
	resource_routes.sort()
	var squad_profile: Array[String] = []
	for squad in data.get("squads", []):
		squad_profile.append("%s:%d" % [String(squad["color"]), int(squad["capacity"])])
	squad_profile.sort()
	return "%d|%s|%s" % [int(data["deployment_slots"]), JSON.stringify(resource_routes), JSON.stringify(squad_profile)]


func _shortest_route_metrics(data: Dictionary, start: Vector2i, target: Vector2i, blocked: Dictionary) -> Dictionary:
	var queue: Array[Vector2i] = [start]
	var distances: Dictionary = {}
	var path_counts: Dictionary = {}
	distances[start] = 0
	path_counts[start] = 1
	var directions: Array[Vector2i] = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]
	var cursor := 0
	while cursor < queue.size():
		var current: Vector2i = queue[cursor]
		cursor += 1
		for direction in directions:
			var next := current + direction
			if next.x < 0 or next.y < 0 or next.x >= int(data["width"]) or next.y >= int(data["height"]) or blocked.has(next):
				continue
			var next_distance := int(distances[current]) + 1
			if not distances.has(next):
				distances[next] = next_distance
				path_counts[next] = int(path_counts[current])
				queue.append(next)
			elif int(distances[next]) == next_distance:
				path_counts[next] = int(path_counts[next]) + int(path_counts[current])
	if not distances.has(target):
		return {"distance": -1, "paths": 0}
	return {"distance": int(distances[target]), "paths": int(path_counts[target])}


func _add_group(groups: Dictionary, signature: String, level_id: String) -> void:
	if not groups.has(signature):
		groups[signature] = []
	groups[signature].append(level_id)


func _accumulate_chapter_stats(stats: Dictionary, chapter_id: String, data: Dictionary) -> Dictionary:
	if not stats.has(chapter_id):
		stats[chapter_id] = {
			"levels": 0,
			"resources": 0,
			"obstacles": 0,
			"squads": 0,
			"slots": 0,
			"capacity_max": 0,
			"route_samples": 0,
			"route_steps_total": 0,
			"extra_steps_total": 0,
			"route_steps_max": 0,
			"expedition_steps_total": 0,
			"trip_count_total": 0,
			"expedition_steps_max_level": 0,
		}
	var entry: Dictionary = stats[chapter_id]
	entry["levels"] += 1
	entry["slots"] += int(data["deployment_slots"])
	for tile in data.get("tiles", []):
		if String(tile["type"]) == "resource":
			entry["resources"] += 1
		elif String(tile["type"]) == "obstacle":
			entry["obstacles"] += 1
	for squad in data.get("squads", []):
		entry["squads"] += 1
		entry["capacity_max"] = maxi(int(entry["capacity_max"]), int(squad["capacity"]))

	var level_expedition_steps := 0
	var level_trip_count := 0
	var board = BoardModelScript.new()
	var board_result: Dictionary = board.load_level(data)
	if board_result.get("valid", false):
		for tile in data.get("tiles", []):
			if String(tile["type"]) != "resource":
				continue
			var target := Vector2i(int(tile["x"]), int(tile["y"]))
			var route: Array[Vector2i] = board.find_path(board.start, target)
			if route.is_empty():
				continue
			var direct_steps := absi(board.start.x - target.x) + absi(board.start.y - target.y)
			entry["route_samples"] += 1
			entry["route_steps_total"] += route.size()
			entry["extra_steps_total"] += route.size() - direct_steps
			entry["route_steps_max"] = maxi(int(entry["route_steps_max"]), route.size())

		for squad in data.get("squads", []):
			var matching_cells: Array[Vector2i] = []
			for cell in board.get_resource_cells():
				if board.resource_color_at(cell) == String(squad["color"]):
					matching_cells.append(cell)
			var cell_index := 0
			while cell_index < matching_cells.size():
				var current_position: Vector2i = board.start
				var carried := 0
				while cell_index < matching_cells.size() and carried < int(squad["capacity"]):
					var target_cell: Vector2i = matching_cells[cell_index]
					var outbound: Array[Vector2i] = board.find_path(current_position, target_cell)
					if outbound.is_empty():
						cell_index = matching_cells.size()
						break
					level_expedition_steps += outbound.size()
					current_position = target_cell
					cell_index += 1
					carried += 1
				if carried == 0:
					break
				var return_path: Array[Vector2i] = board.find_path(current_position, board.start)
				level_expedition_steps += return_path.size()
				level_trip_count += 1

	entry["expedition_steps_total"] += level_expedition_steps
	entry["trip_count_total"] += level_trip_count
	entry["expedition_steps_max_level"] = maxi(int(entry["expedition_steps_max_level"]), level_expedition_steps)
	return {"steps": level_expedition_steps, "trips": level_trip_count}


func _print_chapter_stats(stats: Dictionary) -> void:
	var chapter_ids: Array = stats.keys()
	chapter_ids.sort()
	for chapter_id in chapter_ids:
		var entry: Dictionary = stats[chapter_id]
		var count := int(entry["levels"])
		print(
			"CHAPTER %s: levels=%d avg_resources=%.2f avg_obstacles=%.2f avg_squads=%.2f avg_slots=%.2f max_capacity=%d avg_resource_route_steps=%.2f avg_extra_steps=%.2f max_resource_route=%d avg_test_solver_steps_per_level=%.2f avg_trips_per_level=%.2f max_test_solver_steps=%d" % [
				String(chapter_id),
				count,
				float(entry["resources"]) / count,
				float(entry["obstacles"]) / count,
				float(entry["squads"]) / count,
				float(entry["slots"]) / count,
				int(entry["capacity_max"]),
				float(entry["route_steps_total"]) / maxf(1.0, float(entry["route_samples"])),
				float(entry["extra_steps_total"]) / maxf(1.0, float(entry["route_samples"])),
				int(entry["route_steps_max"]),
				float(entry["expedition_steps_total"]) / count,
				float(entry["trip_count_total"]) / count,
				int(entry["expedition_steps_max_level"]),
			]
		)


func _print_top_workloads(records: Array[Dictionary], limit: int) -> void:
	var sorted_records: Array[Dictionary] = records.duplicate()
	sorted_records.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["steps"]) > int(b["steps"])
	)
	print("TOP %d deterministic test-solver workloads:" % limit)
	for index in range(mini(limit, sorted_records.size())):
		var record: Dictionary = sorted_records[index]
		print("  - %s (%s): steps=%d trips=%d" % [
			String(record["id"]),
			String(record["chapter_id"]),
			int(record["steps"]),
			int(record["trips"]),
		])


func _print_progression_bands(records: Array[Dictionary]) -> void:
	var bands: Dictionary = {}
	for record in records:
		var level_number := int(String(record["id"]).get_slice("_", 1))
		var band_start := int((level_number - 1) / 5) * 5 + 1
		var key := "%s|%03d" % [String(record["chapter_id"]), band_start]
		if not bands.has(key):
			bands[key] = {"levels": 0, "steps": 0, "trips": 0, "max_steps": 0}
		var band: Dictionary = bands[key]
		band["levels"] += 1
		band["steps"] += int(record["steps"])
		band["trips"] += int(record["trips"])
		band["max_steps"] = maxi(int(band["max_steps"]), int(record["steps"]))
	var keys: Array = bands.keys()
	keys.sort()
	print("FIVE-LEVEL WORKLOAD BANDS:")
	for key in keys:
		var band: Dictionary = bands[key]
		var count := int(band["levels"])
		var first_level := int(String(key).get_slice("|", 1))
		print("  - %s %03d-%03d: avg_steps=%.2f avg_trips=%.2f max_steps=%d" % [
			String(key).get_slice("|", 0),
			first_level,
			mini(first_level + 4, 100),
			float(band["steps"]) / count,
			float(band["trips"]) / count,
			int(band["max_steps"]),
		])


func _print_chapter_workloads(records: Array[Dictionary], chapter_id: String) -> void:
	print("LEVEL WORKLOADS — %s:" % chapter_id)
	for record in records:
		if String(record["chapter_id"]) != chapter_id:
			continue
		print("  - %s: steps=%d trips=%d" % [
			String(record["id"]),
			int(record["steps"]),
			int(record["trips"]),
		])


func _print_duplicate_groups(label: String, groups: Dictionary) -> void:
	var duplicates: Array = []
	for signature in groups:
		var ids: Array = groups[signature]
		if ids.size() > 1:
			duplicates.append(ids)
	print("%s: %d groups" % [label, duplicates.size()])
	for ids in duplicates:
		print("  - %s" % ", ".join(ids))
