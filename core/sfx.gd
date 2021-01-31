extends Node
enum {
	BO = 0,
	CONSTRUCT, UNCONSTRUCT,
	GENERAL_UI_01, GENERAL_UI_02,
	NEXT_STAGE,
	PLAYER_MOVE, PLAYER_SELECT,
	WRONG_MOVE,
	PUSH,
	RESTART, RETURN, UNDO,
	STONE_MOVE_START, STONE_SELECT,
	TURN_AROUND,
	TYPEWRITER
}

const sounds = [
	["BO_01", "BO_02", "BO_03", "BO_04"],
	"construct", "unconstruct",
	"General_UI_01", "General_UI_02",
	"nextstage",
	"player_move", ["player_select_01", "player_select_02", "player_select_03"],
	"wrongmove",
	["push_01", "push_02", "push_03"],
	"restart", "return", ["undo_01", "undo_02", "undo_03"],
	["stone_movestart_01", "stone_movestart_02", "stone_movestart_03"],
	["stone_select_01", "stone_select_02", "stone_select_03"],
	"turnaround",
	["Typewriter_01", "Typewriter_02", "Typewriter_03", "Typewriter_04"]
]

var cached = {}


func load_sfx(s: String):
	return load("res://resources/audio/sfx/%s.wav" % s)


func cache(s: String):
	cached[s] = load_sfx(s)


func cache_list(ss):
	for s in ss:
		cache(s)


const AudioManager = preload("res://core/audio_manager.tscn")
var audio_manager = null
func _ready():
	audio_manager = AudioManager.instance()
	add_child(audio_manager)
	cache(sounds[PLAYER_MOVE])
	cache_list(sounds[PLAYER_SELECT])
	cache(sounds[RESTART])
	cache(sounds[RETURN])
	cache_list(sounds[STONE_MOVE_START])
	cache_list(sounds[STONE_SELECT])
	cache_list(sounds[TYPEWRITER])
	cache_list(sounds[UNDO])
	cache(sounds[WRONG_MOVE])
	play_background_noise()


func get_sound(t, i = -1):
	if audio_manager != null:
		var s = sounds[t]
		if typeof(s) == TYPE_ARRAY:
			s = s[i] if i >= 0 else Math.rand_from(s)
		var sound = cached[s] if s in cached else load_sfx(s)
		return sound
	return null


func play(t, i = -1):
	var sound = get_sound(t, i)
	if sound != null:
		audio_manager.play(sound)


var noise = preload("res://resources/audio/sfx/amb_mine.wav")
func play_background_noise():
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.volume_db = -5.0
	player.stream = noise
	player.play()


var keeping_players = {}
func keep_playing(t, i = -1):
	if t in keeping_players:
		return
	var sound = get_sound(t, i)
	if sound != null:
		var player = audio_manager.play(sound)
		keeping_players[t] = player
		player.connect("finished", self, "on_stopped", [player, t])


func stop_keeping(t):
	if t in keeping_players:
		var p = keeping_players[t]
		p.stop()
		keeping_players.erase(t)


func on_stopped(player, t):
	if player.is_connected("finished", self, "on_stopped"):
		player.disconnect("finished", self, "on_stopped")
	if t in keeping_players:
		keeping_players.erase(t)


func switch_bgm(toggled):
	var bgm2 = audio_manager.bgm_player2
	if bgm2 == null:
		return
	var bgm1 = audio_manager.bgm_player
	if not toggled:
		var t = bgm1
		bgm1 = bgm2
		bgm2 = t
	bgm2.play()
	bgm2.seek(bgm1.get_playback_position())
	bgm1.stop()
