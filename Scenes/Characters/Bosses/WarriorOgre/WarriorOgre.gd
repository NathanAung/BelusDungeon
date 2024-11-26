extends Enemy


# camera node in main scene
export(NodePath) var cam_node_path = "/root/Main/CameraKB"
onready var Cam = get_node(cam_node_path)
onready var weapons:Node2D = get_node("Weapons") # weapon node
var current_weapon:Node2D
export var dust_scene:PackedScene # dust scene to spawn while running
var rng = RandomNumberGenerator.new()
onready var eyes_anim:AnimationPlayer = get_node("Eyes/AnimationPlayer")
onready var hurtbox_col:CollisionShape2D = get_node("AnimatedSprite/Hurtbox/CollisionShape2D") # hurtbox collider
onready var dash_timer:Timer = get_node("DashTimer") # cooldown timer for dashing
onready var body_col:CollisionShape2D = get_node("CollisionShape2D")
var dash_dir:Vector2 = Vector2.ZERO
var can_dash:bool = true
var weap_no:int = 0
var can_switch:bool = true # for switching weapons
var blocked_attack:bool = false # shield blocking
var no_attack_cancel:bool = false # no attack cancel if hit during weapon special attack
var times_received_damage:int = 0 # switch to shield after received too many attacks
const MAX_DISTANCE_TO_PLAYER: int = 160
const MIN_DISTANCE_TO_PLAYER: int = 80
var distance_to_player: float
var player_dir:Vector2
var dizzy:bool = false
var can_special_attack:bool = true # for spawning minions and special attacks
var special_attacking:bool = false
var spinning = false  	#for spin attacks
var last_spin_vector:Vector2 	#last direction the boss spinned into
var spin_accel:int = 120
var spin_max_speed:int = 600
var normal_accel:int = 30
var normal_max_speed:int = 100
var weapons_dropped:int = 0 # for dropping weapons during spinning
var weapons_dropped_max:int = 5
var spin_kb:int = 300
var slam_kb:int = 500
# sfx
var slam_sfx = preload("res://SFX/Character/Enemies/Boss/slam.wav")
var spin_sfx = preload("res://SFX/Character/Enemies/Boss/spin.wav")
var summon_sfx = preload("res://SFX/Character/Enemies/Boss/summon.wav")
var dizzy_sfx = preload("res://SFX/Character/Enemies/Boss/dizzy.wav")
var death_sfx = preload("res://SFX/Character/Enemies/Boss/death.wav")
var dash_sfx = preload("res://SFX/Character/dash.wav")
# disabled until player enters room
var active:bool = false


# default HP 100
func _ready():
	rng.randomize()
	# set current weapon and cd time
	if not current_weapon:
		switch_weapon(0)
	current_weapon.hide()
	# disable on spawn
	set_physics_process(false)


func _physics_process(delta):
	# get the direction to player
	player_dir = (Player.global_position - global_position).normalized()
	if current_weapon:
		current_weapon.move(player_dir)
	
	if is_instance_valid(Player) and !PlayerGlobal.player_dead:
		distance_to_player = (Player.global_position - global_position).length()
		if state_machine.state in [state_machine.states.idle, state_machine.states.chase] and can_dash and !special_attacking:
			if distance_to_player <= MIN_DISTANCE_TO_PLAYER and Player.attacking:
				evade()
			elif distance_to_player <= MAX_DISTANCE_TO_PLAYER:
				if dash_timer.time_left == 0 and rng.randi_range(0, 5) == 0:
					dash()
		elif state_machine.state == state_machine.states.dash:
				move_direction = dash_dir
		
		if can_attack and state_machine.state in [state_machine.states.idle, state_machine.states.chase]:
			# special attacks
			if $SpecialTimer.time_left == 0 and can_special_attack and !spinning and !PlayerGlobal.player_dead:
				if rng.randi_range(0,3) != 0:
					hurtbox_col.set_deferred("disabled", true)
					special_attacking = true
					print("special_attacking")
					$SpecialEyes.play()
				$SpecialTimer.start()
				can_special_attack = false
			# switch weapon
			elif rng.randi_range(0, 2) == 0 and can_switch:
				# switch to bow if far
				if distance_to_player >= MAX_DISTANCE_TO_PLAYER and rng.randi_range(0,3) == 0:
					switch_weapon(4)
				else:
					switch_weapon(0)
			# attack player
			elif global_position.distance_to(Player.global_position) < attack_distance:
				if current_weapon.cd_timer.time_left == 0 and !current_weapon.animation_player.is_playing() and !PlayerGlobal.player_dead:
					eyes_anim.play("Flash")
					pass
				else:
					attacking = false
	else:
		attacking = false



func special_attack() -> void:
	print("SPECIAL")
	var r = rng.randi_range(0, 3)	# CHANGE TO (0,3) LATER
	#r = 1
	match r:
		0: # spawn minions
			#hurtbox_col.disabled = true
			if current_room.enemies.size() == 1:
				current_weapon.hide()
				can_attack = false
				state_machine.set_state(state_machine.states.summon)
		1: # spin attack
			#hurtbox_col.set_deferred("disabled", true)
			$Hitbox.knockback_force = spin_kb
			$Hitbox.knockback_dir = player_dir
			state_machine.set_state(state_machine.states.spinStart)
			if weap_no == 3:
				blocked_attack = false
				var w = 3
				while w == 3:
					w = rng.randi_range(1, 4)
				switch_weapon(w)
			current_weapon.hide()
			can_attack = false
			print("spinning")
		2: # slam ground and drop rocks
			#hurtbox_col.disabled = true
			if current_room.taken_positions_floor.size() < 55:
				$Hitbox.knockback_force = slam_kb
				$Hitbox.knockback_dir = player_dir
				state_machine.set_state(state_machine.states.slam)
				current_weapon.hide()
				can_attack = false
				print("dropping rocks")
			else:
				print("too many objects in room to drop rocks. room space: ", current_room.taken_positions_floor.size())
		3: # weapon special
			if weap_no != 3:
				can_dash = false
				dash_timer.start()
				weapon_special_attack()
			else:
				shield_dash()
				weapon_special_attack()
				


func weapon_special_attack() -> void:
	if !PlayerGlobal.player_dead:
		current_weapon.enemy_special_attack()
		can_attack = false
		attacking = true
		no_attack_cancel = true
		print("WEAPON SPECIAL")


func activate_boss() -> void:
	set_difficulty(MiscGlobal.game_difficulty)
	$SpawnTimer.start()


func switch_weapon(w_no) -> void:
	if current_weapon:
		current_weapon.cancel_attack()
		current_weapon.hide()
	if w_no == 0:
		weap_no = rng.randi_range(1, 4)
		#weap_no = 3
	else:
		weap_no = w_no
	current_weapon = weapons.get_child(weap_no - 1)
#	$AnimatedSprite/Hurtbox.set_collision_mask_bit(2, true)
#	$AnimatedSprite/Hurtbox.set_collision_layer_bit(3, true)
	current_weapon.weapon_owner = self
	$SwitchTimer.wait_time = 8
	match weap_no:
		1:# club
			attack_distance = 40
		2:# spear
			attack_distance = 60
		3:# shield
			attack_distance = 40
			current_weapon.gHurtbox.shield_owner = self
			current_weapon.pHurtbox.shield_owner = self
			#current_weapon.weapon_owner = self
			current_weapon.owner_tank = true
			current_weapon.gHurtbox.set_physics_process(true)
			# disable hurtbox while holding shield
#			$AnimatedSprite/Hurtbox.set_collision_mask_bit(2, false)
#			$AnimatedSprite/Hurtbox.set_collision_layer_bit(3, false)
			$SwitchTimer.wait_time = 5
		4:# bow
			attack_distance = 160
	current_weapon.get_node("Cooldown").set_wait_time(attack_cd)
	current_weapon.show()
	can_switch = false
	#print("switched to ", weap_no)
	$SwitchTimer.start()


func spawn_minions() -> void:
	current_room.enemy_gen.call_deferred("create_enemies", 2)
	print("spawned enemies")


func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	if !blocked_attack:
		if !no_attack_cancel:
			attacking = false
		# reduce HP
		HP -= dmg
		if HP > 0:
			# change to hurt state and add knockback
			state_machine.set_state(state_machine.states.hurt)
			velocity += dir * force
			# switch to shield if receiving too many attacks
			if !dizzy:
				times_received_damage += 1
				print(times_received_damage)
				$RDmgTimer.start()
				if times_received_damage >= 5:
					if rng.randi_range(0,2) == 0 and !attacking:
						print("switched to shield")
						switch_weapon(3)
					times_received_damage = 0
		elif HP <= 0 and !state_machine.state in [state_machine.states.dead, state_machine.states.deadStart]:
			emit_signal("enemy_dead", self)
			current_weapon.cancel_attack()
			if animated_sprite.material:
				animated_sprite.material.set_shader_param("flash_modifier", 0)
			Dungeon.boss_defeated = true
			AudioGlobal.music_off_fixed = true
			AudioGlobal.music_on_off(false, false)
			playSFX(5)
			state_machine.set_state(state_machine.states.deadStart)
			path_timer.stop()
	else:
		attacking = false
		print("Enemy blocked attack!")
		blocked_attack = false

 
# check if the enemy is tired
func check_tired() -> void:
	pass


func drop_weapon() -> void:
	var weapon_to_drop:Node2D = current_weapon
	current_weapon = null
	weapons.call_deferred("remove_child", weapon_to_drop)
	# switch sprites
	weapon_to_drop.get_node("Node2D/AnimatedSprite").hide()
	weapon_to_drop.get_node("WeaponIcon").show()
	Dungeon.current_room.call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.call_deferred("set_owner", Dungeon.current_room)
	yield(weapon_to_drop.tween, "tree_entered")
	weapon_to_drop.show()
	weapon_to_drop.interpolate_pos(global_position, global_position)


func drop_weapon_spin() -> void:
	var weapon_to_drop:Node2D
	if rng.randi_range(0, 4) == 0:
		weapon_to_drop = ItemGlobal.lv3_weapons[rng.randi_range(0, 3)].instance()
	elif rng.randi_range(0, 2) == 0:
		weapon_to_drop = ItemGlobal.lv2_weapons[rng.randi_range(0, 3)].instance()
	else:
		weapon_to_drop = ItemGlobal.lv1_weapons[rng.randi_range(0, 3)].instance()
	weapon_to_drop.on_floor = true
	Dungeon.current_room.call_deferred("add_child", weapon_to_drop)
	weapon_to_drop.call_deferred("set_owner", Dungeon.current_room)
	weapon_to_drop.global_position = global_position
	#yield(weapon_to_drop.tween, "tree_entered")
	var dir = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1)).normalized()
	#weapon_to_drop.interpolate_pos(global_position, global_position + dir * 100)
	weapon_to_drop.call_deferred("interpolate_pos", global_position, global_position + dir * 100)
	
	
func spawn_dust() -> void:
	var dust = dust_scene.instance()
	dust.position = global_position
	get_parent().add_child(dust)


func _on_AnimationPlayer_animation_finished(anim_name):
	if max_speed > 120:
		print(anim_name)
	if anim_name == "Flash":
		if max_speed > 120:
			reset_dash()
		current_weapon.enemy_attack()
		attacking = true
	elif anim_name == "Hurt":
		if max_speed > 120:
			reset_dash()
		# resetting flash
		animated_sprite.material.set_shader_param("flash_modifier", 0)
	elif anim_name == "Dash" or anim_name == "ShieldDash":
		reset_dash()
#		var collision = get_last_slide_collision()
#		if collision:
#			print("Collided with: ", collision.collider.name)
	elif anim_name == "SpinStart":
		spinning = true
		acceleration = spin_accel
		max_speed = spin_max_speed
		$SpinTimer.start()
	elif anim_name == "Summon":
		current_weapon.show()
		hurtbox_col.disabled = false
		can_attack = true
		special_attacking = false
	elif anim_name == "Slam":
		current_room.obstacle_gen.call_deferred("drop_rocks")
		Cam.cam_shake(1)
		current_weapon.show()
		hurtbox_col.disabled = false
		can_attack = true
		special_attacking = false
	elif anim_name == "Death":
		body_col.disabled = true
		print("body col disabled")


func dash() -> void:
	#if dash_timer.time_left == 0 and rng.randi_range(0, 5) == 0:
	playSFX(6)
	state_machine.set_state(state_machine.states.dash)
	acceleration = 240
	max_speed = 240
#	set_collision_layer_bit(3, false)
#	set_collision_mask_bit(2, false)
	dash_dir = (Player.global_position - global_position).normalized()
	hurtbox_col.set_deferred("disabled", true)
	dash_timer.start()
	path = []
	can_dash = false
	print("Boss dashed")


func shield_dash() -> void:
	#if dash_timer.time_left == 0 and rng.randi_range(0, 5) == 0:
	playSFX(6)
	state_machine.set_state(state_machine.states.dash)
	set_collision_layer_bit(3, false)
	set_collision_mask_bit(2, false)
	acceleration = 700	#700 both
	max_speed = 700
	dash_dir = (Player.global_position - global_position).normalized()
	hurtbox_col.set_deferred("disabled", true)
	dash_timer.start()
	path = []
	can_dash = false
	print("Boss shield dashed")


func evade() -> void:
	if dash_timer.time_left == 0 and rng.randi_range(0, 5) == 0:
		playSFX(6)
		state_machine.set_state(state_machine.states.dash)
		acceleration = 240
		max_speed = 240
		set_collision_layer_bit(3, false)
		set_collision_mask_bit(2, false)
		if animated_sprite.flip_h:
			dash_dir = Vector2.RIGHT
		else:
			dash_dir = Vector2.LEFT
		hurtbox_col.set_deferred("disabled", true)
		dash_timer.start()
		can_dash = false
		print("Boss evaded")


func reset_dash() -> void:
	print("DASH RESET")
	if !special_attacking:
		hurtbox_col.set_deferred("disabled", false)
	if !spinning:
		acceleration = 50
		max_speed = 120
		move_direction = Vector2.ZERO
		velocity = Vector2.ZERO
	dash_dir = Vector2.ZERO
	set_collision_layer_bit(3, true)
	set_collision_mask_bit(2, true)
	# resetting flash if get hit before 
	animated_sprite.material.set_shader_param("flash_modifier", 0)


func dizzy() -> void:
	dizzy = true
	can_attack = false
	$DizzyTimer.start()


# update the path to the player on timeout
func _on_PathTimer_timeout() -> void:
	if HP > 0:
		# if there is a path
		if path:
			if get_last_slide_collision() and not spinning:
				_get_path_astar()
				stuck = true
				#print("stuck, new path")
			else:
				#print("continuing path")
				return
		elif is_instance_valid(Player) and spinning:
			_get_spin_dir()
			if spinning and weapons_dropped < weapons_dropped_max and rng.randi_range(0,1) == 0:
					drop_weapon_spin()
					weapons_dropped += 1
		# if player is available and not stuck
		elif is_instance_valid(Player) and not stuck:
			# if using bow
			if weap_no == 4:
				if distance_to_player >= MAX_DISTANCE_TO_PLAYER:
					#print(distance_to_player)
					#print("moving in")
					_get_path_to_player()
				elif distance_to_player <= MIN_DISTANCE_TO_PLAYER:
					#print("moving away")
					_get_path_to_move_away_from_player()
				else:
					#print("stopped")
					path = []
					move_direction = Vector2.ZERO
			else:
				_get_path_to_player()
			# clear ColCheck's array because not stuck anymore
			#ColChecker.pos_traveled = []
		elif is_instance_valid(Player) and stuck:
			_get_path_astar()
		else:
			#print("stopped")
			path_timer.stop()
			path = []
			move_direction = Vector2.ZERO
	else:
		$PathTimer.stop()
		$PathTimer.autostart = false


func _get_path_astar() -> void:
	var move_dir = move_direction.round()
	path = room_map.find_path(global_position, Player.global_position, move_dir)
	if path.empty() and stuck:
		print("a star path stuck, getting normal path")
		_get_path_to_player()


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - Player.global_position).normalized()
	path = navigation.get_simple_path(global_position, global_position + dir * 100)


# get a random path during spinning
func _get_spin_dir() -> void:
	if abs(last_spin_vector.x) > abs(last_spin_vector.y):
		if last_spin_vector.x > 0:
			last_spin_vector = Vector2(-1, rng.randf_range(-1, 1))
		else:
			last_spin_vector = Vector2(1, rng.randf_range(-1, 1))
	elif abs(last_spin_vector.x) < abs(last_spin_vector.y):
		if last_spin_vector.y > 0:
			last_spin_vector = Vector2(rng.randf_range(-1, 1), -1)
		else:
			last_spin_vector = Vector2(rng.randf_range(-1, 1), 1)
	else:
		last_spin_vector = Vector2(rng.randf_range(-1, 1), rng.randf_range(-1, 1))
	$SpinDir.rotation = last_spin_vector.angle()
	var c = $SpinDir.get_collider()
	if c.is_in_group("Obstacle") or c.is_in_group("Trap"):
		$SpinDir.add_exception(c)
	#print(c.name, " ", last_spin_vector.x, " ", last_spin_vector.y)
	var p:Vector2
	p.x = clamp($SpinDir.get_collision_point().x, room_map.global_position.x + 160, room_map.global_position.x + DungeonGlobal.room_width - 160)
	p.y = clamp($SpinDir.get_collision_point().y, room_map.global_position.y + 160, room_map.global_position.y + DungeonGlobal.room_height - 160)
	path = navigation.get_simple_path(global_position, p)


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$OtherAudio.stream = explosion_sfx
				$OtherAudio.volume_db = -7
				$OtherAudio.play()
			1:
				$OtherAudio.stream = slam_sfx
				$OtherAudio.volume_db = -7
				$OtherAudio.play()
			2:
				if !PlayerGlobal.player_dead:
					$OtherAudio.stream = spin_sfx
					$OtherAudio.volume_db = -7
					$OtherAudio.play()
			3:
				if !PlayerGlobal.player_dead:
					$OtherAudio.stream = dizzy_sfx
					$OtherAudio.volume_db = -7
					$OtherAudio.play()
			4:
				$OtherAudio.stream = summon_sfx
				$OtherAudio.volume_db = 0
				$OtherAudio.play()
			5:
				$OtherAudio.stream = death_sfx
				$OtherAudio.volume_db = 10
				$OtherAudio.play()
			6: # Dash
				$OtherAudio.stream = dash_sfx
				$OtherAudio.volume_db = -2
				$OtherAudio.play()


func enable_hurtbox():
	hurtbox_col.set_deferred("disabled", false)


# timer set to not attack immediately after spawning
func _on_SpawnTimer_timeout():
	path_timer.start()
	$SpecialTimer.start()
	can_attack = true
	set_physics_process(true)
	current_weapon.show()
	$SpawnTimer.stop()


func _on_SwitchTimer_timeout():
	can_switch = true


func _on_DashTimer_timeout():
	dash_timer.stop()
	can_dash = true


func _on_RDmgTimer_timeout():
	times_received_damage = 0
	print(times_received_damage)
	$RDmgTimer.stop()


func _on_SpecialTimer_timeout():
	can_special_attack = true
	$SpecialTimer.stop()


func _on_SpinTimer_timeout():
	spinning = false
	acceleration = normal_accel
	max_speed = normal_max_speed
	weapons_dropped = 0
	$Hitbox/CollisionShape2D.disabled = true
	hurtbox_col.disabled = false
	dizzy()
	special_attacking = false
	$SpinTimer.stop()


func _on_DizzyTimer_timeout():
	dizzy = false
	can_attack = true
	current_weapon.show()
	$DizzyTimer.stop()


func _on_SpecialEyes_animation_finished():
	special_attack()
	$SpecialEyes.playing = false
	$SpecialEyes.frame = 0


func set_difficulty(dif: int) -> void:
	match dif:
		1:
			HP = HP_easy
			attack_cd = attack_cd_easy
			max_speed = max_speed_easy
			$SpecialTimer.wait_time = 20
			$DizzyTimer.wait_time = 8
