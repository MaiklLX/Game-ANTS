extends SceneTree
## Non-blocking campaign design audit. Reports repeated board geometry and
## exact gameplay signatures without treating every shared motif as a defect.

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
	var chapter_stats: Dictionary = {}
	var levels: Array = result["levels"]

	for level_record in levels:
		var data: Dictionary = level_record["data"]
		var level_id := String(level_record["id"])
		var chapter_id := String(level_record["chapter_id"])
		var geometry_key := _geometry_signature(data)
		var gameplay_key := _gameplay_signature(data)
		_add_group(geometry_groups, geometry_key, level_id)
		_add_group(gameplay_groups, gameplay_key, level_id)
		_accumulate_chapter_stats(chapter_stats, chapter_id, data)

	print("CAMPAIGN DESIGN AUDIT — %d levels across %d chapters" % [levels.size(), chapter_stats.size()])
	_print_chapter_stats(chapter_stats)
	_print_duplicate_groups("Repeated board geometry (review candidates)", geometry_groups)
	_print_duplicate_groups("Exact gameplay signatures (high-priority review)", gameplay_groups)
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


func _add_group(groups: Dictionary, signature: String, level_id: String) -> void:
	if not groups.has(signature):
		groups[signature] = []
	groups[signature].append(level_id)


func _accumulate_chapter_stats(stats: Dictionary, chapter_id: String, data: Dictionary) -> void:
	if not stats.has(chapter_id):
		stats[chapter_id] = {
			"levels": 0,
			"resources": 0,
			"obstacles": 0,
			"squads": 0,
			"slots": 0,
			"capacity_total": 0,
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
		var level_expedition_steps := 0
		var level_trip_count := 0
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
						break
					level_expedition_steps += outbound.size()
					current_position = target_cell
					cell_index += 1
					carried += 1
				var return_path: Array[Vector2i] = board.find_path(current_position, board.start)
				level_expedition_steps += return_path.size()
				level_trip_count += 1
		entry["expedition_steps_total"] += level_expedition_steps
		entry["trip_count_total"] += level_trip_count
		entry["expedition_steps_max_level"] = maxi(int(entry["expedition_steps_max_level"]), level_expedition_steps)
	for squad in data.get("squads", []):
		var capacity := int(squad["capacity"])
		entry["squads"] += 1
		entry["capacity_total"] += capacity
		entry["capacity_max"] = maxi(int(entry["capacity_max"]), capacity)


func _print_chapter_stats(stats: Dictionary) -> void:
	var chapter_ids: Array = stats.keys()
	chapter_ids.sort()
	for chapter_id in chapter_ids:
		var entry: Dictionary = stats[chapter_id]
		var count := int(entry["levels"])
		print(
			"CHAPTER %s: levels=%d avg_resources=%.2f avg_obstacles=%.2f avg_squads=%.2f avg_slots=%.2f max_capacity=%d avg_resource_route_steps=%.2f avg_extra_steps=%.2f max_resource_route=%d" % [
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


func _print_duplicate_groups(label: String, groups: Dictionary) -> void:
	var duplicates: Array = []
	for signature in groups:
		var ids: Array = groups[signature]
		if ids.size() > 1:
			duplicates.append(ids)
	print("%s: %d groups" % [label, duplicates.size()])
	for ids in duplicates:
		print("  - %s" % ", ".join(ids))
