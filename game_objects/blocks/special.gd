tool
extends "res://game_objects/blocks/block.gd"
class_name SpecialBlock

var check_interact_func: FuncRef = null
var interact_func: FuncRef = null


func _ready():
	type_name = "special"
	._ready()


func check_interact(player):
	if check_interact_func != null:
		return check_interact_func.call_func(player)
	return false


func interact(player):
	if interact_func != null:
		return interact_func.call_func(player)
	return .interact(player)
