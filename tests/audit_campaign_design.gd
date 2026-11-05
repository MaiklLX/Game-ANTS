extends SceneTree
## Non-blocking campaign design audit. Reports repeated board geometry and
## exact gameplay signatures without treating every shared motif as a defect.

const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")

var _failures: Array[String] = []


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
	return "%d|%d|%s|%s|%s|%s|%d|%s|%s" % [
		int(data["width"]),
		int(data["height"]),
		JSON.stringify(data["start"]),
		JSON.stringify(data["goal"]),
		JSON.stringify(obstacles),
		JSON.stringify(resource_cells),
		int(data["deployment_slots"]),
		JSON.stringify(squads),
		String(data.get("chapter_id", "")),
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
			"CHAPTER %s: levels=%d avg_resources=%.2f avg_obstacles=%.2f avg_squads=%.2f avg_slots=%.2f max_capacity=%d" % [
				String(chapter_id),
				count,
				float(entry["resources"]) / count,
				float(entry["obstacles"]) / count,
				float(entry["squads"]) / count,
				float(entry["slots"]) / count,
				int(entry["capacity_max"]),
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
