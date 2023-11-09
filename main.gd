extends Node

var fuel_bar: ProgressBar
var level: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.fuel = 1000
	fuel_bar = get_node("VBoxContainer/FuelBar")
	
	level = load("res://level.tscn").instantiate()
	add_child(level)
	connect_signals(level)

func _process(delta):
	fuel_bar.set_value(Globals.fuel)


func on_lander_crashed():
	get_node("GameOverControl").show()


func on_lander_landed():
	get_node("LevelCompletedControl").show()


func _on_reset_button_pressed():
	get_node("GameOverControl").hide()
	
	level.queue_free()
	level = load("res://level.tscn").instantiate()
	add_child(level)
	connect_signals(level)
	
func connect_signals(level: Node):
	var lander = level.get_node("Lander")
	lander.crashed.connect(on_lander_crashed)
	lander.landed.connect(on_lander_landed)
