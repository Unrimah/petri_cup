extends RigidBody2D

var X_RES
var Y_RES
var FPS

var MAX_HEALTH
var BASE_HEALTH
var FUCKING_HEALTH
var HUNGRY_HEALTH
var SPEED_RUN # Pixels / sec
var SPEED_WALK
var SPEED_CRAWL
var CONSUMPTION_RUN
var CONSUMPTION_WALK
var CONSUMPTION_CRAWL
var CONSUMPTION_IDLE
var CONSUMPTION_SLEEP
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
var walk_position_is_set = false

func _init_animal():
	pass

func _create_new_animal(position):
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("animals")
	_init_animal()
	FPS = get_node("..").FPS
	health = HUNGRY_HEALTH
	copulation_timer = COPULATION_PERIOD
	life_timer = LIFE_PERIOD
	X_RES = get_node("..").X_RES
	Y_RES = get_node("..").Y_RES
	walk_position = Vector2(0, 0)
	walk_position_is_set = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action(delta):
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
	walk_position_is_set = false
	walk_position = Vector2(0, 0)

func select_action(delta):
	life_timer -= delta
	if life_timer <= 0:
		return ACT.DIE
	if copulation_timer > 0:
		copulation_timer -= delta
	elif health >= FUCKING_HEALTH:
		return ACT.COPULATE
	if health >= HUNGRY_HEALTH:
		return ACT.WALK
	if health <  1:
		return ACT.DIE
	return ACT.TO_EAT

func loop_closest_position(trg_pos):
	var ret_pos = trg_pos
	if (abs(position.x - trg_pos.x + X_RES) < abs(position.x - trg_pos.x)):
		ret_pos.x = trg_pos.x - X_RES
	if (abs(position.x - trg_pos.x - X_RES) < abs(position.x - trg_pos.x)):
		ret_pos.x = trg_pos.x + X_RES
	if (abs(position.y - trg_pos.y + Y_RES) < abs(position.y - trg_pos.y)):
		ret_pos.y = trg_pos.y - Y_RES
	if (abs(position.y - trg_pos.y - Y_RES) < abs(position.y - trg_pos.y)):
		ret_pos.y = trg_pos.y + Y_RES
	return ret_pos

func normalize_position():
	position.x = normalize_X(position.x)
	position.y = normalize_Y(position.y)
	
func normalize_X(value):
	while (value < 0):
		value += X_RES
	while (value > X_RES):
		value -= X_RES
	return value

func normalize_Y(value):
	while (value < 0):
		value += Y_RES
	while (value > Y_RES):
		value -= Y_RES
	return value

func animal_to_eat(delta):
	var food_list = get_tree().get_nodes_in_group(FOOD_GROUP)#Groups of food
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	var trg_loop_pos
	
	health -= CONSUMPTION_RUN * delta
	for food in food_list:
		trg_loop_pos = loop_closest_position(food.position)
		var food_distance = self.position.distance_to(trg_loop_pos)
		if distance > food_distance:
			distance = food_distance
			TARGET = food
	if distance == SEARCH_RANGE:
		animal_walk(delta)
		return
	if distance < EATING_DISTANCE:
		animal_eat(TARGET)
		return
	trg_loop_pos = loop_closest_position(TARGET.position)
	direction = Vector2((trg_loop_pos.x - position.x)/distance,(trg_loop_pos.y - position.y)/distance)
	direction *= SPEED_RUN * delta
	global_translate(direction)
	normalize_position()

func animal_to_fuck(delta):
	var animals_list = get_tree().get_nodes_in_group(SELF_GROUP)
	var distance = SEARCH_RANGE
	var direction
	var TARGET
	var trg_loop_pos

	health -= CONSUMPTION_RUN * delta
	var animals_in_range = 1
	for animal in animals_list:
		if animal.get_instance_id() == self.get_instance_id():
			continue
		trg_loop_pos = loop_closest_position(animal.position)
		var animal_distance = self.position.distance_to(trg_loop_pos)
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
	trg_loop_pos = loop_closest_position(TARGET.position)
	direction = Vector2((trg_loop_pos.x - position.x)/distance,(trg_loop_pos.y - position.y)/distance)
	direction *= SPEED_RUN * delta
	global_translate(direction)
	normalize_position()

func animal_walk(delta):
	health -= CONSUMPTION_WALK * delta
	if (self.position.distance_to(walk_position) < 2):
		flush_walk_position()
	if (!walk_position_is_set):
		var walk_direction = randf() * 2 * PI
		var walk_distance = randi() % (SEARCH_RANGE / 2) + 1 # To prevent X/0
		var X = normalize_X(walk_distance * sin(walk_direction) + self.position.x)
		var Y = normalize_Y(walk_distance * cos(walk_direction) + self.position.y)
		walk_position = Vector2(X, Y)
		walk_position = loop_closest_position(walk_position)
		walk_position_is_set = true
	var walk_distance = sqrt(pow((walk_position.x - position.x), 2) + pow((walk_position.y - position.y), 2))
	var transition = Vector2((walk_position.x - position.x)/walk_distance,(walk_position.y - position.y)/walk_distance)
	transition *= SPEED_WALK * delta
	global_translate(transition)
	normalize_position()

func animal_eat(food):
	health += food.BASE_HEALTH + food.health
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
	_create_new_animal(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func animal_die():
	queue_free()
