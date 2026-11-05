extends SceneTree

const LevelDefinitionScript = preload("res://scripts/core/level_definition.gd")


func _initialize() -> void:
	var sample_text := FileAccess.get_file_as_string("res://levels/level_001.json")
	var sample_data: Variant = JSON.parse_string(sample_text)
	if typeof(sample_data) != TYPE_DICTIONARY:
		push_error("LevelDefinition test failed: sample level should parse as an object")
		quit(1)
		return

	var result: Dictionary = LevelDefinitionScript.validate(sample_data)
	_check(result["valid"], "sample level should be valid: %s" % str(result["errors"]))
	_check(result["resource_count"] == 1, "sample level should contain one resource")

	var duplicate_data: Dictionary = sample_data.duplicate(true)
	duplicate_data["tiles"].append({"x": 2, "y": 1, "type": "resource"})
	var duplicate_result: Dictionary = LevelDefinitionScript.validate(duplicate_data)
	_check(not duplicate_result["valid"], "duplicate tile coordinates should fail")

	var outside_data: Dictionary = sample_data.duplicate(true)
	outside_data["goal"] = [5, 2]
	var outside_result: Dictionary = LevelDefinitionScript.validate(outside_data)
	_check(not outside_result["valid"], "out-of-bounds goal should fail")

	var version_data: Dictionary = sample_data.duplicate(true)
	version_data["schema_version"] = 99
	var version_result: Dictionary = LevelDefinitionScript.validate(version_data)
	_check(not version_result["valid"], "unsupported schema version should fail")

	var bad_dimensions: Dictionary = sample_data.duplicate(true)
	bad_dimensions["width"] = 0
	_check(not LevelDefinitionScript.validate(bad_dimensions)["valid"], "zero-width board should fail")

	var bad_tile: Dictionary = sample_data.duplicate(true)
	bad_tile["tiles"].append({"x": 3, "y": 2, "type": "lava"})
	_check(not LevelDefinitionScript.validate(bad_tile)["valid"], "unsupported tile type should fail")

	var missing_color: Dictionary = sample_data.duplicate(true)
	missing_color["tiles"][1].erase("color")
	_check(not LevelDefinitionScript.validate(missing_color)["valid"], "resource without a color should fail")

	var bad_color: Dictionary = sample_data.duplicate(true)
	bad_color["tiles"][1]["color"] = "ultraviolet"
	_check(not LevelDefinitionScript.validate(bad_color)["valid"], "unsupported resource color should fail")

	print("LevelDefinition tests completed.")
	quit(0)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("LevelDefinition test failed: " + message)
	quit(1)
