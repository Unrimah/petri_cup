extends RigidBody2D

const MAX_HEALTH = 5000
const FUCKING_HEALTH = 700
const HUNGRY_HEALTH = 600
const SEARCH_RANGE = 700
const EATING_DISTANCE = 40
const COPULATING_DISTANCE = 40
const COPULATION_LOSS = HUNGRY_HEALTH / 2

enum ACT {
	DIE,
	WALK,
	COPULATE,
	TO_EAT
}

var health

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = HUNGRY_HEALTH

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
	self.health -= 1
	if self.health >= FUCKING_HEALTH:
		return ACT.COPULATE
	if self.health >= HUNGRY_HEALTH:
		return ACT.WALK
	if self.health <=  1:
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
	for wolf in wolves_list:
		if wolf.get_instance_id() == self.get_instance_id():
			continue
		var wolf_distance = self.position.distance_to(wolf.position)
		if distance > wolf_distance:
			distance = wolf_distance
			TARGET = wolf
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
		wolf_copulate(TARGET)
	else:
		global_translate(direction)

func wolf_walk():
	var direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	global_translate(direction)

func wolf_eat(food):
	self.health += food.health
	if health > MAX_HEALTH:
		health = MAX_HEALTH
	food.queue_free()
	
func wolf_copulate(wolf):
	self.health -= COPULATION_LOSS
	wolf.health -= COPULATION_LOSS
	get_node("..").create_new_wolf(self.position)
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func wolf_die():
	queue_free()
	
	


	
	
