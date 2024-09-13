extends Melee1FSM


func _init():
	_add_state("revive")


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
				return states.chase
		states.revive:
			if not animation_player.is_playing():
				return states.idle
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	match _new_state:
		states.idle:
			animation_player.play("Idle")
		states.chase:
			animation_player.play("Walk")
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
			animation_player.play("DeathFake")
			parent.set_physics_process(false)
			parent.weapons.set_visible(false)
			set_process(false)
		states.revive:
			animation_player.play("Revive")
			parent.HP = parent.maxHP
