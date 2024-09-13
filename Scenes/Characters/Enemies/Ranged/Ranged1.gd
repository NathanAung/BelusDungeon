extends Enemy

const MAX_DISTANCE_TO_PLAYER: int = 160
const MIN_DISTANCE_TO_PLAYER: int = 80
var distance_to_player: float
# weapon node
onready var weapons:Node2D = get_node("Weapons")
var current_weapon:Node2D
onready var eyes_anim:AnimationPlayer = get_node("Eyes/AnimationPlayer")
# for the enemy's aim to move within a range
export var aim_variation:float = 30
var xy:float = 0
var dir_positive:bool = true


func _ready():
	# set current weapon and cd time
	if not current_weapon:
		current_weapon = weapons.get_child(0)
		current_weapon.get_node("Cooldown").set_wait_time(attack_cd)


func _physics_process(delta):
	# get the direction to player
	if aim_variation > 0:
		if dir_positive:
			xy += 0.5
			if xy == aim_variation:
				dir_positive = false
		else:
			xy -= 0.5
			if xy == -aim_variation:
				dir_positive = true
	var player_dir: Vector2 = (Player.global_position - global_position + Vector2(xy, xy)).normalized()
	if current_weapon:
		current_weapon.move(player_dir)
	
	# attack player
	if can_attack and state_machine.state in [state_machine.states.idle, state_machine.states.chase]:
		if current_weapon.cd_timer.time_left == 0 and !current_weapon.animation_player.is_playing() and !PlayerGlobal.player_dead:
			eyes_anim.play("Flash")


# update the path to the player on timeout
func _on_PathTimer_timeout() -> void:
	# if there is a path
	if path:
		if get_last_slide_collision():
			_get_path_astar()
			stuck = true
			#print("stuck, new path")
		else:
			#print("continuing path")
			return
	# if player is available and not stuck
	elif is_instance_valid(Player) and not stuck:
		distance_to_player = (Player.global_position - global_position).length()
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
		# clear ColCheck's array because not stuck anymore
		#ColChecker.pos_traveled = []
	elif is_instance_valid(Player) and stuck:
		_get_path_astar()
	else:
		#print("stopped")
		path_timer.stop()
		path = []
		move_direction = Vector2.ZERO


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - Player.global_position).normalized()
	path = navigation.get_simple_path(global_position, global_position + dir * 100)


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


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Flash":
		current_weapon.enemy_attack()


# timer set to not attack immediately after spawning
func _on_SpawnTimer_timeout():
	can_attack = true
	current_weapon.show()
