extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if linear_velocity.length() > 0 and linear_velocity.length() < 5: # 目的是让球快速停下来 而不是缓慢等待
		sleeping = true
