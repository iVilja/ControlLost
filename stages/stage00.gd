extends Node2D

const GameManager = preload("res://core/game_manager.gd")


func _ready():
	var game = GameManager.new()
	var terrains = $Terrains.get_children()
	var blocks = $Blocks.get_children()
	$Battleground.initialize(game, terrains, blocks)
