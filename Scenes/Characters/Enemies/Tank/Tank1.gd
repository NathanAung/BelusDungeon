extends Enemy

# weapon node
onready var weapons:Node2D = get_node("Weapons")
var current_weapon:Node2D
export var shield_scene:PackedScene
# dust scene to spawn while running
export var dust_scene:PackedScene
var rng = RandomNumberGenerator.new()
onready var eyes_anim:AnimationPlayer = get_node("Eyes/AnimationPlayer")
# for tired state
var tired:bool = false
var times_attacked:int
export var max_attack_times:int = 4
# shield blocking
var blocked_attack:bool = false


func _ready():
	rng.randomize()
	# set current weapon and cd time
	if not current_weapon:
		current_weapon = weapons.get_child(0)
		current_weapon.get_node("Cooldown").set_wait_time(attack_cd)
		current_weapon.gHurtbox.shield_owner = self
		current_weapon.pHurtbox.shield_owner = self
		current_weapon.weapon_owner = self
		current_weapon.owner_tank = true
		current_weapon.gHurtbox.set_physics_process(true)
		# disable hurtbox while holding shield
#		$AnimatedSprite/Hurtbox.set_collision_mask_bit(2, false)
#		$AnimatedSprite/Hurtbox.set_collision_layer_bit(3, false)


func _physics_process(delta):
	# get the direction to player
	var player_dir: Vector2 = (Player.global_position - global_position).normalized()
	if current_weapon and !tired:
		current_weapon.move(player_dir)
	
	# attack player
	if current_weapon and can_attack and state_machine.state in [state_machine.states.idle, state_machine.states.chase] and global_position.distance_to(Player.global_position) < attack_distance:
		if current_weapon.cd_timer.time_left == 0 and !current_weapon.animation_player.is_playing() and !PlayerGlobal.player_dead:
			eyes_anim.play("Flash")
		else:
			attacking = false
	else:
		attacking = false
			


# respawn weapon after tired state
func get_weapon() -> void:
	current_weapon = shield_scene.instance()
	weapons.add_child(current_weapon)
	current_weapon.set_name("Shield")
	current_weapon.get_node("Node2D/AnimatedSprite/Hitbox").set_collision_mask_bit(3, false)
	current_weapon.gHurtbox.set_collision_mask_bit(2, true)
	current_weapon.gHurtbox.set_collision_layer_bit(3, true)
	current_weapon.pHurtbox.set_collision_mask_bit(2, true)
	current_weapon.pHurtbox.set_collision_layer_bit(3, true)
	current_weapon.gHurtbox.set_physics_process(true)
	current_weapon.get_node("Cooldown").set_wait_time(attack_cd)
	current_weapon.gHurtbox.shield_owner = self
	current_weapon.pHurtbox.shield_owner = self
	current_weapon.weapon_owner = self
	current_weapon.owner_tank = true
#	$AnimatedSprite/Hurtbox.set_collision_mask_bit(2, false)
#	$AnimatedSprite/Hurtbox.set_collision_layer_bit(3, false)
	


func drop_weapon() -> void:
	# add weapon again if the enemy is not holding it
	if current_weapon == null:
		current_weapon = shield_scene.instance()
		weapons.add_child(current_weapon)
		current_weapon.set_name("Shield")
		current_weapon.weapon_owner = self
	var weapon_to_drop:Node2D = current_weapon
	current_weapon = null
	weapons.call_deferred("remove_child", weapon_to_drop)
	# switch sprites
	weapon_to_drop.get_node("Node2D/AnimatedSprite").hide()
	weapon_to_drop.get_node("WeaponIcon").show()
	weapon_to_drop.drop()
	Dungeon.current_room.call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.call_deferred("set_owner", Dungeon.current_room)
	yield(weapon_to_drop.tween, "tree_entered")
	weapon_to_drop.show()
	weapon_to_drop.interpolate_pos(global_position, global_position)


func spawn_dust() -> void:
	var dust = dust_scene.instance()
	dust.position = global_position
	get_parent().add_child(dust)


func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	if !blocked_attack:
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
	else:
		attacking = false
		print("Enemy blocked attack!")
		blocked_attack = false


# check if the enemy is tired
func check_tired() -> void:
	times_attacked += 1
	# enter tired state if attacked maximum times
	if times_attacked >= max_attack_times:
		print("Tired")
		blocked_attack = false
		tired = true
		times_attacked = 0
		can_attack = false
		state_machine.set_state(state_machine.states.tired)
		$TiredTimer.start()
		
		# temporarily remove weapon during the tired state
		weapons.call_deferred("remove_child", current_weapon)
		current_weapon.queue_free()
		current_weapon = null
#		$AnimatedSprite/Hurtbox.set_collision_mask_bit(2, true)
#		$AnimatedSprite/Hurtbox.set_collision_layer_bit(3, true)


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Flash":
		current_weapon.enemy_attack()
		attacking = true


# timer set to not attack immediately after spawning
func _on_SpawnTimer_timeout():
	can_attack = true
	if current_weapon:
		current_weapon.show()


func _on_TiredTimer_timeout():
	tired = false
	can_attack = true
	get_weapon()
	$TiredTimer.stop()
