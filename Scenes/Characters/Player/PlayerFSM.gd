extends FiniteStateMachine

export(NodePath) var health_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/Health"
onready var Health_UI = get_node(health_ui_node_path)


func _init():
	_add_state("idle")
	_add_state("walk")
	_add_state("dash")
	_add_state("hurt")
	_add_state("dead")
	_add_state("revive")
	_add_state("sitting")
	_add_state("stand_up")

func _ready():
	set_state(states.idle)


# put the logic of the state
func _state_logic(_delta: float) -> void:
	if state == states.idle or state == states.walk:
		parent._get_input()
		parent.move()
	elif state == states.dash:
		parent.move()


# get the state transition
func _get_transition() -> int:
	match state:
		states.idle:
			if parent.velocity.length() > 10 and not parent.in_transition:
				return states.walk
		states.walk:
			if parent.velocity.length() < 10:
				return states.idle
		states.dash:
			if parent.velocity.length() < 10:
				return states.idle
		states.hurt:
			if not animation_player.is_playing():
				return states.idle
		states.revive:
			if not animation_player.is_playing():
				return states.idle
		states.stand_up:
			if not animation_player.is_playing():
				return states.idle
	return -1


func _enter_state(_previous_state: int, _new_state: int) -> void:
	match state:
		states.idle:
			parent.move_direction = Vector2.ZERO
			parent.velocity = Vector2.ZERO
			animation_player.play("Idle")
		states.walk:
			animation_player.play("Walk")
		states.dash:
			animation_player.play("Dash")
		states.hurt:
			animation_player.play("Hurt")
		states.dead:
			animation_player.play("Death")
			parent.set_physics_process(false)
			parent.weapons.set_visible(false)
			set_process(false)
		states.revive:
			animation_player.play("Revive")
			PlayerGlobal.player_HP_current += 4
			Health_UI.update_health()
		states.sitting:
			animation_player.play("Sitting")
		states.stand_up:
			animation_player.play("Stand_up")


#func _on_AnimationPlayer_animation_finished(anim_name):
#	if anim_name == "Revive":
#		parent.set_physics_process(true)
#		parent.weapons.set_visible(true)
#		set_process(true)
#	elif anim_name == "Stand_up":
#		parent.current_weapon.show()
		
