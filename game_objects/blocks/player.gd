tool
extends "res://game_objects/blocks/block.gd"
class_name Player

var groupable_blocks = {}
var grouped_block_offsets = []
var grouped_block_scales = []
var grouped_blocks = []


func _ready():
	type_name = "player"


func get_pos_ids():
	var ret = []
	for each in pos_ids:
		ret.append(each + moved_pos)
	for block in grouped_blocks:
		for each in block.pos_ids:
			ret.append(each + block.moved_pos)
	return ret


func group_blocks(add_step = true):
	if groupable_blocks.size() == 0:
		return
	SFX.play(SFX.CONSTRUCT)
	grouped_blocks.clear()
	grouped_block_offsets.clear()
	grouped_block_scales.clear()
	for block in groupable_blocks:
		grouped_blocks.append(block)
		grouped_block_offsets.append(block.position - position)
		grouped_block_scales.append(block.scale / scale)
		block.set_states()
		block.is_grouped = true
	is_grouped = true
	if add_step:
		var step = {
			"type": "group",
			"grouped": true,
			"player": self
		}
		game.steps.append([step])
	print("Grouped. ", grouped_blocks)


func ungroup_all(add_step = true):
	if grouped_blocks.size() == 0:
		return
	SFX.play(SFX.UNCONSTRUCT)
	for block in grouped_blocks:
		block.clear_availables()
		block.set_states()
		block.is_grouped = false
	grouped_blocks.clear()
	grouped_block_offsets.clear()
	grouped_block_scales.clear()
	is_grouped = false
	if add_step:
		var step = {
			"type": "group",
			"grouped": false,
			"player": self
		}
		game.steps.append([step])
	print("Ungrouped.")


func get_all_blocks():
	var ret = [self]
	for block in grouped_blocks:
		ret.append(block)
	return ret


func _physics_process(delta):
	._physics_process(delta)
	for i in grouped_blocks.size():
		grouped_blocks[i].position = position + grouped_block_offsets[i]
		grouped_blocks[i].scale = scale * grouped_block_scales[i]
		


func set_moved_pos(value):
	var diff = value - moved_pos
	.set_moved_pos(value)
	for block in grouped_blocks:
		block.moved_pos += diff


func restore_original():
	.restore_original()
	grouped_blocks.clear()
	grouped_block_offsets.clear()
	grouped_block_scales.clear()
