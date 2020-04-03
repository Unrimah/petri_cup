extends Node2D

const X_RES = 1200
const Y_RES = 680

const NUM_GRASS = 20
const NUM_RABBITS = 10
const NUM_WOLVES = 2
const GRASS_DELAY = 25

var grass_scene = preload("res://Grass1.tscn")
var rabbit_scene = preload("res://Rabbit1.tscn")
var wolf_scene = preload("res://Wolf1.tscn")

var grass_counter

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	grass_counter = 0
	
	for i in NUM_GRASS:
		var position = Vector2(randi() % X_RES, randi() % Y_RES)
		create_new_grass(position)
	
	for i in NUM_RABBITS:
		var position = Vector2(randi() % X_RES, randi() % Y_RES)
		create_new_rabbit(position)
	
	for i in NUM_WOLVES:
		var position = Vector2(randi() % X_RES, randi() % Y_RES)
		create_new_wolf(position)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	grass_counter += 1
	if grass_counter >= GRASS_DELAY:
		grass_counter = 0
		var position = Vector2(randi() % X_RES, randi() % Y_RES)
		create_new_grass(position)

func create_new_grass(position):
	var grass_node = grass_scene.instance()
	grass_node.position = position
	add_child(grass_node)

func create_new_rabbit(position):
	var rabbit_node = rabbit_scene.instance()
	rabbit_node.position = position
	add_child(rabbit_node)

func create_new_wolf(position):
	var wolf_node = wolf_scene.instance()
	wolf_node.position = position
	add_child(wolf_node)
