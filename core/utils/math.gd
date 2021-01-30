extends Node

func sigmoid(t: float) -> float:
	return 1.0 / (1.0 + exp(-t))


func rand_from(arr: Array):
	return arr[randi() % arr.size()]
