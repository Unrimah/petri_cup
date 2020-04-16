extends StaticBody2D

var BASE_HEALTH
var health

func _init_plant():
	pass
	
func _create_new_plant(position):
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("plants")
	_init_plant()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
