extends CharacterBody2D
class_name Worm

var speed = 7
var facing_right = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if $AnimatedSprite2D.frame == 0:
		velocity.x = 0
	else:
		velocity.x = speed
	if not is_on_floor():
		velocity.y += (gravity * delta)*3.5

	if !$LedgeCheck.is_colliding() and is_on_floor() or is_on_wall():
		flip()
		
	move_and_slide()

func flip():
	facing_right = !facing_right
	scale.x = abs(scale.x) * -1
	if facing_right:
		speed = abs(speed)
	else:
		speed = abs(speed) * -1
