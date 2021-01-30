tool
extends Area2D
class_name Terrain

signal interacted(to_break)

export var is_blocking = false
export var auto_interactable = false
var pos_ids = []
const GameManager = preload("res://core/game_manager.gd")
var game: GameManager


func will_block(block):
	return is_blocking


func enclose(block):
	if not block.enabled:
		return false
	var block_pos_ids = block.get_pos_ids()
	if block_pos_ids == null or block_pos_ids.size() == 0:
		return false
	for block_pos_id in block_pos_ids:
		if not (block_pos_id + block.moved_pos in pos_ids):
			return false
	return true


func check_interact(block):
	if auto_interactable:
		return enclose(block)
	return false


func interact(block):
	emit_signal("interacted", false)
