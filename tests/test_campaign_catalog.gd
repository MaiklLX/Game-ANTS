extends SceneTree

const CampaignCatalogScript = preload("res://scripts/core/campaign_catalog.gd")


var _failures: Array[String] = []


func _initialize() -> void:
	var result: Dictionary = CampaignCatalogScript.load_catalog("res://campaign/campaign_manifest.json")
	_check(result["valid"], "root manifest and chapter pack should load: %s" % str(result["errors"]))
	if result["valid"]:
		var levels: Array = result["levels"]
		_check(levels.size() == 100, "campaign catalogue should expose all one hundred authored levels across four chapters")
		_check(levels[0]["id"] == "meadow_001", "first manifest level should remain first")
		_check(levels[29]["id"] == "meadow_030", "thirtieth manifest level should remain last")
		_check(levels[0]["chapter_id"] == "meadow", "level should retain its chapter identity")
		_check(levels[29]["global_index"] == 29, "catalog should assign a stable zero-based global index")

		_check(levels[30]["id"] == "root_031", "second chapter should follow Meadow without reordering")
		_check(levels[30]["chapter_id"] == "root_labyrinth", "second chapter should retain its chapter identity")
		_check(levels[59]["id"] == "root_060", "thirtieth Root Labyrinth level should remain last")
		_check(levels[59]["global_index"] == 59, "second chapter levels should keep stable flattened indices")
		_check(levels[60]["id"] == "orchard_061", "third chapter should follow Root Labyrinth without reordering")
		_check(levels[60]["chapter_id"] == "amber_orchard", "third chapter should retain its chapter identity")
		_check(levels[64]["id"] == "orchard_065", "first Amber Orchard batch should remain in order")
		_check(levels[64]["global_index"] == 64, "third chapter levels should keep stable flattened indices")
		_check(levels[65]["id"] == "orchard_066", "Amber Orchard continuation should follow level 065")
		_check(levels[69]["id"] == "orchard_070", "second Amber Orchard batch should remain last")
		_check(levels[69]["chapter_id"] == "amber_orchard", "new levels should retain their chapter identity")
		_check(levels[69]["global_index"] == 69, "new levels should keep stable flattened indices")
		_check(levels[70]["id"] == "orchard_071", "third Amber Orchard batch should follow level 070")
		_check(levels[74]["id"] == "orchard_075", "third Amber Orchard batch should remain last")
		_check(levels[74]["chapter_id"] == "amber_orchard", "latest levels should retain their chapter identity")
		_check(levels[74]["global_index"] == 74, "latest levels should keep stable flattened indices")
		_check(levels[75]["id"] == "orchard_076", "fourth Amber Orchard batch should follow level 075")
		_check(levels[79]["id"] == "orchard_080", "fourth Amber Orchard batch should remain last")
		_check(levels[79]["chapter_id"] == "amber_orchard", "latest levels should retain their chapter identity")
		_check(levels[79]["global_index"] == 79, "latest levels should keep stable flattened indices")
		_check(levels[80]["id"] == "orchard_081", "fifth Amber Orchard batch should follow level 080")
		_check(levels[84]["id"] == "orchard_085", "fifth Amber Orchard batch should remain last")
		_check(levels[84]["chapter_id"] == "amber_orchard", "latest levels should retain their chapter identity")
		_check(levels[84]["global_index"] == 84, "latest levels should keep stable flattened indices")
		_check(levels[85]["id"] == "orchard_086", "final Amber Orchard batch should follow level 085")
		_check(levels[89]["id"] == "orchard_090", "Amber Orchard chapter finale should remain last")
		_check(levels[89]["chapter_id"] == "amber_orchard", "chapter finale should retain its chapter identity")
		_check(levels[89]["global_index"] == 89, "Amber Orchard finale should keep stable flattened index")
		_check(levels[90]["id"] == "colony_091", "fourth chapter should follow Amber Orchard")
		_check(levels[90]["chapter_id"] == "colony_heart", "fourth chapter should retain its identity")
		_check(levels[94]["id"] == "colony_095", "first finale batch should remain last")
		_check(levels[94]["global_index"] == 94, "first finale batch should keep stable flattened index")
		_check(levels[95]["id"] == "colony_096", "finale continuation should follow level 095")
		_check(levels[99]["id"] == "colony_100", "the hundredth level should remain last")
		_check(levels[99]["chapter_id"] == "colony_heart", "the hundredth level should retain finale chapter identity")
		_check(levels[99]["global_index"] == 99, "the hundredth level should keep stable flattened index")

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
