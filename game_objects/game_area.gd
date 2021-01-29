tool
extends Node2D

class_name GameArea

export var is_up = true setget set_is_up

var original_pos = Vector2(0, 0) setget set_original_pos
var pos = Vector2(0, 0)

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager = null


func set_original_pos(value):
	original_pos = value
	pos = value


func set_is_up(value):
	is_up = value
	rotation_degrees = 0 if value else 180
