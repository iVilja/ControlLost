extends Node2D
class_name Stage

export var next_stage = ""

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager


func _ready():
	game = GameManager.new()
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	game.stage = self
	add_child(game)


func end():
	Global.current_scene.start(next_stage)
