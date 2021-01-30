extends Node2D
class_name MainScene

signal stage_entered
signal stage_exited

export var entering_time = 3.5
export var exiting_time = 4.5

const Stage = preload("res://stages/stage.gd")
var current_stage: Stage = null

onready var lan_animation = $Characters/Lan/AnimatedSprite
onready var player = $Player
onready var ui_node = $UI
onready var characters = $Characters
onready var background = $Background
onready var original_player_position = player.position

var entering = -1.0
var entering_player_start = Vector2()
var entering_player_target = Vector2()
func enter_stage(stage: Stage):
	stage.scale = Vector2.ZERO
	add_child(stage)
	entering = 0.0
	player.clear_state()
	player.game = stage.game
	player.enabled = false
	entering_player_start = player.position
	entering_player_target = stage.player.position
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
	var t = Math.sigmoid(entering / entering_time * 12.0 - 6.0)
	current_stage.scale = Vector2.ONE * t
	player.position = entering_player_start.linear_interpolate(entering_player_target, t)


const MAX_STAGE_SCALE = 35
const EXITING_FADING_START = 0.25
var exiting = -1.0
var exiting_player_start = Vector2()
var exiting_player_target = Vector2()
var exiting_stage_start = Vector2()
var exiting_stage_target = Vector2()
var exiting_fading = null
func exit_stage(stage: Stage):
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


func update_stage_exiting(delta):
	if exiting < 0:
		return
	exiting += delta
	if exiting >= exiting_time:
		current_stage.visible = false
		player.position = exiting_player_target
		exiting = -1.0
		exiting_fading = null
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
		exit_stage(current_stage)
		yield(self, "stage_exited")
		current_stage.queue_free()
	current_stage = stage.instance()
	enter_stage(current_stage)
	yield(self, "stage_entered")
	if current_stage.header_image != null:
		$UI/StageName.texture = current_stage.header_image
	current_stage.initialize()
	yield(current_stage, "initialized")
	show_ui()
	current_stage.game.connect("direction_changed", self, "_on_direction_changed")


var UI_SHOWING_TIME = 0.5
func show_ui():
	NodeTransform.fade_in(background, UI_SHOWING_TIME * 2)
	NodeTransform.fade_in(ui_node, UI_SHOWING_TIME)
	NodeTransform.fade_in(characters, UI_SHOWING_TIME)


func hide_ui():
	NodeTransform.fade_out(background, UI_SHOWING_TIME * 2)
	NodeTransform.fade_out(ui_node, UI_SHOWING_TIME)
	NodeTransform.fade_out(characters, UI_SHOWING_TIME)


func _ready():
	background.visible = false
	ui_node.visible = false
	characters.visible = false
	var stage_name = "stage-1"  # for debugging
	if Global.loading_stage != null:
		stage_name = Global.loading_stage
		Global.loading_stage = null
	start(stage_name)


func _on_Home_pressed():
	Global.goto_scene("res://scenes/title.tscn")


func _on_Restart_pressed():
	current_stage.game.restart()


func _on_GoBack_pressed():
	current_stage.game.go_back()


func _on_Magnet_pressed():
	pass # Replace with function body.


func _on_direction_changed(value):
	var frame = lan_animation.frame
	lan_animation.play("idle" if value < 0 else "move-%d" % value)
	lan_animation.frame = frame


func _physics_process(delta):
	update_stage_entering(delta)
	update_stage_exiting(delta)
