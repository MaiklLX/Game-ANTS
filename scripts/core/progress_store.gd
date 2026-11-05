extends RefCounted
## Versioned local campaign progress. Level identity is stored by stable ID, never by array index.

const SCHEMA_VERSION := 1
const DEFAULT_SAVE_PATH := "user://campaign_progress.json"

var _save_path: String
var _known_level_ids: Dictionary = {}
var _completed_level_ids: Dictionary = {}
var _last_selected_level_id: String = ""
var _write_enabled: bool = true
var _warning: String = ""


func _init(save_path: String = DEFAULT_SAVE_PATH) -> void:
	_save_path = save_path


func load_progress(level_ids: Array[String]) -> Dictionary:
	_known_level_ids.clear()
	_completed_level_ids.clear()
	_last_selected_level_id = ""
	_write_enabled = true
	_warning = ""
	for level_id in level_ids:
		if not level_id.is_empty():
			_known_level_ids[level_id] = true
	if not level_ids.is_empty():
		_last_selected_level_id = level_ids[0]

	if not FileAccess.file_exists(_save_path):
		return {"valid": true, "is_new": true, "warning": ""}

	var file := FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		_write_enabled = false
		return _failure("Progress file could not be opened for reading.")

	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	var parsed: Variant = parser.data
	if parse_error != OK or typeof(parsed) != TYPE_DICTIONARY:
		if _preserve_corrupt_save():
			_warning = "Previous progress was damaged; a backup was preserved and a fresh record will be started."
		else:
			_write_enabled = false
			_warning = "Previous progress was damaged and could not be backed up; saving is disabled to protect it."
		return {"valid": true, "is_new": false, "recovered": _write_enabled, "warning": _warning}

	var stored_version := int(parsed.get("schema_version", 0))
	if stored_version != SCHEMA_VERSION:
		_write_enabled = false
		_warning = "Progress save version is not supported; the existing file will not be overwritten."
		return _failure(_warning)

	var stored_completed: Variant = parsed.get("completed_level_ids", [])
	if typeof(stored_completed) == TYPE_ARRAY:
		for value in stored_completed:
			var level_id := String(value)
			if _known_level_ids.has(level_id):
				_completed_level_ids[level_id] = true

	var stored_last_id := String(parsed.get("last_selected_level_id", ""))
	if _known_level_ids.has(stored_last_id):
		_last_selected_level_id = stored_last_id

	return {"valid": true, "is_new": false, "warning": ""}


func set_last_selected_level(level_id: String) -> Dictionary:
	if not _known_level_ids.has(level_id):
		return _failure("Cannot save an unknown level ID: %s." % level_id)
	_last_selected_level_id = level_id
	return _save()


func mark_level_completed(level_id: String) -> Dictionary:
	if not _known_level_ids.has(level_id):
		return _failure("Cannot complete an unknown level ID: %s." % level_id)
	_completed_level_ids[level_id] = true
	return _save()


func is_level_completed(level_id: String) -> bool:
	return _completed_level_ids.has(level_id)


func get_completed_count() -> int:
	return _completed_level_ids.size()


func get_completed_level_ids() -> Array[String]:
	var result: Array[String] = []
	for level_id in _completed_level_ids.keys():
		result.append(String(level_id))
	result.sort()
	return result


func get_last_selected_level_id() -> String:
	return _last_selected_level_id


func _save() -> Dictionary:
	if not _write_enabled:
		return _failure(_warning if not _warning.is_empty() else "Progress saving is disabled.")
	var temporary_path := _save_path + ".tmp"
	var backup_path := _save_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _failure("Could not open temporary progress file.")
	file.store_string(JSON.stringify({
		"schema_version": SCHEMA_VERSION,
		"completed_level_ids": get_completed_level_ids(),
		"last_selected_level_id": _last_selected_level_id,
	}, "\t"))
	file.flush()
	file.close()

	var save_global := ProjectSettings.globalize_path(_save_path)
	var temporary_global := ProjectSettings.globalize_path(temporary_path)
	var backup_global := ProjectSettings.globalize_path(backup_path)
	var moved_previous := false
	if FileAccess.file_exists(_save_path):
		if FileAccess.file_exists(backup_path):
			var remove_error := DirAccess.remove_absolute(backup_global)
			if remove_error != OK:
				return _failure("Could not rotate the previous progress backup.")
		var backup_error := DirAccess.rename_absolute(save_global, backup_global)
		if backup_error != OK:
			return _failure("Could not preserve the previous progress file.")
		moved_previous = true

	var rename_error := DirAccess.rename_absolute(temporary_global, save_global)
	if rename_error != OK:
		if moved_previous:
			DirAccess.rename_absolute(backup_global, save_global)
		return _failure("Could not commit the new progress file.")
	return {"valid": true, "errors": []}


func _preserve_corrupt_save() -> bool:
	var source := FileAccess.open(_save_path, FileAccess.READ)
	if source == null:
		return false
	var contents := source.get_as_text()
	source.close()
	var backup := FileAccess.open(_save_path + ".corrupt", FileAccess.WRITE)
	if backup == null:
		return false
	backup.store_string(contents)
	backup.flush()
	backup.close()
	return true


func _failure(message: String) -> Dictionary:
	return {"valid": false, "errors": [message], "warning": message}
