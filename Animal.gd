extends RigidBody2D

var X_RES
var Y_RES
var FPS

var MAX_HEALTH
var BASE_HEALTH
var FUCKING_HEALTH
var HUNGRY_HEALTH
var SPEED_RUN
var SPEED_WALK
var SPEED_CRAWL
var SEARCH_RANGE
var EATING_DISTANCE
var COPULATING_DISTANCE
var COPULATION_LOSS
var COPULATION_PERIOD
var POPULATION_LIMIT
var LIFE_PERIOD
var SELF_GROUP
var FOOD_GROUP

enum ACT {
	DIE,
	WALK,
	COPULATE,
	TO_EAT
}

var health
var copulation_timer
var life_timer
var walk_position

func _init_animal():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_init_animal()
	health = HUNGRY_HEALTH
	copulation_timer = COPULATION_PERIOD
	life_timer = LIFE_PERIOD
	X_RES = get_node("..").X_RES
	Y_RES = get_node("..").Y_RES
	FPS = get_node("..").FPS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action():
		ACT.WALK:
			animal_walk(delta)
		ACT.COPULATE:
			flush_walk_position()
			animal_to_fuck(delta)
		ACT.TO_EAT:
			flush_walk_position()
			animal_to_eat(delta)
		ACT.DIE:
			flush_walk_position()
			animal_die()

func flush_walk_position():
	walk_position = Vector2(0, 0)

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
	
	
func animal_to_eat(delta):
	var food_list = get_tree().get_nodes_in_group(FOOD_GROUP)#Groups of food
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	for food in food_list:
		var food_distance = self.position.distance_to(food.position)
		if distance > food_distance:
			distance = food_distance
			TARGET = food
	if distance == SEARCH_RANGE:
		animal_walk(delta)
		return
	if distance < EATING_DISTANCE:
		animal_eat(TARGET)
		return
#	direction = Vector2(0,0)
	direction = Vector2((TARGET.position.x - position.x)/distance,(TARGET.position.y - position.y)/distance)
#	if (self.position.x < TARGET.position.x) and (self.position.x < X_RES):
#		direction.x = 1
#	if (self.position.y < TARGET.position.y) and (self.position.y < Y_RES):
#		direction.y = 1
#	if (self.position.x > TARGET.position.x) and (self.position.x >= 0):
#		direction.x = -1
#	if (self.position.y > TARGET.position.y) and (self.position.y >= 0):
#		direction.y = -1
	direction *= SPEED_RUN * delta
	global_translate(direction)

func animal_to_fuck(delta):
	var animals_list = get_tree().get_nodes_in_group(SELF_GROUP)
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
		animal_walk(delta)
		return
	if (animals_in_range < POPULATION_LIMIT) and (distance < COPULATING_DISTANCE):
		animal_copulate(TARGET)
		return
	direction = Vector2((TARGET.position.x - position.x)/distance,(TARGET.position.y - position.y)/distance)
#	direction = Vector2(0,0)
#	if (self.position.x < TARGET.position.x) and (self.position.x < X_RES):
#		direction.x = 1
#	if (self.position.y < TARGET.position.y) and (self.position.y < Y_RES):
#		direction.y = 1
#	if (self.position.x > TARGET.position.x) and (self.position.x >= 0):
#		direction.x = -1
#	if (self.position.y > TARGET.position.y) and (self.position.y >= 0):
#		direction.y = -1
	direction *= SPEED_RUN * delta
	global_translate(direction)

func animal_walk(delta):
	if (self.position.distance_to(walk_position) < 2):
		flush_walk_position()
#	var X
#	var Y
#	var walk_distance
#	var walk_direction
	if (walk_position == Vector2(0, 0)):
		var walk_direction = randf() * 2 * PI
		var walk_distance = randi() % SEARCH_RANGE + 1 # To prevent X/0
		var X = walk_distance * sin(walk_direction) + self.position.x
		var Y = walk_distance * cos(walk_direction) + self.position.y
		walk_position = Vector2(X, Y)
	var walk_distance = sqrt(pow((walk_position.x - position.x), 2) + pow((walk_position.y - position.y), 2))
	var direction = Vector2((walk_position.x - position.x)/walk_distance,(walk_position.y - position.y)/walk_distance)
	direction *= SPEED_WALK * delta
	global_translate(direction)

func animal_eat(food):
	health += food.BASE_HEALTH + food.health
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	food.queue_free()
	
func _create_new_animal(position):
	pass
	
func animal_copulate(animal):
	if animal.copulation_timer > 0:
		return
	copulation_timer = COPULATION_PERIOD
	health -= COPULATION_LOSS
	animal.copulation_timer = COPULATION_PERIOD
	animal.health -= COPULATION_LOSS
	_create_new_animal(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func animal_die():
	queue_free()