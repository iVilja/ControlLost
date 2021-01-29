tool
extends Area2D
class_name Terrain

export var is_blocking = false
var pos_ids = []
const GameManager = preload("res://core/game_manager.gd")
var game: GameManager

func will_block(block):
	return is_blocking
