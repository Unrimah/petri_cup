extends RigidBody2D

const MAX_HEALTH = 1500
const FUCKING_HEALTH = 1200
const HUNGRY_HEALTH = 700
const SEARCH_RANGE = 700
const EATING_DISTANCE = 40
const COPULATING_DISTANCE = 40
const COPULATION_LOSS = HUNGRY_HEALTH / 2
const COPULATION_PERIOD = 2000
const POPULATION_LIMIT = 4
const LIFE_PERIOD = COPULATION_PERIOD * 10

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
			wolf_walk()
		ACT.COPULATE:
			wolf_to_fuck()
		ACT.DIE:
			wolf_die()
		ACT.TO_EAT:
			wolf_to_eat()		

func select_action():
	life_timer -= 1
	if life_timer == 0:
		return ACT.DIE
	health -= 1
	if copulation_timer > 0:
		copulation_timer -= 1
	elif health >= FUCKING_HEALTH:
		return ACT.COPULATE
	if health >= HUNGRY_HEALTH:
		return ACT.WALK
	if health <  1:
		return ACT.DIE
	return ACT.TO_EAT
	
	
func wolf_to_eat():
	var rabbit_list = get_tree().get_nodes_in_group("rabbits")
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	for rabbit in rabbit_list:
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
	if distance < EATING_DISTANCE:
		wolf_eat(TARGET)
	else:
		global_translate(direction)

func wolf_to_fuck():
	var wolves_list = get_tree().get_nodes_in_group("wolves")
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	var animals_in_range = 1
	for wolf in wolves_list:
		if wolf.get_instance_id() == self.get_instance_id():
			continue
		var wolf_distance = self.position.distance_to(wolf.position)
		if wolf_distance < SEARCH_RANGE:
			animals_in_range += 1
		if wolf.copulation_timer > 0:
			continue
		if distance > wolf_distance:
			distance = wolf_distance
			TARGET = wolf
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
		wolf_copulate(TARGET)
	else:
		global_translate(direction)

func wolf_walk():
	var direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	global_translate(direction)

func wolf_eat(food):
	self.health += 2 * food.health
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	food.queue_free()
	
func wolf_copulate(wolf):
	if wolf.copulation_timer > 0:
		return
	copulation_timer = COPULATION_PERIOD
	self.health -= COPULATION_LOSS
	wolf.health -= COPULATION_LOSS
	get_node("..").create_new_wolf(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func wolf_die():
	queue_free()
	
	


	
	
