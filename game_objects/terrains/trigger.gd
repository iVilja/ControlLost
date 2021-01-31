tool
extends "res://game_objects/terrains/terrain.gd"
class_name TriggerTerrain

export var excluded = ["normal"]

var last_checked = -1
func check_interact(block):
	var t = game.steps.size()
	assert(pos_ids.size() == 1)
	var pos = pos_ids[0]
	if t != last_checked:
		self.activated = false
	if block.type_name in excluded:
		return false
	for block_pos in block.pos_ids:
		if block.moved_pos + block_pos == pos:
			SFX.play(SFX.PUSH)
			self.activated = true
			break
	last_checked = game.steps.size()
	return false
