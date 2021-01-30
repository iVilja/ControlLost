extends Node2D
class_name MainScene

signal stage_entered

export var entering_time = 3.5

const Stage = preload("res://stages/stage.gd")
var current_stage: Stage = null

onready var lan_animation = $Characters/Lan/AnimatedSprite
onready var player = $Player

var entering = -1.0
func enter_stage(stage: Stage):
	stage.scale = Vector2.ZERO
	add_child(stage)
	entering = 0.0
	player.game = stage.game


func update_stage_loading(delta):
	if entering < 0:
		return
	entering += delta
	if entering >= entering_time:
		current_stage.scale = Vector2.ONE
		entering = -1.0
		emit_signal("stage_entered")
		return
	var t = Math.sigmoid(entering / entering_time * 12.0 - 6.0)
	current_stage.scale = Vector2.ONE * t


func start(stage_name: String):
	if stage_name == null or stage_name.empty():
		Global.goto_scene("res://scenes/ending.tscn")
		return
	var stage = load("res://stages/%s.tscn" % stage_name)
	if current_stage != null:
		current_stage.queue_free()
	current_stage = stage.instance()
	enter_stage(current_stage)
	yield(self, "stage_entered")
	if current_stage.header_image != null:
		$UI/StageName.texture = current_stage.header_image
	current_stage.initialize()
	yield(current_stage, "initialized")
	current_stage.game.connect("direction_changed", self, "_on_direction_changed")


func _ready():
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
	update_stage_loading(delta)
