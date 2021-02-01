extends Control


const image02 = preload("res://textures/ui/opening/02.png")
const image03 = preload("res://textures/ui/opening/03.png")

onready var image = $Image
onready var dialog = $Dialog
onready var icon = $icon

func _ready():
	var scripts = Global.load_scripts("res://resources/scripts/opening.res")
	if scripts != null:
		run_scripts(scripts)


signal said(character, content)
var is_bo = false
func say(character, content):
	if character != "Bo" and character != "Lan":
		yield(get_tree(), "idle_frame")
		emit_signal("said", character, content)
	is_bo = character == "Bo"
	print("%s: %s" % [character, content])
	dialog.type(content)
	yield(dialog, "typing_completed")
	emit_signal("said", character, content)


var waiting_for_click = false
signal cover_clicked
func run_scripts(scripts):
	var n = scripts.size()
	for i in range(n):
		dialog.clear()
		icon.hide()
		if i == 0:
			var t = NodeTransform.fade_in(image, 1.0)
			yield(t, "transformed")
		elif i == 3:
			var t = NodeTransform.fade_out(image, 1.0)
			yield(t, "transformed")
			image.texture = image02
			t = NodeTransform.fade_in(image, 1.0)
			yield(t, "transformed")
		elif i == 8:
			var t = NodeTransform.fade_out(image, 1.0)
			yield(t, "transformed")
			image.texture = image03
			t = NodeTransform.fade_in(image, 1.0)
			yield(t, "transformed")
		var line = scripts[i]
		var character = line[0]
		match character:
			"B": character = "Bo"
			"": character = "Lan"
			"N": character = "Narrative"
		var content = line[1]
		say(character, content)
		yield(self, "said")
		yield(get_tree().create_timer(0.4), "timeout")
		icon.show()
		waiting_for_click = true
		yield(self, "cover_clicked")
		icon.hide()
		waiting_for_click = false
	dialog.clear()
	Global.loading_stage = "stage-1"
	Global.goto_scene("res://scenes/main.tscn")


func _on_Background_gui_input(event):
	if waiting_for_click and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			emit_signal("cover_clicked")


var last_bo_typed = -1.0
func _on_Dialog_characters_typed(chars):
	if is_bo:
		var t = OS.get_ticks_usec()
		if t - last_bo_typed > 500:
			last_bo_typed = t
			SFX.play(SFX.BO)
	else:
		SFX.play(SFX.TYPEWRITER)
