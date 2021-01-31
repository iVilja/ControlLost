extends Node


const creature_sfx = [
	preload("res://resources/audio/sfx/creature_01.wav"),
	preload("res://resources/audio/sfx/creature_02.wav")
]
const machine_sfx = preload("res://resources/audio/sfx/machine.wav")
const drone_sfx = [
	preload("res://resources/audio/sfx/random_drone_01.wav"),
	preload("res://resources/audio/sfx/random_drone_02.wav"),
	preload("res://resources/audio/sfx/random_drone_03.wav"),
	preload("res://resources/audio/sfx/random_drone_04.wav")
]

func _ready():
	assert(Global.audio_manager == null)
	Global.audio_manager = self


func _exit_tree():
	if Global.current_game == self:
		Global.current_game = null


func start_timers():
	timers = []
	start_timer(55, creature_sfx)
	start_timer(47, [machine_sfx])
	start_timer(33, drone_sfx)


func clear_timers():
	for timer in timers:
		timer.stop()
	timers = []


var timers = []
func start_timer(interval, sounds):
	var timer = Timer.new()
	timer.wait_time = interval * (randf() + 0.5)
	timer.connect("timeout", self, "on_timeout", [timer, interval, sounds])
	timers.append(timer)


onready var sfx_players = $SoundEffects.get_children()
var sfx_player_i = -1


func get_sfx_player():
	while true:
		sfx_player_i = (sfx_player_i + 1) % sfx_players.size()
		var player = sfx_players[sfx_player_i]
		if not player.playing:
			return player

func play(sound):
	var player = get_sfx_player()
	player.stream = sound
	player.play()
	return player


func on_timeout(timer, interval, sounds):
	timer.wait_time = interval
	play(Math.rand_from(sounds))
	timer.start()


func load_bgm(bgm):
	return load("res://resources/audio/music/%s.wav" % bgm)

onready var bgm_player = $BGM
onready var bgm_player2 = $BGM2
func play_bgm(bgm, bgm2 = ""):
	bgm_player.stream = load_bgm(bgm)
	bgm_player.play()
	if bgm2.empty():
		bgm_player2.stream = null
	else:
		bgm_player2.stream = load_bgm(bgm2)


func stop_bgm():
	bgm_player.stop()
	bgm_player2.stop()
