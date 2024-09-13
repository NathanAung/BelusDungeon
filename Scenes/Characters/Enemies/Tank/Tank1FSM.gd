extends FiniteStateMachine

func _init():
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")
	_add_state("tired")
	_add_state("dash")


func _ready():
	set_state(states.idle)


# put the logic of the state
func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.chase()
		parent.move()


# get the state transition
func _get_transition() -> int:
	match state:
		states.idle:
			if parent.path:
				return states.chase
		states.chase:
			if parent.move_direction == Vector2.ZERO:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				if parent.tired:
					return states.tired
				else:
					return states.chase
		states.tired:
			if not parent.tired:
				return states.idle
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	match _new_state:
		states.idle:
			animation_player.play("Idle")
		states.chase:
			animation_player.play("Walk")
		states.tired:
			animation_player.play("Tired")
		states.hurt:
			animation_player.play("Hurt")
			# cancel attack
			if parent.current_weapon:
				parent.current_weapon.cancel_attack()
			parent.eyes_anim.play("Cancel")
		states.dead:
			# cancel attack
			if parent.current_weapon:
				parent.current_weapon.cancel_attack()
			parent.eyes_anim.play("Cancel")
			animation_player.play("Death")
			PlayerGlobal.player_score_current += parent.kill_points
			#parent.set_physics_process(false)
			parent.weapons.set_visible(false)
			set_process(false)
