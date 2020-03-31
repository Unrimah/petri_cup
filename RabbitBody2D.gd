extends RigidBody2D

const MAX_HEALTH = 1000
const FUCKING_HEALTH = 700
const HUNGRY_HEALTH = 500
const SEARCH_RANGE = 500
const EATING_DISTANCE = 5
const COPULATING_DISTANCE = 40
const GRASS_FEED_RATE = 500
const COPULATION_LOSS = 200

enum ACT {
	DIE,
	WALK,
	COPULATE,
	TO_GRASS
}

var health

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = HUNGRY_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action():
		ACT.WALK:
			rabbit_walk()
		ACT.COPULATE:
			rabbit_to_fuck()
		ACT.DIE:
			rabbit_die()
		ACT.TO_GRASS:
			rabbit_to_grass()		

func select_action():
	self.health -= 1
	if self.health >= FUCKING_HEALTH:
		return ACT.COPULATE
	if self.health >= HUNGRY_HEALTH:
		return ACT.WALK
	if self.health <=  1:
		return ACT.DIE
	return ACT.TO_GRASS
	
	
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
	for rabbit in rabbits_list:
		if rabbit.get_instance_id() == self.get_instance_id():
			continue
		var rabbit_distance = self.position.distance_to(rabbit.position)
		if distance > rabbit_distance:
			distance = rabbit_distance
			TARGET = rabbit
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
	if distance < COPULATING_DISTANCE:
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
	self.health -= COPULATION_LOSS
	rabbit.health -= COPULATION_LOSS
	get_node("..").create_new_rabbit(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func rabbit_die():
	queue_free()
	
	


	
	
