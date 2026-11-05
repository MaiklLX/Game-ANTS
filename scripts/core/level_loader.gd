class_name LevelLoader
extends RefCounted
## Loads a validated level definition into the board and colony simulation.


static func load_into(data: Dictionary, board: BoardModel, colony: ColonyModel) -> Dictionary:
	var validation: Dictionary = LevelDefinition.validate(data)
	if not validation["valid"]:
		return {"valid": false, "errors": validation["errors"]}

	if not data.has("deployment_slots") or not data.has("squads"):
		return {"valid": false, "errors": ["Level is missing deployment_slots or squads."]}

	var board_result: Dictionary = board.load_level(data)
	if not board_result["valid"]:
		return board_result

	colony.configure(int(data["deployment_slots"]))
	for squad_data in data["squads"]:
		var result: Dictionary = colony.register_squad(
			String(squad_data["id"]),
			String(squad_data["color"]),
			int(squad_data["capacity"])
		)
		if not result["valid"]:
			return result

	return {
		"valid": true,
		"errors": [],
		"level_id": board.level_id,
		"resource_count": board.total_resources,
		"squad_count": colony.get_squad_ids().size(),
		"deployment_slots": colony.slot_capacity,
	}
