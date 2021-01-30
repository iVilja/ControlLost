extends Node2D
class_name Stage

signal initialized

export var next_stage = ""
export (Texture)var header_image

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager
var player: Node2D


func _ready():
	game = GameManager.new()
	game.stage = self
	player = $Player


func initialize():
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	add_child(game)
	yield(get_tree(), "idle_frame")
	emit_signal("initialized")


func end():
	Global.current_scene.start(next_stage)
