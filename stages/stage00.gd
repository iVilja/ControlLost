extends Node2D

const GameManager = preload("res://core/game_manager.gd")


func _ready():
	var game = GameManager.new()
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	print(game.blocks)
	print(game.terrains)
