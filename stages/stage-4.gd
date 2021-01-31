extends "res://stages/stage.gd"


func _ready():
	# TODO: delete this
	next_stage = "stage-8"
	._ready()


func end():
	SFX.stop_keeping(SFX.LAVA)
	.end()


func _on_Stage4_initialized():
	SFX.keep_playing(SFX.LAVA)
