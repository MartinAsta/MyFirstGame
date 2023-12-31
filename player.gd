extends CharacterBody2D
class_name Player

const SPEED = 100.0
const JUMP_HEIGHT = -140.0
var max_jump = 1
var remaining_jump = 1
@onready var ladderCheckLeft = $LadderCheckLeft
@onready var ladderCheckRight = $LadderCheckRight
@onready var sprite = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum { MOVE, CLIMB }
var state = MOVE

func _physics_process(delta):
	var x_input = Input.get_axis("ui_left", "ui_right")
	var y_input = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(delta)
		CLIMB: climb_state(y_input)
	
	move_left_or_right(x_input)
	move_and_slide()

func hit_flower():
	max_jump += 1

func is_on_ladder():
	return ladderCheckLeft.is_colliding() and ladderCheckLeft.get_collider() is Ladder or ladderCheckRight.is_colliding() and ladderCheckRight.get_collider() is Ladder

func move_left_or_right(direction):
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if direction < 0:
		sprite.flip_h = true
	elif direction > 0:
		sprite.flip_h = false

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += (gravity * delta)/2
		if remaining_jump == 0 and velocity.y > 0:
			velocity.y += 2
	else:
		remaining_jump = max_jump

func move_state(delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	apply_gravity(delta)
	if (is_on_floor() or remaining_jump > 0) and Input.is_action_just_pressed("ui_up"):
		remaining_jump -= 1
		velocity.y = JUMP_HEIGHT
	elif Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y = -25
	elif Input.is_action_pressed("ui_down"):
		velocity.y += 15
	
func climb_state(input):
	if not is_on_ladder():
		state = MOVE
		remaining_jump = max_jump
	velocity.y = input*50
