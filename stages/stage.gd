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


func load_scripts(file_name):
	var file = File.new()
	if not file.file_exists(file_name):
		return null
	file.open(file_name, file.READ)
	var ret = []
	while not file.eof_reached():
		var csv = file.get_csv_line()
		ret.append(csv)
	file.close()
	print(file_name)
	print(ret)
	return ret


func _ready():
	game = GameManager.new()
	game.stage = self
	player = $Player
	scripts_before = load_scripts("res://resources/scripts/%s.csv" % stage_name)
	scripts_after = load_scripts("res://resources/scripts/%s-after.csv" % stage_name)


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
	Global.current_scene.run_scripts(scripts_before)
	print("%s started" % stage_name)


func end():
	Global.current_scene.start(next_stage)
