extends Enemy


onready var hitbox:Area2D = get_node("AnimatedSprite/Hitbox")
onready var cooldown_timer:Timer = get_node("Cooldown")
var attack_sfx = preload("res://SFX/Character/Enemies/bat_attack.wav")

# Called when the node enters the scene tree for the first time.
#func _ready():
#	acceleration = 60
#	max_speed = 120
#	attack_distance = 20


func _physics_process(delta):
	hitbox.knockback_dir = velocity.normalized()
	#print(cooldown_timer.time_left)
	if cooldown_timer.time_left == 0 and state_machine.state in [state_machine.states.idle, state_machine.states.chase] and global_position.distance_to(Player.global_position) < attack_distance and !PlayerGlobal.player_dead:
		state_machine.set_state(state_machine.states.attack)
		playSFX(1)
		cooldown_timer.start()


func _on_Cooldown_timeout():
	cooldown_timer.stop()


# update the path to the player on timeout
func _on_PathTimer_timeout() -> void:
	# if there is a path
	if path:
		return
	# if player is available and not stuck
	elif is_instance_valid(Player):
		_get_path_to_player()
	else:
		path_timer.stop()
		path = []
		move_direction = Vector2.ZERO


# called when the character takes damage
func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	attacking = false
	# reduce HP
	HP -= dmg
	if HP > 0:
		# change to hurt state and add knockback
		state_machine.set_state(state_machine.states.hurt)
		velocity += dir * force
	elif HP <= 0 and state_machine.state != state_machine.states.dead:
		emit_signal("enemy_dead", self)
		state_machine.set_state(state_machine.states.dead)
		if animated_sprite.material:
			animated_sprite.material.set_shader_param("flash_modifier", 0)
		velocity += dir * force * 2
		path_timer.stop()


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$OtherAudio.stream = explosion_sfx
				$OtherAudio.volume_db = -6
				$OtherAudio.play()
			1:
				$OtherAudio.stream = attack_sfx
				$OtherAudio.volume_db = -10
				$OtherAudio.play()
