extends "res://stages/stage.gd"

func _ready():
	._ready()
	scripts_after = Global.load_scripts("res://resources/scripts/stage-x-after.res")
