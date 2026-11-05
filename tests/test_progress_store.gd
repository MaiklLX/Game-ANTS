extends SceneTree

const ProgressStoreScript = preload("res://scripts/core/progress_store.gd")

var _failures: Array[String] = []
const TEST_PATH := "user://campaign_progress_test.json"


func _initialize() -> void:
	_cleanup_files()
	var level_ids: Array[String] = ["meadow_001", "meadow_002", "root_031"]
	var store = ProgressStoreScript.new(TEST_PATH)
	var initial: Dictionary = store.load_progress(level_ids)
	_check(initial["valid"] and initial["is_new"], "missing progress file should start a new record")
	_check(store.get_last_selected_level_id() == "meadow_001", "new progress should select the first stable level ID")
	_check(store.get_completed_count() == 0, "new progress should have no completed levels")

	_check(store.set_last_selected_level("meadow_002")["valid"], "last selected level should be saved")
	_check(store.mark_level_completed("meadow_001")["valid"], "completed level should be saved")
	_check(store.mark_level_completed("meadow_001")["valid"], "re-completing a level should remain valid")
	_check(store.get_completed_count() == 1, "completed level IDs should be unique")
	_check(FileAccess.file_exists(TEST_PATH + ".bak"), "atomic replacement should preserve the previous progress file")
	var backup_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(TEST_PATH + ".bak"))
	_check(typeof(backup_data) == TYPE_DICTIONARY and int(backup_data.get("schema_version", 0)) == 1, "progress backup should remain a valid versioned record")
	_check(not store.mark_level_completed("removed_level")["valid"], "unknown level IDs should not be saved")

	var reopened = ProgressStoreScript.new(TEST_PATH)
	var reopened_result: Dictionary = reopened.load_progress(level_ids)
	_check(reopened_result["valid"], "saved progress should reload")
	_check(reopened.get_last_selected_level_id() == "meadow_002", "last selected level should survive reload")
	_check(reopened.is_level_completed("meadow_001"), "completed level should survive reload")
	_check(reopened.get_completed_level_ids() == ["meadow_001"], "completed IDs should be returned in stable sorted order")

	_write_text(TEST_PATH, JSON.stringify({
		"schema_version": 1,
		"completed_level_ids": ["meadow_001", "removed_level"],
		"last_selected_level_id": "removed_level",
	}))
	var filtered = ProgressStoreScript.new(TEST_PATH)
	var filtered_result: Dictionary = filtered.load_progress(level_ids)
	_check(filtered_result["valid"], "progress with removed content IDs should still load")
	_check(filtered.get_completed_count() == 1, "removed level IDs should be ignored safely")
	_check(filtered.get_last_selected_level_id() == "meadow_001", "unknown last level should fall back to the first current level")

	_write_text(TEST_PATH, "{ not valid json")
	var recovered = ProgressStoreScript.new(TEST_PATH)
	var recovered_result: Dictionary = recovered.load_progress(level_ids)
	_check(recovered_result["valid"] and recovered_result["recovered"], "corrupt progress should recover without crashing")
	_check(FileAccess.file_exists(TEST_PATH + ".corrupt"), "corrupt progress should be preserved in a sidecar backup")
	_check(recovered.set_last_selected_level("root_031")["valid"], "fresh progress should save after corrupt-file recovery")
	_check(FileAccess.file_exists(TEST_PATH + ".corrupt"), "corrupt sidecar backup should remain after fresh save")

	_write_text(TEST_PATH, JSON.stringify({
		"schema_version": 999,
		"completed_level_ids": ["meadow_001"],
		"last_selected_level_id": "meadow_002",
	}))
	var future = ProgressStoreScript.new(TEST_PATH)
	var future_result: Dictionary = future.load_progress(level_ids)
	_check(not future_result["valid"], "unsupported future save schema should be rejected")
	_check(not future.set_last_selected_level("meadow_002")["valid"], "unsupported save should not be overwritten")
	_check(FileAccess.get_file_as_string(TEST_PATH).contains('"schema_version":999'), "unsupported save file should remain intact")

	_cleanup_files()
	if _failures.is_empty():
		print("ProgressStore tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("ProgressStore test failed: " + failure)
		quit(1)


func _write_text(path: String, contents: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_check(false, "test fixture should be writable: " + path)
		return
	file.store_string(contents)
	file.close()


func _cleanup_files() -> void:
	for path in [TEST_PATH, TEST_PATH + ".tmp", TEST_PATH + ".bak", TEST_PATH + ".corrupt"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
