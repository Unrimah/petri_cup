extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	_position_rab_and_grow()
	
func _position_rab_and_grow():
#	var posX = randi() % 1366
#	var posY = randi() % 768
	get_node("KrolikVashyMat").set_place(randi() % 1366, randi() % 768)
	get_node("TRAVAblin").set_place(randi() % 1366, randi() % 768)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
