extends Node2D
class_name Stage

signal initialized

export var stage_name = ""
export var next_stage = ""
export (Texture)var header_image
export var bgm_normal = "dungeon22_normal"
export var bgm_other = "dungeon22_otherworld"

const GameManager = preload("res://core/game_manager.gd")
var game: GameManager
var player: Node2D
var scripts_before = null
var scripts_after = null


func _ready():
	game = GameManager.new()
	game.stage = self
	player = $Player
	scripts_before = Global.load_scripts("res://resources/scripts/%s.res" % stage_name)
	scripts_after = Global.load_scripts("res://resources/scripts/%s-after.res" % stage_name)


func initialize():
	var area = $Battleground/TrianglePolygonShape
	$Battleground.initialize(game, area)
	add_child(game)
	SFX.audio_manager.start_timers()
	SFX.audio_manager.play_bgm(bgm_normal, bgm_other)
	SFX.switch_bgm(not Triangle.get_is_up(Global.current_scene.player.pos_ids[0]))
	yield(get_tree(), "idle_frame")
	emit_signal("initialized")


func start():
	var main = Global.current_scene
	main.run_scripts(scripts_before)
	yield(main, "scripts_completed")
	initialize()
	print("%s started" % stage_name)


func clear_states():
	SFX.audio_manager.clear_timers()
	SFX.audio_manager.stop_bgm()


func end():
	clear_states()
	var main = Global.current_scene
	main.run_scripts(scripts_after, true)
	yield(main, "scripts_completed")
	print("%s ended" % stage_name)
	main.start(next_stage)
