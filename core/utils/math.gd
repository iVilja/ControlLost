tool
extends Node

func sigmoid(t: float) -> float:
	return 1.0 / (1.0 + exp(-t))


func rand_from(arr: Array):
	return arr[randi() % arr.size()]


func get_polygon_center(polygon) -> Vector2:
	var n = polygon.size()
	var center = Vector2.ZERO
	for i in range(n):
		center += polygon[i]
	center /= n
	return center
