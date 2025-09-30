class_name CuerpoRigit
extends RigidBody2D

var destruccion = 0
var contador = 0

func _ready():
	global_position = Vector2(100, 200)
	linear_velocity = Vector2.ZERO

func _process(delta):
	if global_position.y > 1000:
		global_position = Vector2(100, 200)
		linear_velocity = Vector2.ZERO
