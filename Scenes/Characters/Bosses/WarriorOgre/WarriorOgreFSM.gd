extends FiniteStateMachine

func _init():
	_add_state("idle")
	_add_state("chase")
	_add_state("hurt")
	_add_state("dead")
	_add_state("deadStart")
	_add_state("dash")
	_add_state("dizzy")
	_add_state("dizzyStart")
	_add_state("summon")
	_add_state("spinStart")
	_add_state("spin")
	_add_state("slam")


func _ready():
	set_state(states.idle)


# put the logic of the state
func _state_logic(_delta: float) -> void:
	if state == states.chase:
		parent.chase()
		parent.move()
	elif state == states.dash:
		parent.move()
	elif state == states.spin:
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
		states.dash:
			if not animation_player.is_playing():
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				if parent.dizzy:
					return states.dizzy
				else:
					return states.chase
		states.dizzyStart:
			if not animation_player.is_playing():
				return states.dizzy
		states.dizzy:
			if not parent.dizzy:
				return states.idle
		states.summon:
			if not animation_player.is_playing():
				return states.chase
		states.spinStart:
			if not animation_player.is_playing():
				return states.spin
		states.spin:
			if parent.spinning == false:
				return states.dizzyStart
		states.slam:
			if not animation_player.is_playing():
				return states.chase
		states.deadStart:
			if not animation_player.is_playing():
				return states.dead
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	match _new_state:
		states.idle:
			animation_player.play("Idle")
		states.chase:
			animation_player.play("Walk")
		states.dash:
			if parent.special_attacking:
				animation_player.play("ShieldDash")
			else:
				animation_player.play("Dash")
		states.dizzyStart:
			animation_player.play("DizzyStart")
		states.dizzy:
			animation_player.play("Dizzy")
		states.summon:
			animation_player.play("Summon")
		states.spinStart:
			animation_player.play("SpinStart")
		states.spin:
			animation_player.play("Spin")
		states.slam:
			animation_player.play("Slam")
		states.hurt:
			animation_player.play("Hurt")
			# cancel attack
			if parent.current_weapon and !parent.no_attack_cancel:
				parent.current_weapon.cancel_attack()
			parent.eyes_anim.play("Cancel")
		states.deadStart:
			# cancel attack
			if parent.current_weapon:
				parent.current_weapon.cancel_attack()
			parent.eyes_anim.play("Cancel")
			PlayerGlobal.player_score_current += parent.kill_points
			animation_player.play("DeathStart")
		states.dead:
			animation_player.play("Death")
			#parent.set_physics_process(false)
			parent.weapons.set_visible(false)
			parent.set_physics_process(false)
