extends RigidBody2D

const MAX_HEALTH = 1000
const FUCKING_HEALTH = 700
const HUNGRY_HEALTH = 500
const SEARCH_RANGE = 500
const EATING_DISTANCE = 5
const COPULATING_DISTANCE = 40
const GRASS_FEED_RATE = 500
const COPULATION_LOSS = HUNGRY_HEALTH / 2
const COPULATION_PERIOD = 300
const POPULATION_LIMIT = 16
const LIFE_PERIOD = COPULATION_PERIOD * 20

enum ACT {
	DIE,
	WALK,
	COPULATE,
	TO_EAT
}

var health
var copulation_timer
var life_timer

# Called when the node enters the scene tree for the first time.
func _ready():
	health = HUNGRY_HEALTH
	copulation_timer = COPULATION_PERIOD
	life_timer = LIFE_PERIOD

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action():
		ACT.WALK:
			rabbit_walk()
		ACT.COPULATE:
			rabbit_to_fuck()
		ACT.DIE:
			rabbit_die()
		ACT.TO_EAT:
			rabbit_to_grass()		

func select_action():
	life_timer -= 1
	if life_timer == 0:
		return ACT.DIE
	health -= 1
	if copulation_timer > 0:
		copulation_timer -= 1
	elif health >= FUCKING_HEALTH:
		return ACT.COPULATE
	if self.health >= HUNGRY_HEALTH:
		return ACT.WALK
	if self.health <  1:
		return ACT.DIE
	return ACT.TO_EAT
	
	
func rabbit_to_grass():
	var grass_list = get_tree().get_nodes_in_group("grass")
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	for grass in grass_list:
		var grass_distance = self.position.distance_to(grass.position)
		if distance > grass_distance:
			distance = grass_distance
			TARGET = grass
	if distance == SEARCH_RANGE:
		direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	else:
		direction = Vector2(0,0)
		if (self.position.x < TARGET.position.x) and (self.position.x < 1200):
			direction.x = 1
		if (self.position.y < TARGET.position.y) and (self.position.y < 600):
			direction.y = 1
		if (self.position.x > TARGET.position.x) and (self.position.x >= 0):
			direction.x = -1
		if (self.position.y > TARGET.position.y) and (self.position.y >= 0):
			direction.y = -1
	if distance < EATING_DISTANCE:
		rabbit_eat(TARGET)
	else:
		global_translate(direction)

func rabbit_to_fuck():
	var rabbits_list = get_tree().get_nodes_in_group("rabbits")
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	var animals_in_range = 1
	for rabbit in rabbits_list:
		if rabbit.get_instance_id() == self.get_instance_id():
			continue
		var rabbit_distance = self.position.distance_to(rabbit.position)
		if rabbit_distance < SEARCH_RANGE:
			animals_in_range += 1
		if rabbit.copulation_timer > 0:
			continue
		if distance > rabbit_distance:
			distance = rabbit_distance
			TARGET = rabbit
	if (distance == SEARCH_RANGE) or (animals_in_range >= POPULATION_LIMIT):
		direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	else:
		direction = Vector2(0,0)
		if (self.position.x < TARGET.position.x) and (self.position.x < 1200):
			direction.x = 1
		if (self.position.y < TARGET.position.y) and (self.position.y < 600):
			direction.y = 1
		if (self.position.x > TARGET.position.x) and (self.position.x >= 0):
			direction.x = -1
		if (self.position.y > TARGET.position.y) and (self.position.y >= 0):
			direction.y = -1
	if (animals_in_range < POPULATION_LIMIT) and (distance < COPULATING_DISTANCE):
		rabbit_copulate(TARGET)
	else:
		global_translate(direction)

func rabbit_walk():
	var direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	global_translate(direction)

func rabbit_eat(food):
	food.free()
	self.health += GRASS_FEED_RATE
	if health > MAX_HEALTH:
		health = MAX_HEALTH

func rabbit_copulate(rabbit):
	if rabbit.copulation_timer > 0:
		return
	copulation_timer = COPULATION_PERIOD
	health -= COPULATION_LOSS
	rabbit.copulation_timer = COPULATION_PERIOD
	rabbit.health -= COPULATION_LOSS
	get_node("..").create_new_rabbit(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func rabbit_die():
	queue_free()
