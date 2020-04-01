extends Node2D

const NUM_GRASS = 20
const NUM_RABBITS = 10
const NUM_WOLVES = 3
const GRASS_DELAY = 25

var grass_scene = preload("res://GrassBody2D.tscn")
var rabbit_scene = preload("res://RabbitBody2D.tscn")
var wolf_scene = preload("res://WolfBody2D.tscn")

var grass_counter

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	grass_counter = 0
	
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
	
	for i in NUM_WOLVES:
		var wolf_node = wolf_scene.instance()
		wolf_node.position.x = randi() % 1200
		wolf_node.position.y = randi() % 600
		wolf_node.add_to_group("wolves")
		add_child(wolf_node)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grass_counter += 1
	if grass_counter >= GRASS_DELAY:
		grass_counter = 0
		var grass_node = grass_scene.instance()
		grass_node.position.x = randi() % 1200
		grass_node.position.y = randi() % 600
		grass_node.add_to_group("grass")
		add_child(grass_node)

func create_new_rabbit(position):
	var rabbit_node = rabbit_scene.instance()
	rabbit_node.position = position
	rabbit_node.add_to_group("rabbits")
	add_child(rabbit_node)

func create_new_wolf(position):
	var wolf_node = wolf_scene.instance()
	wolf_node.position = position
	wolf_node.add_to_group("wolves")
	add_child(wolf_node)
