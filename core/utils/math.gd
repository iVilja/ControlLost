extends Node

func sigmoid(t: float) -> float:
	return 1.0 / (1.0 + exp(-t))
