extends RigidBody2D

const MAX_HEALTH = 100
const SEARCH_RANGE = 500
const EATING_DISTANCE = 5

enum ACT {
	DIE,
	WALK,
	EAT,
	TO_GRASS
}

var health
#onready var TARGET = get_node("../TRAVAblin").position

# Called when the node enters the scene tree for the first time.
func _ready():
	self.health = MAX_HEALTH

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action():
		ACT.WALK:
			rabbit_walk()
		ACT.EAT:
			pass
		ACT.DIE:
			rabbit_die()
		ACT.TO_GRASS:
			rabbit_to_grass()		

func select_action():
	while self.health <= 100 and self.health > 0.1:
		self.health -= 0.1
		if self.health < (MAX_HEALTH / 2):
			return ACT.TO_GRASS
		elif self.health >= (MAX_HEALTH / 2):
			return ACT.WALK
		else:
			return ACT.DIE
	
	
	
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
func rabbit_walk():
	var direction = Vector2(2*(randi() % 2)-1,2*(randi() % 2)-1)
	global_translate(direction)

func rabbit_eat(food):
	food.free()
	self.health += 10
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func rabbit_die():
	self.free()
	


	
	
