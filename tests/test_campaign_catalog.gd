extends SceneTree

const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")


var _failures: Array[String] = []


func _initialize() -> void:
	var result: Dictionary = CampaignCatalogScript.load_catalog("res://campaign/campaign_manifest.json")
	_check(result["valid"], "root manifest and chapter pack should load: %s" % str(result["errors"]))
	if result["valid"]:
		var levels: Array = result["levels"]
		_check(levels.size() == 50, "meadow pack should expose all fifty authored levels across both chapters")
		_check(levels[0]["id"] == "meadow_001", "first manifest level should remain first")
		_check(levels[29]["id"] == "meadow_030", "thirtieth manifest level should remain last")
		_check(levels[0]["chapter_id"] == "meadow", "level should retain its chapter identity")
		_check(levels[29]["global_index"] == 29, "catalog should assign a stable zero-based global index")

		_check(levels[30]["id"] == "root_031", "second chapter should follow Meadow without reordering")
		_check(levels[30]["chapter_id"] == "root_labyrinth", "second chapter should retain its chapter identity")
		_check(levels[49]["id"] == "root_050", "twentieth Root Labyrinth level should remain last")
		_check(levels[49]["global_index"] == 49, "second chapter levels should keep stable flattened indices")

	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://campaign/campaign_manifest.json"))
	var duplicate_pack: Dictionary = manifest.duplicate(true)
	duplicate_pack["packs"].append(duplicate_pack["packs"][0].duplicate(true))
	var duplicate_result: Dictionary = CampaignCatalogScript.expand_manifest(duplicate_pack)
	_check(not duplicate_result["valid"], "duplicate chapter pack references should be rejected")

	var missing_pack: Dictionary = manifest.duplicate(true)
	missing_pack["packs"][0]["file"] = "res://campaign/packs/missing/pack.json"
	var missing_result: Dictionary = CampaignCatalogScript.expand_manifest(missing_pack)
	_check(not missing_result["valid"], "missing chapter packs should be rejected")

	var empty_campaign: Dictionary = manifest.duplicate(true)
	empty_campaign["packs"] = []
	var empty_result: Dictionary = CampaignCatalogScript.expand_manifest(empty_campaign)
	_check(not empty_result["valid"], "empty campaign should be rejected")

	if _failures.is_empty():
		print("Campaign catalog tests passed.")
		quit(0)
	else:
		for failure in _failures:
			push_error("Campaign catalog test failed: " + failure)
		quit(1)


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	_failures.append(message)
