class_name CampaignCatalog
extends RefCounted
## Loads an expandable campaign from a root manifest and independent chapter packs.
## Level files remain ordinary JSON; adding content does not require code changes.


static func load_catalog(manifest_path: String) -> Dictionary:
	if not FileAccess.file_exists(manifest_path):
		return _failure(["Campaign manifest does not exist: %s." % manifest_path])
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if typeof(parsed) != TYPE_DICTIONARY:
		return _failure(["Campaign manifest must be a JSON object."])
	return expand_manifest(parsed)


static func expand_manifest(manifest: Dictionary) -> Dictionary:
	var errors: Array[String] = []
	var levels: Array[Dictionary] = []
	if int(manifest.get("schema_version", -1)) != 1:
		errors.append("Campaign manifest schema_version must equal 1.")
	var campaign_id: Variant = manifest.get("campaign_id")
	if typeof(campaign_id) != TYPE_STRING or String(campaign_id).strip_edges().is_empty():
		errors.append("campaign_id must be a non-empty string.")
	var packs: Variant = manifest.get("packs")
	if typeof(packs) != TYPE_ARRAY or packs.is_empty():
		errors.append("packs must contain at least one chapter pack.")
		return {"valid": false, "errors": errors, "levels": []}

	var seen_pack_ids: Dictionary = {}
	var seen_level_ids: Dictionary = {}
	var seen_level_files: Dictionary = {}
	for pack_index in range(packs.size()):
		var pack_entry: Variant = packs[pack_index]
		if typeof(pack_entry) != TYPE_DICTIONARY:
			errors.append("packs[%d] must be an object." % pack_index)
			continue
		var pack_path: Variant = pack_entry.get("file")
		if typeof(pack_path) != TYPE_STRING or String(pack_path).strip_edges().is_empty():
			errors.append("packs[%d].file must be a non-empty path." % pack_index)
			continue
		if not FileAccess.file_exists(String(pack_path)):
			errors.append("Chapter pack does not exist: %s." % String(pack_path))
			continue
		var pack_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(String(pack_path)))
		if typeof(pack_data) != TYPE_DICTIONARY:
			errors.append("Chapter pack must be a JSON object: %s." % String(pack_path))
			continue
		if int(pack_data.get("schema_version", -1)) != 1:
			errors.append("Chapter pack schema_version must equal 1: %s." % String(pack_path))
			continue

		var pack_id: Variant = pack_data.get("id")
		var pack_title: Variant = pack_data.get("title")
		if typeof(pack_id) != TYPE_STRING or String(pack_id).strip_edges().is_empty():
			errors.append("Chapter pack id must be a non-empty string: %s." % String(pack_path))
			continue
		if seen_pack_ids.has(pack_id):
			errors.append("Duplicate chapter pack id: %s." % String(pack_id))
			continue
		seen_pack_ids[pack_id] = true
		if typeof(pack_title) != TYPE_STRING or String(pack_title).strip_edges().is_empty():
			errors.append("Chapter pack title must be a non-empty string: %s." % String(pack_path))
			continue

		var pack_levels: Variant = pack_data.get("levels")
		if typeof(pack_levels) != TYPE_ARRAY or pack_levels.is_empty():
			errors.append("Chapter pack %s must contain at least one level." % String(pack_id))
			continue
		var chapter_level_index := 0
		for level_entry_index in range(pack_levels.size()):
			var level_entry: Variant = pack_levels[level_entry_index]
			if typeof(level_entry) != TYPE_DICTIONARY:
				errors.append("%s levels[%d] must be an object." % [String(pack_id), level_entry_index])
				continue
			var level_id: Variant = level_entry.get("id")
			var level_path: Variant = level_entry.get("file")
			if typeof(level_id) != TYPE_STRING or String(level_id).strip_edges().is_empty():
				errors.append("%s levels[%d].id must be a non-empty string." % [String(pack_id), level_entry_index])
				continue
			if typeof(level_path) != TYPE_STRING or String(level_path).strip_edges().is_empty():
				errors.append("%s levels[%d].file must be a non-empty path." % [String(pack_id), level_entry_index])
				continue
			if seen_level_ids.has(level_id):
				errors.append("Duplicate campaign level id: %s." % String(level_id))
				continue
			if seen_level_files.has(level_path):
				errors.append("Campaign level file is referenced more than once: %s." % String(level_path))
				continue
			if not FileAccess.file_exists(String(level_path)):
				errors.append("Campaign level file does not exist: %s." % String(level_path))
				continue
			var level_data: Variant = JSON.parse_string(FileAccess.get_file_as_string(String(level_path)))
			if typeof(level_data) != TYPE_DICTIONARY:
				errors.append("Campaign level must be a JSON object: %s." % String(level_path))
				continue
			var validation: Dictionary = LevelDefinition.validate(level_data)
			if not validation["valid"]:
				errors.append("%s: %s" % [String(level_id), "; ".join(validation["errors"])])
				continue
			if String(level_data.get("id", "")) != String(level_id):
				errors.append("Manifest id does not match level file id: %s." % String(level_path))
				continue

			seen_level_ids[level_id] = true
			seen_level_files[level_path] = true
			levels.append({
				"id": String(level_id),
				"path": String(level_path),
				"data": level_data,
				"chapter_id": String(pack_id),
				"chapter_title": String(pack_title),
				"chapter_index": pack_index,
				"chapter_level_index": chapter_level_index,
				"global_index": levels.size(),
			})
			chapter_level_index += 1

	if levels.is_empty() and errors.is_empty():
		errors.append("Campaign contains no playable levels.")
	return {"valid": errors.is_empty(), "errors": errors, "levels": levels}


static func _failure(errors: Array[String]) -> Dictionary:
	return {"valid": false, "errors": errors, "levels": []}
