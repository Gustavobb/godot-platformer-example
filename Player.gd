extends KinematicBody2D

export(int) var ACCELERATION = 1000
export(int) var MAX_SPEED = 200
export(int) var FRICTION = 700
export(int) var GRAVITY = 10
export(int) var JUMP_HEIGHT = -800
const FLOOR = Vector2(0, -1)

onready var animation_player = $AnimationPlayer
onready var ray_left = $Rays/Left
onready var ray_right = $Rays/Right
onready var sprite = $Sprite
onready var coyote_timer = $Coyote

var velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
var BODY_MASS;

var slidin_the_wall = false
var is_off_ground = false

func apply_gravity(delta):
	BODY_MASS = 300
	if !is_on_floor(): BODY_MASS = 250
	if slidin_the_wall: BODY_MASS = 20
	velocity.y += GRAVITY * BODY_MASS * delta
	
func apply_input_movement(delta):
	var _from = input_velocity * MAX_SPEED if input_velocity else Vector2.ZERO
	var _to = ACCELERATION * delta if input_velocity else FRICTION * delta
	velocity = velocity.move_toward(_from, _to)
	
func apply_movement():
	velocity = move_and_slide(velocity, FLOOR)

func apply_jump():
	velocity.y = JUMP_HEIGHT
	
func apply_wall_jump():
	velocity.y = JUMP_HEIGHT * 0.8
	velocity.x = -JUMP_HEIGHT * 0.4 if !sprite.flip_h else JUMP_HEIGHT * 0.4
	
func handle_input():
	input_velocity = Vector2.ZERO
	input_velocity.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_velocity = input_velocity.normalized()
	if input_velocity: 
		sprite.flip_h = true if input_velocity.x < 0 and !slidin_the_wall else false

func can_wall_slide():
	var left = _is_on_wall(ray_left) and input_velocity.x < 0
	var right = _is_on_wall(ray_right) and input_velocity.x > 0
	
	if left or right: return [left, right] 
	return
	
func _is_on_wall(ray2d):
	for ray in ray2d.get_children():
		if ray.is_colliding(): return true
	
	return false
