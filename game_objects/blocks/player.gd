tool
extends "res://game_objects/blocks/block.gd"
class_name Player

var grouped_blocks = []


func _ready():
	type_name = "player"


func get_pos_ids():
	var ret = pos_ids.duplicate()
	for each in grouped_blocks:
		ret.append_array(each.pos_ids)
	return ret
