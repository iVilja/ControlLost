extends Control

signal characters_typed(chars)
signal typing_completed(text)


export var typing_speed = 12

onready var content = $Content

func _ready():
	clear()


var started = -1.0
var speed = 0.0
func type(text, speed_scale = 1.0):
	visible = true
	content.text = text
	content.visible_characters = 0
	started = 0.0
	speed = typing_speed * speed_scale


func _physics_process(delta):
	if started < 0:
		return
	started += delta
	var vc = int(floor(started * speed))
	var old_vc = content.visible_characters
	if old_vc != vc:
		emit_signal("characters_typed", content.text.substr(old_vc, vc - old_vc))
		content.visible_characters = vc
	if vc >= content.text.length():
		started = -1.0
		emit_signal("typing_completed", content.text)

func clear():
	content.text = ""
	visible = false
