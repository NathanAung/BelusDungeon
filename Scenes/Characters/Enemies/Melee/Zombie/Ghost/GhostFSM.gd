extends FiniteStateMachine

func _init():
	_add_state("idle")
	_add_state("chase")
	_add_state("chased")
	_add_state("hurt")
	_add_state("dead")
	_add_state("dash")
	_add_state("spawn")
	_add_state("revive")


func _ready():
	set_state(states.spawn)


# put the logic of the state
func _state_logic(_delta: float) -> void:
	if state == states.chase or state == states.chased:
		parent.chase()
		parent.move()


# get the state transition
func _get_transition() -> int:
	match state:
		states.spawn:
			if not animation_player.is_playing():
				return states.idle
		states.idle:
			if parent.path:
				return states.chase
		states.chase:
			if parent.move_direction == Vector2.ZERO:
				return states.idle
			elif parent.being_chased:
				return states.chased
		states.chased:
			if parent.move_direction == Vector2.ZERO:
				return states.idle
			elif !parent.being_chased:
				return states.chase
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	match _new_state:
		states.spawn:
			animation_player.play("Spawn")
		states.idle:
			animation_player.play("Fly")
		states.chase:
			animation_player.play("Fly")
		states.chased:
			animation_player.play("Chased")
		states.hurt:
			animation_player.play("Hurt")
		states.dead:
			animation_player.play("Death")
			PlayerGlobal.player_score_current += parent.kill_points
			#parent.set_physics_process(false)
			set_process(false)
		states.revive:
			animation_player.play("Revive")
			set_process(false)
