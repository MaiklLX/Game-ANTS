extends RefCounted
## Versioned local accessibility and feedback preferences.

const SCHEMA_VERSION := 1
const DEFAULT_PATH := "user://app_settings.json"

const DEFAULTS := {
	"reduced_motion": false,
	"haptics_enabled": true,
}

var _path: String
var _values: Dictionary = DEFAULTS.duplicate(true)
var _write_enabled := true
var _warning := ""


func _init(path: String = DEFAULT_PATH) -> void:
	_path = path


func load_settings() -> Dictionary:
	_values = DEFAULTS.duplicate(true)
	_write_enabled = true
	_warning = ""
	if not FileAccess.file_exists(_path):
		return {"valid": true, "is_new": true, "settings": get_settings()}

	var file := FileAccess.open(_path, FileAccess.READ)
	if file == null:
		_write_enabled = false
		return _failure("Настройки не удалось прочитать.")

	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK or typeof(parser.data) != TYPE_DICTIONARY:
		_warning = "Файл настроек повреждён; исходные данные сохранены."
		if not _preserve_corrupt():
			_write_enabled = false
			_warning = "Файл настроек повреждён и не сохранён в резервную копию."
		return {"valid": true, "recovered": _write_enabled, "warning": _warning, "settings": get_settings()}

	var parsed: Dictionary = parser.data
	if int(parsed.get("schema_version", 0)) != SCHEMA_VERSION:
		_write_enabled = false
		_warning = "Версия настроек не поддерживается; файл оставлен без изменений."
		return _failure(_warning)

	_values["reduced_motion"] = bool(parsed.get("reduced_motion", DEFAULTS["reduced_motion"]))
	_values["haptics_enabled"] = bool(parsed.get("haptics_enabled", DEFAULTS["haptics_enabled"]))
	return {"valid": true, "is_new": false, "settings": get_settings(), "warning": ""}


func get_settings() -> Dictionary:
	return _values.duplicate(true)


func is_reduced_motion_enabled() -> bool:
	return bool(_values.get("reduced_motion", false))


func are_haptics_enabled() -> bool:
	return bool(_values.get("haptics_enabled", true))


func set_setting(key: String, value: bool) -> Dictionary:
	if not DEFAULTS.has(key):
		return _failure("Неизвестная настройка: %s." % key)
	if not _write_enabled:
		return _failure(_warning if not _warning.is_empty() else "Сохранение настроек отключено.")
	var previous: bool = bool(_values[key])
	_values[key] = value
	var result := _save()
	if not result.get("valid", false):
		_values[key] = previous
	return result


func _save() -> Dictionary:
	var temporary_path := _path + ".tmp"
	var backup_path := _path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return _failure("Не удалось создать временный файл настроек.")
	var payload := {"schema_version": SCHEMA_VERSION}
	payload.merge(_values, true)
	file.store_string(JSON.stringify(payload, "\t"))
	file.flush()
	file.close()

	var save_global := ProjectSettings.globalize_path(_path)
	var temporary_global := ProjectSettings.globalize_path(temporary_path)
	var backup_global := ProjectSettings.globalize_path(backup_path)
	var moved_previous := false
	if FileAccess.file_exists(_path):
		if FileAccess.file_exists(backup_path):
			var remove_error := DirAccess.remove_absolute(backup_global)
			if remove_error != OK:
				return _failure("Не удалось обновить резервную копию настроек.")
		var backup_error := DirAccess.rename_absolute(save_global, backup_global)
		if backup_error != OK:
			return _failure("Не удалось сохранить предыдущие настройки.")
		moved_previous = true
	var rename_error := DirAccess.rename_absolute(temporary_global, save_global)
	if rename_error != OK:
		if moved_previous:
			DirAccess.rename_absolute(backup_global, save_global)
		return _failure("Не удалось применить новые настройки.")
	return {"valid": true, "errors": []}


func _preserve_corrupt() -> bool:
	var source := FileAccess.open(_path, FileAccess.READ)
	if source == null:
		return false
	var contents := source.get_as_text()
	source.close()
	var backup := FileAccess.open(_path + ".corrupt", FileAccess.WRITE)
	if backup == null:
		return false
	backup.store_string(contents)
	backup.flush()
	backup.close()
	return true


func _failure(message: String) -> Dictionary:
	return {"valid": false, "errors": [message], "warning": message}
