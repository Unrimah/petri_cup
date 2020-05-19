extends Node2D

const X_RES = 1200
const Y_RES = 680
const FPS = 60 # 60 default

const GRASS_DELAY = .2
const RABBITS_DELAY = 5

const NUM_GRASS = 100
const NUM_RABBITS = 40
const NUM_WOLVES = 4

const MAX_PLANTS = 500

var grass_scene = preload("res://Grass1.tscn")
var rabbit_scene = preload("res://Rabbit1.tscn")
var wolf_scene = preload("res://Wolf1.tscn")

var plants_time_counter
var animals_time_counter
var Log = Logger.get_logger("Node2D.gd", "res://logs/", "animals")

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	plants_time_counter = 0
	animals_time_counter = 0
	
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
	plants_autogenesis(delta)
	animals_autogenesis(delta)

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

func animals_autogenesis(delta):
	animals_time_counter += delta
	if animals_time_counter >= RABBITS_DELAY:
		animals_time_counter = 0
		if get_tree().get_nodes_in_group("animals").size() == 0:
			for i in 4:
				var position = Vector2(randi() % X_RES, randi() % Y_RES)
				create_new_rabbit(position)
			return
		if get_tree().get_nodes_in_group("wolves").size() == 0:
			if get_tree().get_nodes_in_group("rabbits").size() > NUM_RABBITS:
				for i in NUM_WOLVES:
					var position = Vector2(randi() % X_RES, randi() % Y_RES)
					create_new_wolf(position)
	
func plants_autogenesis(delta):
	plants_time_counter += delta
	if plants_time_counter >= GRASS_DELAY:
		plants_time_counter = 0
		if get_tree().get_nodes_in_group("plants").size() < MAX_PLANTS:
			var position = Vector2(randi() % X_RES, randi() % Y_RES)
			create_new_grass(position)
