extends Node2D

const Stage = preload("res://stages/stage.gd")
var current_stage: Stage = null


func start(stage_name: String):
	if stage_name == null or stage_name.empty():
		Global.goto_scene("res://scenes/ending.tscn")
		return
	var stage = load("res://stages/%s.tscn" % stage_name)
	if current_stage != null:
		current_stage.queue_free()
	current_stage = stage.instance()
	add_child(current_stage)


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
