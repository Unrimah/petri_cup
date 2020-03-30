extends Node2D

const NUM_GRASS = 10
const NUM_RABBITS = 3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var grass_scene = preload("res://GrassBody2D.tscn")
	var rabbit_scene = preload("res://RabbitBody2D.tscn")

	for i in NUM_GRASS:
		var grass_node = grass_scene.instance()
		grass_node.position.x = randi() % 1200
		grass_node.position.y = randi() % 600
		grass_node.add_to_group("grass")
		add_child(grass_node)
	
	for i in NUM_RABBITS:
		var rabbit_node = rabbit_scene.instance()
		rabbit_node.position.x = randi() % 1200
		rabbit_node.position.y = randi() % 600
		rabbit_node.add_to_group("rabbits")
		add_child(rabbit_node)
	
#	_position_rab_and_grow()
	
	
func _position_rab_and_grow():
#	var posX = randi() % 1366
#	var posY = randi() % 768
	get_node("KrolikVashyMat").set_place(randi() % 1200, randi() % 600)
	get_node("TRAVAblin").set_place(randi() % 1200, randi() % 600)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
