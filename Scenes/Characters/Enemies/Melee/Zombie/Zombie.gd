extends Melee1


export var ghost_scene = preload("res://Scenes/Characters/Enemies/Melee/Zombie/Ghost/Ghost.tscn")
export var ghost_sfx:AudioStreamSample = preload("res://SFX/Character/Enemies/ghost.wav")
export(NodePath) var YSort_node_path = "/root/Main/Dungeon/YSort"
onready var YSort_node = get_node("/root/Main/Dungeon/YSort")
export(float) var maxHP: float = 3


func _ready():
	HP = maxHP


func spawnGhost() -> void:
	var ghost = ghost_scene.instance()
	ghost.global_position = global_position
	ghost.navigation = get_node(MiscGlobal.dungeon_node_path)
	ghost.connect_signal(current_room)
	#current_room.enemies.append(ghost)
	YSort_node.add_child(ghost)
	ghost.corpse = self


func reviveCorpse() -> void:
	state_machine.set_state(state_machine.states.revive)
	playSFX(1)


# destroy the corpse after the ghost is defeated
func destroyCorpse() -> void:
	spawn_explosion()
	drop_weapon()
	emit_signal("enemy_dead", self)
	queue_free()


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
		state_machine.set_state(state_machine.states.dead)
		if animated_sprite.material:
			animated_sprite.material.set_shader_param("flash_modifier", 0)
		velocity += dir * force * 2
		path = []


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Flash":
		current_weapon.enemy_attack()
		attacking = true
	elif anim_name == "Revive":
		weapons.set_visible(true)
		set_physics_process(true)


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$OtherAudio.stream = explosion_sfx
				$OtherAudio.volume_db = -7
				$OtherAudio.play()
			1:
				$OtherAudio.stream = ghost_sfx
				$OtherAudio.volume_db = 0
				$OtherAudio.play()
