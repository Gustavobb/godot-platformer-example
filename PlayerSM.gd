extends "res://SM.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wallslide")
	call_deferred("set_state", states_dict.idle)
	
func _logic(delta):
	parent.handle_input()
	parent.apply_input_movement(delta)
	parent.apply_gravity(delta)
	parent.apply_movement()

func _handle_current_state():
	match current_state:
		states_dict.idle: 
			if parent.velocity: return states_dict.run 
			elif !parent.is_on_floor(): return states_dict.jump if parent.velocity.y < 0 else states_dict.fall
			
		states_dict.run: 
			if !parent.velocity: return states_dict.idle
			elif !parent.is_on_floor(): return states_dict.jump if parent.velocity.y < 0 else states_dict.fall
			
		states_dict.jump: if parent.velocity.y > 0: return states_dict.fall
		
		states_dict.fall: 
			if parent.is_on_floor(): return states_dict.idle
			elif parent.velocity.y < 0: return states_dict.jump

	return

func _enter_state(new_state):
	match new_state:
		states_dict.idle: parent.animation_player.play("Idle")
		
		states_dict.run: parent.animation_player.play("Run")
		
		states_dict.jump: 
			parent.animation_player.play("Jump")
			parent.is_off_ground = true
			
		states_dict.fall: 
			parent.animation_player.play("Fall")
			parent.is_off_ground = true
			if [states_dict.idle, states_dict.run].has(old_state): parent.coyote_timer.start()

func _exit_state(old_state):
	match old_state:
		states_dict.fall: 
			parent.is_off_ground = false

func _input(event):
	if event.is_action_pressed("ui_up"):
		if !parent.is_off_ground and !parent.coyote_timer.is_stopped():
			parent.coyote_timer.stop()
			parent.apply_jump()
