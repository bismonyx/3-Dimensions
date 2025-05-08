extends AnimatableBody3D
@export var max_health = 5
var health = 0

func _ready() -> void:
	health = max_health

func take_dmg(amount):
	health = health - amount 
	if health <= 0:
		queue_free()
