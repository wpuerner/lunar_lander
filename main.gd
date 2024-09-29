extends Node

@export var lander: Node2D

var level: Node

func _on_reset_button_pressed():
	get_node("GameOverControl").hide()
	
	level.queue_free()
	level = load("res://level.tscn").instantiate()
	add_child(level)

func _on_lander_crashed():
	get_node("GameOverControl").show()

func _on_lander_landed():
	get_node("LevelCompletedControl").show()
