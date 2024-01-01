extends CharacterBody2D
class_name Player

const SPEED = 85.0
const JUMP_HEIGHT = -140.0
var max_jump = 1
var remaining_jump = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum { MOVE, CLIMB }
var state = MOVE
var buffered_jump = false
var coyote_jump = false

@onready var ladderCheckLeft = $LadderCheckLeft
@onready var ladderCheckRight = $LadderCheckRight
@onready var sprite = $AnimatedSprite2D
@onready var jumpBufferTimer = $JumpBufferTimer
@onready var coyoteTimer = $CoyoteTimer

func _physics_process(delta):
	match state:
		MOVE: move_state(delta)
		CLIMB: climb_state()

func hit_flower():
	max_jump += 1

func jump():
	remaining_jump -= 1
	velocity.y = JUMP_HEIGHT

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
		velocity.y += (gravity * delta)/2.5
		if remaining_jump == 0 and velocity.y > 0:
			velocity.y += 2
	else:
		remaining_jump = max_jump

func move_state(delta):
	var x_input = Input.get_axis("ui_left", "ui_right")
	move_left_or_right(x_input)
	
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	apply_gravity(delta)
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		if is_on_floor() or coyote_jump:
			jump()
			buffered_jump = false
			coyote_jump = false
		elif remaining_jump > 0:
			jump()
		elif not buffered_jump:
			buffered_jump = true
			jumpBufferTimer.start()

	elif Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y = -25
	elif Input.is_action_pressed("ui_down"):
		velocity.y += 15

	var wasOnFloor = is_on_floor()
	move_and_slide()
	var justLeftGround = not is_on_floor() and wasOnFloor
	if justLeftGround and velocity.y >= 0:
		coyote_jump = true
		coyoteTimer.start()

func climb_state():
	if not is_on_ladder():
		state = MOVE
		remaining_jump = max_jump
	var x_input = Input.get_axis("ui_left", "ui_right")
	var y_input = Input.get_axis("ui_up", "ui_down")
	velocity.y = y_input*50
	move_left_or_right(x_input)
	
	move_and_slide()

func _on_jump_buffer_timer_timeout():
	buffered_jump = false

func _on_coyote_timer_timeout():
	coyote_jump = false
