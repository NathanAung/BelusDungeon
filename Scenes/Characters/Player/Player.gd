extends Character

# weapon node
var current_weapon:Node2D
onready var weapons:Node2D = get_node("Weapons")
var unarmed:bool = true
# for weapon switching
enum {SCROLL_UP, SCROLL_DOWN}
# for scrolling to not update every frame
var scroll_strength = 0
# for weapon switching on the UI
var switched:bool = false

# whether the player is travelling through doors or not
var in_transition = false

var movement_disabled:bool = false

# dungeon node in main scene
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# camera node in main scene
export(NodePath) var cam_node_path = "/root/Main/CameraKB"
onready var Cam = get_node(cam_node_path)
# health node in the UI
export(NodePath) var health_node_path = "/root/Main/PlayerUI/CanvasLayer/Health"
onready var Health = get_node(health_node_path)
# armor UI node in the UI
export(NodePath) var armor_node_path = "/root/Main/PlayerUI/CanvasLayer/ArmorU"
onready var ArmorUI = get_node(armor_node_path)
# weapon slots node in the UI
export(NodePath) var weapon_slots_node_path = "/root/Main/PlayerUI/CanvasLayer/WeaponSlots"
onready var weapon_slots = get_node(weapon_slots_node_path)
# game over text node in the UI
export(NodePath) var game_over_text_node_path = "/root/Main/PlayerUI/CanvasLayer/GameOver"
onready var game_over_text = get_node(game_over_text_node_path)
# power up display node from UI
export(NodePath) var power_up_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/PauseMenu/PowerUps"
onready var power_up_UI = get_node(power_up_ui_node_path)

# dust scene to spawn while running
export var dust_scene:PackedScene
# cooldown timer for dashing
onready var dash_timer:Timer = get_node("DashTimer")
onready var dash_reset_timer:Timer = get_node("DashResetTimer")
var dash_dir:Vector2 = Vector2.ZERO
var dashed_times:int = 0
# hurtbox collider
onready var hurtbox_col:CollisionShape2D = get_node("AnimatedSprite/Hurtbox/CollisionShape2D")
# invincibility timer called after getting hurt
onready var invi_timer:Timer = get_node("InviTimer")

# when the shield blocks attacks
var blocked_attack:bool = false
# armor node
onready var armor:AnimatedSprite = get_node("AnimatedSprite/Armor")
# for interact indicator
var interactable:bool = false
onready var interact_indi:AnimatedSprite = get_node("InteractIndi")
# SFX
var dash_sfx = preload("res://SFX/Character/dash.wav")
var weapon_switch_sfx = preload("res://SFX/Character/weapon_switch.wav")
var hurt_sfx = preload("res://SFX/Character/hurt.wav")
var defend_sfx = preload("res://SFX/Character/defend.wav")
var revive_sfx = preload("res://SFX/Character/revive.wav")
var death_sfx = preload("res://SFX/Character/death.wav")


func _ready():
	acceleration = 50
	max_speed = 120
	if DungeonGlobal.current_floor > 1:
		restore_weapons()
		weapon_slots.call_deferred("update_all")
	if PlayerGlobal.player_armor_current > 0:
		match PlayerGlobal.player_armor_level:
			1:
				armor.animation = "Bronze"
			2:
				armor.animation = "Silver"
			3:
				armor.animation = "Gold"
		armor.visible = true
		ArmorUI.generate_armor_ui()
		ArmorUI.update_armor_ui()
	if PlayerGlobal.in_menu:
		state_machine.set_state(state_machine.states.sitting)


func _physics_process(delta):
	var mouse_dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
	
	if !in_transition and !PlayerGlobal.in_menu:
	# flip sprite
		if mouse_dir.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
			armor.flip_h = false
		elif mouse_dir.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true
			armor.flip_h = true
	
	# move weapon
	if current_weapon:
		current_weapon.move(mouse_dir)
		# update switching on UI
		if switched:
			weapon_slots.call_deferred("switch_weapon", current_weapon.get_index())
			if current_weapon.get_parent().name == "Weapons":
				switched = false
		# make sure he doesn't hold more than max weapons
		if weapons.get_child_count() > PlayerGlobal.player_WS_current:
			drop_weapon(0)
	
	if not current_weapon:
		if  weapons.get_child_count() > 1:
			current_weapon = weapons.get_child(weapons.get_child_count() - 1)
		else:
			current_weapon = weapons.get_child(0)
		# for knife
		if current_weapon.weapon_owner == null:
			current_weapon.weapon_owner = self
			weapon_slots.call_deferred("update_all")
		if !PlayerGlobal.in_menu:
			current_weapon.show()
		#print(current_weapon)
		weapon_slots.call_deferred("switch_weapon", current_weapon.get_index())
#	elif current_weapon.weapon_type == 4 and weapons.get_child_count() <= 1 and not unarmed:
#		#print("unarmed")
#		unarmed = true
#		#weapon_slots.call_deferred("switch_weapon", 20)
#		Dungeon.current_room.spawn_item(Dungeon.current_room.item_no.weapon_pot)


func _get_input() -> void:
	if !movement_disabled:
		# MOVE PLAYER
		move_direction = Vector2.ZERO
		if not in_transition:
			var input_Vector = Vector2.ZERO
			input_Vector.x = Input.get_action_strength("input_right") - Input.get_action_strength("input_left")
			input_Vector.y = Input.get_action_strength("input_down") - Input.get_action_strength("input_up")
			
			# DASHING
			if Input.is_action_just_pressed("input_dash") and dash_timer.time_left == 0:
				playSFX(1)
				state_machine.set_state(state_machine.states.dash)
				acceleration = 240
				max_speed = 240
				set_collision_layer_bit(2, false)
				set_collision_mask_bit(3, false)
				if input_Vector != Vector2.ZERO:
					dash_dir = input_Vector.normalized()
				else:
					if animated_sprite.flip_h:
						dash_dir = Vector2.RIGHT
					else:
						dash_dir = Vector2.LEFT
				hurtbox_col.set_deferred("disabled", true)
				dashed_times += 1
				dash_reset_timer.start()
				if dashed_times >= PlayerGlobal.player_DC_current:
					dash_timer.start()
			
			if state_machine.state == state_machine.states.dash:
				move_direction = dash_dir
			elif input_Vector != Vector2.ZERO:
				move_direction = input_Vector.normalized()
			else:
				move_direction = Vector2.ZERO
				velocity = Vector2.ZERO
		else:
			# resetting flash if player gets hit before 
			animated_sprite.material.set_shader_param("flash_modifier", 0)
			# reset speeds if the player was dashing
			acceleration = 50
			max_speed = 120
			dash_dir = Vector2.ZERO
			move_direction = Vector2.ZERO
			velocity = Vector2.ZERO
			set_collision_layer_bit(2, true)
			set_collision_mask_bit(3, true)
			armor.flip_h = animated_sprite.flip_h
		
		# WEAPON ACTIONS
		if current_weapon:
			# switch weapon while an animation is not playing
			if not current_weapon.is_busy():
				if Input.is_action_just_released("input_weapon_scroll_up") and scroll_strength == 0 and !unarmed:
					switch_weapon(SCROLL_UP)
					scroll_strength += 10
				elif Input.is_action_just_released("input_weapon_scroll_down") and scroll_strength == 0 and !unarmed:
					switch_weapon(SCROLL_DOWN)
					scroll_strength += 10
				elif Input.is_action_just_pressed("input_interact"):
					# error handling
					pass
				elif Input.is_action_just_pressed("input_drop"):
					drop_weapon(100)
				elif scroll_strength > 0:
					scroll_strength -= 1
			if current_weapon:
				current_weapon.get_input()
				# break weapon if the durability reaches 0
				if current_weapon.durability <= 0:
					#print("Weapon broke!")
					attacking = false
					weapons.call_deferred("remove_child", current_weapon)
					current_weapon.queue_free()
					current_weapon = null
					weapon_slots.call_deferred("update_all")
					if weapons.get_child_count() <= 2:
						unarmed = true
						Dungeon.current_room.spawn_item(Dungeon.current_room.item_no.weapon_pot)


# change weapons with number keys
func _input(event):
	if !movement_disabled:
		if event is InputEventKey and event.pressed and not event.echo and not unarmed:
			if event.scancode in [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6] and not current_weapon.is_busy():
				var k = int(OS.get_scancode_string(event.scancode)) - 1
				if k < weapons.get_child_count():
					current_weapon.hide()
					current_weapon = weapons.get_child(k)
					#print("switched to ", current_weapon.name)
					weapon_slots.call_deferred("switch_weapon", k)
					current_weapon.show()
					playSFX(2)


func switch_weapon(scroll_dir: int) -> void:
	attacking = false
	var index:int = current_weapon.get_index()
	if scroll_dir == SCROLL_UP:
		index -= 1
		if index < 0:
			index = weapons.get_child_count() - 1
	else:
		index += 1
		if index > weapons.get_child_count() - 1:
			index = 0
	current_weapon.hide()
	current_weapon = weapons.get_child(index)
	print("swtiched to ", current_weapon.name)
	current_weapon.show()
	playSFX(2)
	switched = true


func cancel_attack() -> void:
	if current_weapon:
		current_weapon.cancel_attack()


# called when the character takes damage
func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	if !blocked_attack:
		attacking = false
		# split-second invincibility
		if invi_timer.time_left == 0:
			#print("invincible")
			hurtbox_col.set_deferred("disabled", true)
			invi_timer.wait_time = 0.5
			invi_timer.start()
		# knockback
		velocity += dir * force
		# if player is wearing armor
		if PlayerGlobal.player_armor_current > 0:
			PlayerGlobal.player_armor_current -= dmg
			ArmorUI.update_armor_ui()
			Cam.cam_shake(0)
			playSFX(6)
			print("Armor absorbed ", dmg, " damage! AP: ", PlayerGlobal.player_armor_current)
			if PlayerGlobal.player_armor_current <= 0:
				#print("armor broke!")
				armor.visible = false
				ArmorUI.visible = false
		else:
			# reduce HP
			PlayerGlobal.player_HP_current -= dmg
			# update health UI
			Health.update_health()
			if PlayerGlobal.player_HP_current > 0:
				Cam.cam_shake(0)
				playSFX(3)
				print("Player took ", dmg, " damage! HP: ", PlayerGlobal.player_HP_current)
				# change to hurt state and add knockback
				state_machine.set_state(state_machine.states.hurt)
			elif PlayerGlobal.player_HP_current <= 0 and state_machine.state != state_machine.states.dead:
				state_machine.set_state(state_machine.states.dead)
				playSFX(4)
				# resetting flash if player gets hit before 
				animated_sprite.material.set_shader_param("flash_modifier", 0)
				velocity += dir * force * 2
				PlayerGlobal.player_dead = true
	else:
		attacking = false
		print("Blocked attack!")
		blocked_attack = false


# play player SFXs
func playSFX(sfx):
	if AudioGlobal.sfx_settings:
		match sfx:
			0: # Footstep
				$FootstepsAudio.volume_db = -5
				$FootstepsAudio.play()
			1: # Dash
				$OtherAudio.stream = dash_sfx
				$OtherAudio.volume_db = -2
				$OtherAudio.play()
			2: # Weapon Swtich
				$OtherAudio.stream = weapon_switch_sfx
				$OtherAudio.volume_db = 5
				$OtherAudio.play()
			3: # Hurt
				$OtherAudio.stream = hurt_sfx
				$OtherAudio.volume_db = -5
				$OtherAudio.play()
			4: # Death
				$OtherAudio.stream = death_sfx
				$OtherAudio.volume_db = 1
				$OtherAudio.play()
			5: # Revive
				$OtherAudio.stream = revive_sfx
				$OtherAudio.volume_db = 1
				$OtherAudio.play()
			6: # Defend
				$OtherAudio.stream = defend_sfx
				$OtherAudio.volume_db = 0
				$OtherAudio.play()
		pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Hurt":
		if acceleration == 240 and max_speed == 240:	# reset speed if player dashes before getting hurt
			acceleration = 50
			max_speed = 120
			dash_dir = Vector2.ZERO
			move_direction = Vector2.ZERO
			velocity = Vector2.ZERO
#			set_collision_layer_bit(2, true)
#			set_collision_mask_bit(3, true)
	elif anim_name == "Dash":
		acceleration = 50
		max_speed = 120
		dash_dir = Vector2.ZERO
		move_direction = Vector2.ZERO
		velocity = Vector2.ZERO
		set_collision_layer_bit(2, true)
		set_collision_mask_bit(3, true)
	# restart game after death animation
	elif anim_name == "Death":
		if PlayerGlobal.player_death_protection:
			state_machine.set_state(state_machine.states.revive)
			playSFX(5)
		else:
			PlayerGlobal.play_timer_on = false
			game_over_text.game_over()
			Dungeon.current_room.call_deferred("enable_room_traps", false)
			Dungeon.current_room.call_deferred("enable_room_enemies", false)
	elif anim_name == "Revive":
		PlayerGlobal.player_dead = false
		PlayerGlobal.player_death_protection = false
		#hurtbox_col.set_deferred("disabled", true)
		invi_timer.wait_time = 3
		invi_timer.start()
		PlayerGlobal.collected_power_ups.erase(PlayerGlobal.power_up_dict.revive)
		power_up_UI.update_display()
		set_physics_process(true)
		weapons.set_visible(true)
	elif anim_name == "Stand_up":
		current_weapon.show()


# for spawning dust
func spawn_dust() -> void:
	var dust = dust_scene.instance()
	dust.position = global_position
	get_parent().add_child(dust)


func pick_up_weapon(weapon: Node2D) -> void:
	if current_weapon:
		cancel_attack()
		current_weapon.hide()
	# deferred is used here as the code in this script gets postponed otherwise
	weapon.get_parent().call_deferred("remove_child", weapon)
	weapons.call_deferred("add_child", weapon)
	weapon.set_deferred("owner", weapons)
	current_weapon = weapon
	# switch sprite
	current_weapon.get_node("WeaponIcon").hide()
	current_weapon.get_node("Node2D/AnimatedSprite").show()
	current_weapon.show()
	
	unarmed = false
	#print("picked up weapon")
	weapon_slots.call_deferred("update_all")
	switched = true


func drop_weapon(strength:int) -> void:
	if !current_weapon.permanent:
		attacking = false
		var weapon_to_drop:Node2D = current_weapon
		if weapons.get_child_count() > 1:
			call_deferred("switch_weapon", SCROLL_UP)
			if weapons.get_child_count() <= 2:
					unarmed = true
		# switch sprites
		weapon_to_drop.get_node("Node2D/AnimatedSprite").hide()
		weapon_to_drop.get_node("WeaponIcon").show()
		weapon_to_drop.drop()
		
		weapons.call_deferred("remove_child", weapon_to_drop)
		weapon_slots.call_deferred("update_all")
		Dungeon.current_room.call_deferred("add_child", weapon_to_drop)
		weapon_to_drop.call_deferred("set_owner", Dungeon.current_room)
		yield(weapon_to_drop.tween, "tree_entered")
		weapon_to_drop.show()
		
		var throw_dir: Vector2 = (get_global_mouse_position() - global_position).normalized()
		weapon_to_drop.interpolate_pos(global_position, global_position + throw_dir * strength)

# cooldown for dash
func _on_DashTimer_timeout():
	hurtbox_col.set_deferred("disabled", false)
	dash_timer.stop()


func _on_InviTimer_timeout():
	#print("invi timer out")
	if state_machine.state != state_machine.states.dash:
		hurtbox_col.set_deferred("disabled", false)
	invi_timer.stop()


# for in-between dashes
func _on_DashResetTimer_timeout():
	#print("Evaded: ", dashed_times)
	dashed_times = 0
	hurtbox_col.set_deferred("disabled", false)
	dash_reset_timer.stop()
	dash_timer.start()


# restore the holding weapons when going up a floor
func restore_weapons():
	if PlayerGlobal.current_weapons.size() > 0:
		for i in PlayerGlobal.current_weapons.size():
			var weapon = PlayerGlobal.current_weapons[i][0].instance()
			weapons.add_child(weapon)
			weapon.pick_up(self)
			weapon.durability = PlayerGlobal.current_weapons[i][1]
		# switch to last weapon
		current_weapon.hide()
		current_weapon = weapons.get_child(PlayerGlobal.last_weapon_index)
		weapon_slots.call_deferred("switch_weapon", PlayerGlobal.last_weapon_index)
		current_weapon.show()
		
	PlayerGlobal.current_weapons = []
	PlayerGlobal.last_weapon_index = 0
