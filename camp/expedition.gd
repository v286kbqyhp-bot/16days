extends RefCounted

var _equipment: Dictionary = {}
var _owned: Dictionary = {}
var _party: Array = []


static func create(characters: Array, weapons: Array, crests: Array):
	if characters.size() != 3:
		return null
	for group in [characters, weapons, crests]:
		var seen := {}
		for id in group:
			if not id is String or id.strip_edges().is_empty() or seen.has(id):
				return null
			seen[id] = true
	var camp = new()
	camp._owned = {"weapon": weapons.duplicate(), "crest": crests.duplicate()}
	for id in characters:
		camp._equipment[id] = {"weapon": null, "crest": null}
	return camp


func loadout(id: String) -> Dictionary:
	return _equipment.get(id, {}).duplicate()


func equip(id: String, slot: String, item: Variant) -> Error:
	if not _party.is_empty():
		return ERR_LOCKED
	if not _equipment.has(id) or not _owned.has(slot):
		return ERR_INVALID_PARAMETER
	if item != null:
		if not _owned[slot].has(item):
			return ERR_DOES_NOT_EXIST
		for wearer in _equipment:
			if wearer != id and _equipment[wearer][slot] == item:
				return ERR_ALREADY_IN_USE
	_equipment[id][slot] = item
	return OK


func depart(ids: Array) -> Error:
	if not _party.is_empty():
		return ERR_LOCKED
	if ids.is_empty() or ids.size() > 3:
		return ERR_INVALID_PARAMETER
	var selected := {}
	var members := []
	for id in ids:
		if selected.has(id) or not _equipment.has(id):
			return ERR_INVALID_PARAMETER
		var gear: Dictionary = _equipment[id]
		if gear.weapon == null or gear.crest == null:
			return ERR_UNCONFIGURED
		selected[id] = true
		members.append({"id": id, "weapon": gear.weapon, "crest": gear.crest})
	_party = members
	return OK


func party_snapshot() -> Array:
	return _party.duplicate(true)


func return_to_camp() -> Error:
	if _party.is_empty():
		return ERR_UNCONFIGURED
	_party.clear()
	return OK
