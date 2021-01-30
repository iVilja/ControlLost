extends Node

func sigmoid(t: float):
	return 1.0 / (1.0 + exp(-t))
