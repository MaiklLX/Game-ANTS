extends SceneTree

const SettingsStoreScript = preload("res://scripts/core/settings_store.gd")
const TEST_PATH := "user://app_settings_test.json"

var _failures: Array[String] = []


func _initialize() -> void:
	_cleanup()
	var store = SettingsStoreScript.new(TEST_PATH)
	var initial: Dictionary = store.load_settings()
	_check(initial["valid"] and initial["is_new"], "missing settings should use defaults")
	_check(not store.is_reduced_motion_enabled(), "reduced motion should be disabled by default")
	_check(store.are_haptics_enabled(), "haptics should be enabled by default")

	_check(store.set_setting("reduced_motion", true)["valid"], "reduced motion preference should save")
	_check(store.set_setting("haptics_enabled", false)["valid"], "haptics preference should save")
	_check(not store.set_setting("unknown_setting", true)["valid"], "unknown setting should be rejected")
	_check(FileAccess.file_exists(TEST_PATH + ".bak"), "replacing settings should preserve the previous version")

	var reopened = SettingsStoreScript.new(TEST_PATH)
	var loaded: Dictionary = reopened.load_settings()
	_check(loaded["valid"] and not loaded["is_new"], "saved settings should reload")
	_check(reopened.is_reduced_motion_enabled(), "reduced motion should persist")
	_check(not reopened.are_haptics_enabled(), "haptics preference should persist")

	_write("{ broken")
	var recovered = SettingsStoreScript.new(TEST_PATH)
	var recovery: Dictionary = recovered.load_settings()
	_check(recovery["valid"] and recovery.get("recovered", false), "corrupt settings should recover to defaults")
	_check(FileAccess.file_exists(TEST_PATH + ".corrupt"), "corrupt settings should be preserved")

	_write(JSON.stringify({"schema_version": 999, "reduced_motion": true}))
	var future = SettingsStoreScript.new(TEST_PATH)
	_check(not future.load_settings()["valid"], "unknown future schema should be rejected")
	_check(not future.set_setting("reduced_motion", false)["valid"], "unsupported settings must not be overwritten")

	_cleanup()
	if _failures.is_empty():
		print("SettingsStore tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("SettingsStore test failed: " + failure)
		quit(1)


func _write(contents: String) -> void:
	var file := FileAccess.open(TEST_PATH, FileAccess.WRITE)
	if file == null:
		_check(false, "settings fixture should be writable")
		return
	file.store_string(contents)
	file.close()


func _cleanup() -> void:
	for path in [TEST_PATH, TEST_PATH + ".tmp", TEST_PATH + ".bak", TEST_PATH + ".corrupt"]:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
