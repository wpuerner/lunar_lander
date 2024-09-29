extends Camera2D

@export var lander: Node2D

func _process(_delta):
	global_position.x = lander.global_position.x
