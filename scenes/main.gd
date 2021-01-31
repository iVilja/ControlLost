extends Node2D
class_name MainScene

signal stage_entered
signal stage_exited

export var entering_time = 1.8
export var exiting_time = 1.8

const DEFAULT_STAGE = "stage-3"

const Stage = preload("res://stages/stage.gd")
var current_stage: Stage = null

onready var player = $Player
onready var ui_node = $UI
onready var characters = $Characters
onready var background = $Background
onready var original_player_position = player.position

var entering = -1.0
var entering_player_start = Vector2()
var entering_player_target = Vector2()
var showing_background = null
func enter_stage(stage: Stage):
	stage.scale = Vector2.ZERO
	add_child(stage)
	entering = 0.0
	player.clear_state()
	player.game = stage.game
	player.enabled = false
	player.scale = stage.player.scale
	player.update_sprite()
	entering_player_start = player.position
	entering_player_target = stage.player.position
	showing_background = null
	stage.player.queue_free()


func update_stage_entering(delta):
	if entering < 0:
		return
	entering += delta
	if entering >= entering_time:
		current_stage.scale = Vector2.ONE
		player.position = entering_player_target
		entering = -1.0
		player.initialize(current_stage.game)
		player.enabled = true
		emit_signal("stage_entered")
		return
	var t1 = entering / entering_time
	if (showing_background == null or showing_background.ended) and t1 >= 0.7:
		showing_background = NodeTransform.fade_in(background, BACKGROUND_SHOWING_TIME)
	var t2 = Math.sigmoid(t1 * 12.0 - 6.0)
	current_stage.scale = Vector2.ONE * t2
	player.position = entering_player_start.linear_interpolate(entering_player_target, t2)


const MAX_STAGE_SCALE = 35
const EXITING_FADING_START = 0.25
var exiting = -1.0
var exiting_player_start = Vector2()
var exiting_player_target = Vector2()
var exiting_stage_start = Vector2()
var exiting_stage_target = Vector2()
var exiting_fading = null
func exit_stage(stage: Stage, has_next_stage = false):
	SFX.audio_manager.clear_timers()
	if has_next_stage:
		SFX.play(SFX.NEXT_STAGE)
	exiting = 0.0
	exiting_player_start = player.position
	exiting_player_target = original_player_position if Triangle.get_is_up(
		player.pos_ids[0] + player.moved_pos
	) else original_player_position + Vector2.UP * Triangle.TriangleSize.y * 2 / 3
	exiting_stage_start = stage.position  # always ZERO
	exiting_stage_target = exiting_player_target - exiting_player_start + exiting_stage_start
	player.clear_state()
	player.game = null
	player.enabled = false
	hide_ui()
	NodeTransform.fade_out(characters, UI_SHOWING_TIME)
	showing_background = NodeTransform.fade_out(background, BACKGROUND_HIDING_TIME)


func update_stage_exiting(delta):
	if exiting < 0:
		return
	exiting += delta
	if exiting >= exiting_time:
		current_stage.visible = false
		player.position = exiting_player_target
		exiting = -1.0
		exiting_fading = null
		if showing_background != null and !showing_background.ended:
			showing_background.stop_fading()
			showing_background = null
		emit_signal("stage_exited")
		return
	var t = Math.sigmoid(exiting / exiting_time * 12.0 - 6.0)
	if exiting_fading == null && t > EXITING_FADING_START:
		exiting_fading = NodeTransform.fade_out(current_stage, exiting_time - exiting)
	var pp = exiting_player_start.linear_interpolate(exiting_player_target, t)
	var scale = 1.0 + t * MAX_STAGE_SCALE
	player.position = pp
	current_stage.position = (exiting_stage_target - exiting_stage_start) * scale + pp - exiting_player_target
	current_stage.scale = Vector2.ONE * scale


func start(stage_name: String):
	if stage_name == null or stage_name.empty():
		Global.goto_scene("res://scenes/ending.tscn")
		return
	var stage = load("res://stages/%s.tscn" % stage_name)
	if current_stage != null:
		exit_stage(current_stage, true)
		yield(self, "stage_exited")
		current_stage.queue_free()
	current_stage = stage.instance()
	enter_stage(current_stage)
	yield(self, "stage_entered")
	if current_stage.header_image != null:
		$UI/StageName.texture = current_stage.header_image
	NodeTransform.fade_in(characters, UI_SHOWING_TIME)
	current_stage.start()
	yield(current_stage, "initialized")
	show_ui()
	current_stage.game.connect("direction_changed", self, "_on_direction_changed")
	dialog_cover.visible = false


var UI_SHOWING_TIME = 0.5
var BACKGROUND_SHOWING_TIME = 4.0
var BACKGROUND_HIDING_TIME = 1.0
func show_ui():
	NodeTransform.fade_in(ui_node, UI_SHOWING_TIME)


func hide_ui():
	NodeTransform.fade_out(ui_node, UI_SHOWING_TIME)


func _ready():
	background.visible = false
	ui_node.visible = false
	characters.visible = false
	dialog_cover.visible = false
	var stage_name = DEFAULT_STAGE  # for debugging
	if Global.loading_stage != null:
		stage_name = Global.loading_stage
		Global.loading_stage = null
	start(stage_name)


func _on_Home_pressed():
	SFX.play(SFX.RETURN)
	Global.goto_scene("res://scenes/title.tscn")


func _on_Restart_pressed():
	SFX.play(SFX.RESTART)
	current_stage.game.restart()


func _on_GoBack_pressed():
	current_stage.game.go_back()


onready var magnet = $UI/Magnet
func _on_Magnet_pressed():
	if player.is_grouped:
		player.ungroup_all()
	else:
		player.group_blocks()


func _on_direction_changed(value):
	var frame = lan_animation.frame
	lan_animation.play("idle" if value < 0 else "move-%d" % value)
	lan_animation.frame = frame


func _physics_process(delta):
	update_stage_entering(delta)
	update_stage_exiting(delta)


onready var lan_animation = $Characters/Lan/AnimatedSprite
onready var bo_animation = $Characters/Bo/AnimatedSprite
onready var lan_dialog = $Characters/Lan/Dialog
onready var bo_dialog = $Characters/Bo/Dialog
onready var dialog_cover = $Characters/DialogCover

var is_ending = false
signal said(character, content)
func say(character, content):
	if character != "Bo" and character != "Lan":
		yield(get_tree(), "idle_frame")
		emit_signal("said", character, content)
	var is_bo = character == "Bo"
	var dialog = bo_dialog if is_bo else lan_dialog
	if is_bo and not is_ending:
		bo_animation.play("talking" if randi() % 2 == 0 else "talking-2")
	print("%s: %s" % [character, content])
	dialog.type(content)
	yield(dialog, "typing_completed")
	if is_bo and not is_ending:
		bo_animation.play("idle")
	emit_signal("said", character, content)

var waiting_for_click = false
signal cover_clicked
signal scripts_completed
func run_scripts(scripts, ending = false):
	# TODO: delete it
	scripts = null
	if scripts == null:
		yield(get_tree(), "idle_frame")
		emit_signal("scripts_completed")
		return
	is_ending = ending
	hide_ui()
	dialog_cover.visible = true
	for line in scripts:
		var character = line[0]
		match character:
			"B": character = "Bo"
			"": character = "Lan"
			"N": character = "Narrative"
		var content = line[1]
		say(character, content)
		yield(self, "said")
		yield(get_tree().create_timer(0.4), "timeout")
		waiting_for_click = true
		yield(self, "cover_clicked")
		waiting_for_click = false
	lan_dialog.clear()
	bo_dialog.clear()
	dialog_cover.visible = false
	emit_signal("scripts_completed")


func _on_DialogCover_gui_input(event):
	if waiting_for_click and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			emit_signal("cover_clicked")


func _on_lan_characters_typed(chars):
	SFX.play(SFX.TYPEWRITER)


var last_bo_typed = -1.0
func _on_bo_characters_typed(chars):
	if is_ending:
		return
	var t = OS.get_ticks_usec()
	if t - last_bo_typed > 500:
		last_bo_typed = t
		SFX.play(SFX.BO)
