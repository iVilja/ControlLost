extends Stage


func end():
	var t = NodeTransform.fade_out(self, 2.0)
	yield(t, "transformed")
	.end()
