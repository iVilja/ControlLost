extends Node2D

class_name Battleground

var rows = [
	3,
	4, 4,
	5, 5,
	6, 6,
	5, 5,
	4, 4,
	3
]
const GameManager = preload("res://core/game_manager.gd")
var game: GameManager = null


func is_up(row: int) -> bool:
	return row % 2 == 1


# Only works for our current model.
const BlockSize = Vector2(128, 112)
func pixels2pos(pixels: Vector2, is_up: bool) -> Vector2:
	var y = int(round(pixels.y / BlockSize.y))
	var row = 0
	if y == -3:
		assert(!is_up)
		row = 0
	elif y == 3:
		assert(is_up)
		row = 11
	else:
		row = 5 + y * 2 + (0 if is_up else 1)
	
	var t = ((row + 1) / 2) % 2 == 1
	var x = int(round((pixels.x - (
		(BlockSize.x / 2) if t else 0
	)) / BlockSize.x))
	var column = floor(rows[row] / 2) + x
	var pos = Vector2(row, column)
	print(pixels, pos)
	return pos


func initialize(game, terrains, blocks):
	self.game = game
	for i in range(rows.size()):
		for j in range(rows[i]):
			game.terrains[Vector2(i, j)] = null
	var center = self.position
	for terrain in terrains:
		terrain.game = game
		terrain.original_pos = pixels2pos(terrain.position - center, terrain.is_up)
		game.terrains[terrain.original_pos] = terrain
	for block in blocks:
		block.game = game
		block.original_pos = pixels2pos(block.position - center, block.is_up)
		game.blocks[block.original_pos] = block
