extends Node2D
class_name Stage

signal initialized

export var stage_name = ""
export var next_stage = ""
export (Texture)var header_image

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager
var player: Node2D
var scripts = ""


func _ready():
	game = GameManager.new()
	game.stage = self
	player = $Player


func initialize():
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	add_child(game)
	SFX.audio_manager.start_timers()
	yield(get_tree(), "idle_frame")
	emit_signal("initialized")


func start():
	print("%s started" % stage_name)


func end():
	Global.current_scene.start(next_stage)
