extends "res://stages/stage.gd"


onready var special = $Blocks/Special
onready var trigger1 = $Terrains/Trigger
onready var trigger2 = $Terrains/Trigger2

func _ready():
	._ready()
	special.check_interact_func = funcref(self, "check_special")
	special.interact_func = funcref(self, "interact_special")


func check_special(_player):
	return special.enabled and trigger1.activated and trigger2.activated


func interact_special(_player):
	var di = Math.rand_from([0, 3])
	special.move_with_logics(di)
	yield(special, "moved")
	var step = {
		"type": "move",
		"block": special,
		"direction": di
	}
	special.emit_signal("interacted", step)



func end():
	SFX.stop_keeping(SFX.LAVA)
	.end()


func _on_Stage3_initialized():
	SFX.keep_playing(SFX.LAVA)
