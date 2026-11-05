extends SceneTree
## Protects the authored level contract used by the first-session tutorial.

var _failures: Array[String] = []


func _initialize() -> void:
	var file := FileAccess.open("res://levels/level_001.json", FileAccess.READ)
	_check(file != null, "first tutorial level should be readable")
	if file == null:
		_finish()
		return

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	_check(typeof(parsed) == TYPE_DICTIONARY, "first tutorial level should contain valid JSON")
	if typeof(parsed) != TYPE_DICTIONARY:
		_finish()
		return

	var data: Dictionary = parsed
	_check(String(data.get("id", "")) == "meadow_001", "tutorial must remain attached to stable level meadow_001")
	var start: Array = data.get("start", [])
	_check(start.size() == 2 and int(start[0]) == 0 and int(start[1]) == 2, "tutorial nest should remain at the expected starting cell")
	_check(int(data.get("deployment_slots", 0)) == 1, "first tutorial expedition should teach one deployment slot")

	var amber_squad_found := false
	for squad in data.get("squads", []):
		if String(squad.get("id", "")) == "amber_workers" and String(squad.get("color", "")) == "amber" and int(squad.get("capacity", 0)) == 1:
			amber_squad_found = true
	_check(amber_squad_found, "tutorial must retain its one-capacity amber worker squad")

	var amber_seed_found := false
	for tile in data.get("tiles", []):
		if String(tile.get("type", "")) == "resource" and int(tile.get("x", -1)) == 4 and int(tile.get("y", -1)) == 2 and String(tile.get("color", "")) == "amber":
			amber_seed_found = true
	_check(amber_seed_found, "tutorial's amber collection target should remain at (4, 2)")

	_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("First-session onboarding contract tests passed.")
		quit(0)
		return
	for failure in _failures:
		push_error("Onboarding contract test failed: " + failure)
	quit(1)
