extends Character
class_name Enemy

signal enemy_dead(enemy)

# explosion effect when enemies spawn
export var explosion_scene:PackedScene
# arrays of points to the player
var path: PoolVector2Array
# Navigation2D scene of the room's tilemap
var navigation: Navigation2D
# the room the enemy is in
var current_room: Node2D
var room_map: Node2D
# player node in main scene
export(NodePath) var player_node_path = MiscGlobal.player_node_path
onready var Player: KinematicBody2D = get_node(player_node_path)
# dungeon node in main scene
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)

# timer that updates the path
onready var path_timer: Timer = get_node("PathTimer")
# move speed of the enemy
var distance_offset = 20

# for avoiding obstacles
#onready var ColChecker: Node2D = get_node("ColChecker")
var stuck:bool = false

# attack cd and wait bool
export(int) var attack_cd = 1
var can_attack = false
# the distance enemy's attack can reach
export var attack_distance:float = 40
onready var LineTest:Line2D = get_node("/root/Main/Line2D")
export var eyes_offset:float = -3

# score
export var kill_points:int = 100

# sfx
var explosion_sfx = preload("res://SFX/Environment/explosion.wav")


func connect_signal(room: Node2D):
	current_room = room
	room_map = room.get_node("RoomMap")
	connect("enemy_dead", current_room, "check_enemies")
	
# called to chase the player
func chase() -> void:
	# if there is a path
	if path:
		# re-enable physics process to start flipping again
		set_physics_process(true)
		# store the vector to the next point in the path
		var vector_to_next_point: Vector2 = path[0] - global_position
		#print(global_position, " ", vector_to_next_point, " ", path[0])
		var distance_to_next_point: float = vector_to_next_point.length()
		
		# if the distance to next point is less than the move speed, remove it
		if distance_to_next_point < distance_offset or global_position.distance_to(Player.global_position) < attack_distance:
			path.remove(0)
			#print("point removed")
			# return if there aren't more points in the path
			if not path:
				if stuck:
					print("unstucked")
					stuck = false
				return
		# update the move direction from the extended Character class
		move_direction = vector_to_next_point.normalized()


func _physics_process(delta):
	# flipping the sprite according to the moving direction
	if state_machine.state != state_machine.states.dash:
		if move_direction.x > 0 and animated_sprite.flip_h:
			animated_sprite.flip_h = false
			$Eyes.position.x = 0
		elif move_direction.x < 0 and not animated_sprite.flip_h:
			animated_sprite.flip_h = true
			$Eyes.position.x = eyes_offset


# update the path to the player on timeout
func _on_PathTimer_timeout() -> void:
	# if there is a path
	if path:
		# if collided or stuck
		if get_last_slide_collision():
			_get_path_astar()
			stuck = true
		else:
			return
	# if player is available and not stuck
	elif is_instance_valid(Player) and not stuck:
		_get_path_to_player()
		# clear ColCheck's array because not stuck anymore
#		ColChecker.pos_traveled = []
	elif is_instance_valid(Player) and stuck:
		_get_path_astar()
	else:
		path_timer.stop()
		path = []
		move_direction = Vector2.ZERO


# get path directly to the player
func _get_path_to_player() -> void:
	#print("getting player path")
	if global_position.distance_to(Player.global_position) > attack_distance:
		#print("Enemy global pos = ", global_position, " Player global pos = ", Player.global_position)
		path = navigation.get_simple_path(global_position, Player.global_position)
		LineTest.points = path
		# temporarily disable physics process to avoid flipping
		set_physics_process(false)
	else:
		move_direction = Vector2.ZERO


# get path to the player by avoiding obstacles
#func _get_path_to_pos() -> void:
#	#print("getting free path")
#	var free_pos_path = ColChecker.get_free_path()
#	if free_pos_path:
#		path = free_pos_path
#		LineTest.points = path
#		# temporarily disable physics process to avoid flipping
#		set_physics_process(false)
#	else:
#		_get_path_to_player()


func _get_path_astar() -> void:
	var move_dir = move_direction.round()
	path = room_map.find_path(global_position, Player.global_position, move_dir)
	if path.empty() and stuck:
		print("a star path stuck, getting normal path")
		_get_path_to_player()


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


func spawn_explosion() -> void:
	var explosion = explosion_scene.instance()
	explosion.position = global_position
	get_parent().add_child(explosion)


func playSFX(sfx) -> void:
	if AudioGlobal.sfx_settings:
		match sfx:
			0:
				$OtherAudio.stream = explosion_sfx
				$OtherAudio.volume_db = -7
				$OtherAudio.play()


# timer set to not attack immediately after spawning
func _on_SpawnTimer_timeout():
	can_attack = true
