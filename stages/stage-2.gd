extends "res://stages/stage.gd"


onready var event_scripts = Global.load_scripts("res://resources/scripts/stage-2-event.res")


func _on_Stage2_initialized():
	for terrain in game.terrains:
		if terrain.type_name == "reflect":
			terrain.connect("interacted", self, "on_event")
			break


var event_envoked = false
func on_event(_step):
	if event_envoked:
		return
	var main = Global.current_scene
	main.run_scripts(event_scripts)
	yield(main, "scripts_completed")
	main.show_ui()
	event_envoked = true
