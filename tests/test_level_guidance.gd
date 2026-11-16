extends SceneTree
## Verifies the level 002–005 guidance against authored squad, capacity, slot, and color contracts.

const GuidanceScript = preload("res://scripts/ui/level_guidance.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	var level_002 := _load_level("level_002.json")
	var level_003 := _load_level("level_003.json")
	var level_004 := _load_level("level_004.json")
	var level_005 := _load_level("level_005.json")

	_check(int(level_002.get("deployment_slots", 0)) == 1, "level 002 must retain one deployment slot")
	_check(_resource_count(level_002, "amber") == 1 and _resource_count(level_002, "teal") == 1, "level 002 must retain one seed of each color")
	_check(_squad_capacity(level_002, "amber") == 1 and _squad_capacity(level_002, "teal") == 1, "level 002 must retain matching one-capacity squads")

	_check(int(level_003.get("deployment_slots", 0)) == 1, "level 003 must retain one deployment slot")
	_check(_resource_count(level_003, "amber") == 2 and _resource_count(level_003, "teal") == 1, "level 003 must retain the amber pair and separate teal seed")
	_check(_squad_capacity(level_003, "amber") == 2 and _squad_capacity(level_003, "teal") == 1, "level 003 must retain the capacity-two amber carrier")

	_check(int(level_004.get("deployment_slots", 0)) == 2, "level 004 must retain two deployment slots")
	_check(_resource_count(level_004, "amber") == 1 and _resource_count(level_004, "teal") == 1, "level 004 must retain both matching color targets")
	_check(_squad_capacity(level_004, "amber") == 1 and _squad_capacity(level_004, "teal") == 1, "level 004 must retain both one-capacity teams")

	_check(int(level_005.get("deployment_slots", 0)) == 2, "level 005 must retain two deployment slots")
	_check(_resource_count(level_005, "amber") == 2 and _resource_count(level_005, "teal") == 1 and _resource_count(level_005, "coral") == 1, "level 005 must retain the three-color four-seed workload")
	_check(_squad_capacity(level_005, "amber") == 2 and _squad_capacity(level_005, "teal") == 1 and _squad_capacity(level_005, "coral") == 1, "level 005 must retain the capacity-two amber carrier and two scouts")

	_test_level_002_hints()
	_test_level_003_hints()
	_test_level_004_hints()
	_test_level_005_hints()
	_check(GuidanceScript.get_hint("meadow_006", {}, 0, 1, 0).is_empty(), "levels outside the guidance batch must not receive an unreviewed hint")

	_finish()


func _test_level_002_hints() -> void:
	var opening := GuidanceScript.get_hint("meadow_002", {}, 0, 1, 0)
	_check(opening.contains("One slot") and opening.contains("two colors"), "level 002 opening hint must explain its one-slot color rotation")

	var carrying := GuidanceScript.get_hint("meadow_002", {"color": "amber", "deployed": true, "carried": 1, "capacity": 1}, 1, 1, 0)
	_check(carrying.contains("free the only slot"), "level 002 carrying hint must direct the player home before changing colors")

	var after_delivery := GuidanceScript.get_hint("meadow_002", {}, 0, 1, 1)
	_check(after_delivery.contains("other color"), "level 002 must point toward the remaining color after the first delivery")


func _test_level_003_hints() -> void:
	var opening := GuidanceScript.get_hint("meadow_003", {}, 0, 1, 0)
	_check(opening.contains("two-seed trip"), "level 003 opening hint must communicate capacity-two planning")

	var amber_loaded := GuidanceScript.get_hint("meadow_003", {"color": "amber", "deployed": true, "carried": 1, "capacity": 2}, 1, 1, 0)
	_check(amber_loaded.contains("both amber seeds"), "level 003 amber hint must recommend filling the paired load")

	var amber_full := GuidanceScript.get_hint("meadow_003", {"color": "amber", "deployed": true, "carried": 2, "capacity": 2}, 1, 1, 0)
	_check(amber_full.contains("deliver both seeds"), "level 003 full-load hint must direct the player to the nest")

	var teal_loaded := GuidanceScript.get_hint("meadow_003", {"color": "teal", "deployed": true, "carried": 1, "capacity": 1}, 1, 1, 0)
	_check(teal_loaded.contains("separate two-seed trip"), "level 003 teal hint must explain the separate amber expedition")


func _test_level_004_hints() -> void:
	var opening := GuidanceScript.get_hint("meadow_004", {}, 0, 2, 0)
	_check(opening.contains("Two slots") and opening.contains("narrow pass"), "level 004 opening hint must introduce the two-slot narrow crossing")

	var one_active := GuidanceScript.get_hint("meadow_004", {"color": "amber", "deployed": true, "carried": 0, "capacity": 1}, 1, 2, 0)
	_check(one_active.contains("One slot is free"), "level 004 hint must encourage use of the second slot")

	var both_active := GuidanceScript.get_hint("meadow_004", {"color": "teal", "deployed": true, "carried": 0, "capacity": 1}, 2, 2, 0)
	_check(both_active.contains("Both squads can work"), "level 004 hint must recognize when both squads are deployed")


func _test_level_005_hints() -> void:
	var opening := GuidanceScript.get_hint("meadow_005", {}, 0, 2, 0)
	_check(opening.contains("Three colors") and opening.contains("two slots"), "level 005 opening hint must explain three colors competing for two slots")

	var amber_waiting := GuidanceScript.get_hint("meadow_005", {"color": "amber", "deployed": true, "carried": 1, "capacity": 2}, 2, 2, 0)
	_check(amber_waiting.contains("second space") and amber_waiting.contains("third color waits"), "level 005 amber hint must explain the paired load and waiting third color")

	var both_busy := GuidanceScript.get_hint("meadow_005", {}, 2, 2, 0)
	_check(both_busy.contains("Both slots are busy"), "level 005 must explain how to rotate a third squad when both slots are occupied")


func _load_level(file_name: String) -> Dictionary:
	var file := FileAccess.open("res://levels/" + file_name, FileAccess.READ)
	_check(file != null, file_name + " must be readable")
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(typeof(parsed) == TYPE_DICTIONARY, file_name + " must contain a JSON object")
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed


func _resource_count(level_data: Dictionary, color: String) -> int:
	var count := 0
	for tile in level_data.get("tiles", []):
		if String(tile.get("type", "")) == "resource" and String(tile.get("color", "")) == color:
			count += 1
	return count


func _squad_capacity(level_data: Dictionary, color: String) -> int:
	for squad in level_data.get("squads", []):
		if String(squad.get("color", "")) == color:
			return int(squad.get("capacity", 0))
	return 0


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("Contextual level guidance contract tests passed.")
		quit(0)
		return
	for failure in _failures:
		push_error("Contextual level guidance contract failed: " + failure)
	quit(1)
