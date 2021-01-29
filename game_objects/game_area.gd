tool
extends Node2D

class_name GameArea

export var is_up = true setget is_up_set

var original_pos = Vector2(0, 0) setget original_pos_set
var pos = Vector2(0, 0)

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager = null


func original_pos_set(value):
	original_pos = value
	pos = value


func is_up_set(value):
	is_up = value
	rotation_degrees = 0 if value else 180
