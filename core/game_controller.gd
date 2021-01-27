extends Node

var current_selected = null

func clear_state():
	self.current_selected = null

func select(block):
	print(block)
	self.current_selected = block
