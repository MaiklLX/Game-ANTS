extends RefCounted
## Short, state-aware field tips for the first four post-tutorial levels.
## This module is presentation-only: it does not alter movement, collection, or deployment rules.


static func get_hint(
	level_id: String,
	selected_squad: Dictionary,
	active_squad_count: int,
	slot_capacity: int,
	delivered_count: int
) -> String:
	var has_selection := not selected_squad.is_empty()
	var is_deployed := bool(selected_squad.get("deployed", false))
	var squad_color := String(selected_squad.get("color", ""))
	var carried := int(selected_squad.get("carried", 0))
	var capacity := int(selected_squad.get("capacity", 1))

	match level_id:
		"meadow_002":
			if has_selection and not is_deployed:
				return "A slot is occupied. Return that team before sending this color out."
			if has_selection:
				if carried > 0:
					return "Seed aboard. Return to the nest to free the only slot for the other color."
				return "This squad collects only its matching color. Find that seed, then bring it home."
			if active_squad_count > 0:
				return "A squad is still out. Select it to collect or return it before switching colors."
			if delivered_count > 0:
				return "One seed is home. The free slot is ready for the squad matching the other color."
			return "One slot, two colors: match each squad to its seed, then return before switching teams."

		"meadow_003":
			if has_selection and not is_deployed:
				return "The only slot is occupied. Return that squad before sending this carrier."
			if has_selection:
				if squad_color == "amber":
					if carried >= capacity:
						return "Amber load full. Return to deliver both seeds and free the only slot."
					return "Amber carries two. Collect both amber seeds before returning for one full haul."
				if squad_color == "teal":
					if carried > 0:
						return "Teal seed aboard. Return home; amber's pair needs a separate two-seed trip."
					return "Teal carries one. Collect its seed, return, then send amber for the pair."
			if active_squad_count > 0:
				return "A carrier is still out. Select it to harvest or return it before switching squads."
			if delivered_count > 0:
				return "A load is home. Use the free slot for the other color's remaining seeds."
			return "Amber carries two: make one full two-seed trip, then send teal on its separate run."

		"meadow_004":
			if has_selection and not is_deployed:
				return "A slot is occupied. Return a team before deploying this squad."
			if has_selection:
				if active_squad_count >= slot_capacity:
					if carried > 0:
						return "Seed aboard. Both slots are in use; return this team to free one."
					return "Both squads can work in the field. Match each squad to its own color, then return them."
				if carried > 0:
					return "Seed secured. The second slot is free—deploy the other color before returning."
				return "One slot is free. Deploy the other color so both teams can work before returning."
			if active_squad_count >= slot_capacity:
				return "Both slots are busy. Select a team to collect or return it before changing squads."
			if active_squad_count > 0:
				return "One squad is already out. Deploy the other color into the free slot before returning."
			return "Two slots and one narrow pass: deploy amber and teal before bringing either team home."

		"meadow_005":
			if not has_selection:
				if active_squad_count >= slot_capacity:
					return "Both slots are busy. Select a team to harvest or return; the third color waits."
				if active_squad_count > 0:
					return "One team is out. Use the free slot for a second color; the third waits for a return."
				if delivered_count > 0:
					return "A return has freed a slot. Rotate the remaining colors; amber can carry its pair together."
				return "Three colors, two slots. Amber carries its pair; teal and coral each need their own trip."

			if not is_deployed:
				if active_squad_count >= slot_capacity:
					return "Both slots are occupied. Return a deployed team before sending this color out."
				return "One slot is free. Deploy this color now; the third team waits for a return."

			if squad_color == "amber":
				if carried >= capacity:
					return "Amber load is full. Deliver both seeds, then rotate in the waiting color."
				if active_squad_count >= slot_capacity:
					return "Amber can carry both seeds. Fill its second space before returning; the third color waits."
				if carried > 0:
					return "One amber seed aboard. Collect its partner; the free slot can run teal or coral."
				return "Amber can carry both seeds in one trip. Use the other slot for teal or coral."

			if carried > 0:
				if active_squad_count >= slot_capacity:
					return "Load aboard. Return a team to rotate in the third color."
				return "Seed aboard. Use the free slot for another color before rotating the third."
			if active_squad_count >= slot_capacity:
				return "Both slots are occupied. Return a team before deploying the third color."
			return "One slot is free. Deploy another color; the third team waits for a return."

	return ""
