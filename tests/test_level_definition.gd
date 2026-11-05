extends SceneTree

const LevelDefinitionScript = preload("res://scripts/core/level_definition.gd")


func _initialize() -> void:
	var sample_data: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://levels/level_001.json"))
	_check(typeof(sample_data) == TYPE_DICTIONARY, "sample level should parse as an object")
	if typeof(sample_data) != TYPE_DICTIONARY:
		quit(1)
		return

	var result: Dictionary = LevelDefinitionScript.validate(sample_data)
	_check(result["valid"], "sample level should be valid: %s" % result["errors"])
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

	print("LevelDefinition tests passed.")
	quit(0)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	push_error("LevelDefinition test failed: " + message)
	quit(1)
