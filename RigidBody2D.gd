extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MOVE = 1
var EAT = 2
var DIE = 0
#var TARGET = Vector2(13, 5)
onready var TARGET = get_node("../TRAVAblin").position

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match select_action():
		MOVE:
			rabbit_move()
		EAT:
			rabbit_eat()
		DIE:
			rabbit_die()		

func select_action():
	return MOVE
	
func rabbit_move():
	TARGET = get_node("../TRAVAblin").position
	var X = self.position.x
	var Y = self.position.y
	var t = Vector2(2,2)
	if (X > TARGET.x):
		t.x = -2
	if (Y > TARGET.y):
		t.y = -2
	global_translate(t)

func rabbit_eat():
	#rabbit_move()
	var food = get_node("../TRAVAblin")
	food.delete_food()
	
func set_place(x, y):
	self.position = Vector2(x, y)
	
func rabbit_die():
	pass