extends SceneTree

const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")

var _failures: Array[String] = []


func _initialize() -> void:
	var catalog: Dictionary = CampaignCatalogScript.load_catalog("res://campaign/campaign_manifest.json")
	_check(bool(catalog.get("valid", false)), "campaign catalogue should load before localization is checked")
	var localization: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://localization/ru.json"))
	_check(typeof(localization) == TYPE_DICTIONARY, "Russian localization JSON should parse")
	if typeof(localization) == TYPE_DICTIONARY and catalog.get("valid", false):
		var levels: Dictionary = localization.get("levels", {})
		_check(levels.size() == 100, "Russian localization should contain all 100 campaign levels")
		for level in catalog["levels"]:
			var level_id := String(level["id"])
			_check(levels.has(level_id), "missing Russian translation for %s" % level_id)
			if levels.has(level_id):
				var translated: Dictionary = levels[level_id]
				_check(not String(translated.get("title", "")).strip_edges().is_empty(), "%s should have a translated title" % level_id)
				_check(not String(translated.get("objective", "")).strip_edges().is_empty(), "%s should have a translated objective" % level_id)
		var chapters: Dictionary = localization.get("chapter_titles", {})
		_check(chapters.has("The Living Meadow"), "meadow chapter title should be translated")
		_check(chapters.has("The Root Labyrinth"), "root chapter title should be translated")
		_check(chapters.has("The Amber Orchard"), "orchard chapter title should be translated")
		_check(chapters.has("The Colony Heart: First Dawn"), "final chapter title should be translated")
	if _failures.is_empty():
		print("PASS: Russian localization covers all 100 campaign levels and four chapters.")
		quit(0)
		return
	for failure in _failures:
		push_error(failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
