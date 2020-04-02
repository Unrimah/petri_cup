extends RigidBody2D

var MAX_HEALTH
var FUCKING_HEALTH
var HUNGRY_HEALTH
var SEARCH_RANGE
var EATING_DISTANCE
var COPULATING_DISTANCE
var COPULATION_LOSS
var COPULATION_PERIOD
var POPULATION_LIMIT
var LIFE_PERIOD

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
			animal_walk()
		ACT.COPULATE:
			animal_to_fuck()
		ACT.DIE:
			animal_die()
		ACT.TO_EAT:
			animal_to_eat()		

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
	
	
func animal_to_eat():
	var food_list = get_tree().get_nodes_in_group("food??")#Groups of food
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	for food in food_list:
		var food_distance = self.position.distance_to(food.position)
		if distance > food_distance:
			distance = food_distance
			TARGET = food
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
		animal_eat(TARGET)
	else:
		global_translate(direction)

func animal_to_fuck():
	var animals_list = get_tree().get_nodes_in_group("wolve")
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	var animals_in_range = 1
	for animal in animals_list:
		if animal.get_instance_id() == self.get_instance_id():
			continue
		var animal_distance = self.position.distance_to(animal.position)
		if animal_distance < SEARCH_RANGE:
			animals_in_range += 1
		if animal.copulation_timer > 0:
			continue
		if distance > animal_distance:
			distance = animal_distance
			TARGET = animal
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
		animal_copulate(TARGET)
	else:
		global_translate(direction)

func animal_walk():
	var direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	global_translate(direction)

func animal_eat(food):
	self.health += 2 * food.health
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	food.queue_free()
	
func animal_copulate(animal):
	if animal.copulation_timer > 0:
		return
	copulation_timer = COPULATION_PERIOD
	health -= COPULATION_LOSS
	animal.copulation_timer = COPULATION_PERIOD
	animal.health -= COPULATION_LOSS
	get_node("..").create_new_animal(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func animal_die():
	queue_free()

