extends Node

class_name GameManager

var terrains = {}
var blocks = {}

var hovered_block = null
var dragging_block = null


func _init():
	assert(Global.current_game == null)
	Global.current_game = self


func end():
	assert(Global.current_game == self)
	Global.current_game = null


func all_positions():
	return terrains.keys()


func get_terrain(x, y):
	return terrains[Vector2(x, y)]


func get_block(x, y):
	var pos = Vector2(x, y)
	if pos in blocks:
		return blocks[pos]
	return null
