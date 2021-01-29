extends Node2D
class_name Stage

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager

func _ready():
	game = GameManager.new()
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	add_child(game)
