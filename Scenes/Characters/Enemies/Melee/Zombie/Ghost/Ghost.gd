extends Enemy

export var ghost_sfx:AudioStreamSample = preload("res://SFX/Character/Enemies/ghost.wav")
var corpse_pos:Vector2
var corpse:KinematicBody2D
const MAX_DISTANCE_TO_PLAYER: int = 160
const MIN_DISTANCE_TO_PLAYER: int = 80
var distance_to_player: float
var being_chased:bool = false
var can_revive:bool = false


func connect_signal(room: Node2D):
	current_room = room
	room_map = room.get_node("RoomMap")
	#connect("enemy_dead", current_room, "check_enemies")


func _ready():
	playSFX(1)


func destroyCorpse() -> void:
	corpse.call_deferred("destroyCorpse")

func reviveCorpse() -> void:
	corpse.call_deferred("reviveCorpse")


func _physics_process(delta):
	if can_revive and state_machine.state in [state_machine.states.idle, state_machine.states.chase] and !PlayerGlobal.player_dead:
		#print((corpse.global_position - global_position).length())
		if (corpse.global_position - global_position).length() <= 20:
			z_index = 1
			state_machine.set_state(state_machine.states.revive)
			if corpse.animated_sprite.flip_h:
				animated_sprite.flip_h = true
				global_position = corpse.global_position + Vector2(0, -5)
			else:
				global_position = corpse.global_position + Vector2(0, -5)
			#print("revive")


# update the path to the player on timeout
func _on_PathTimer_timeout() -> void:
	# if there is a path
	if path:
		return
	elif can_revive:
		_get_path_to_corpse()
		being_chased = false
	# if player is available and not stuck
	elif is_instance_valid(Player):
		distance_to_player = (Player.global_position - global_position).length()
		if distance_to_player >= MAX_DISTANCE_TO_PLAYER:
			_get_path_to_player()
			being_chased = false
			#print("chase")
		elif distance_to_player <= MIN_DISTANCE_TO_PLAYER:
			_get_path_to_move_away_from_player()
			being_chased = true
			#print("move away")
		else:
			path = []
			move_direction = Vector2.ZERO
			being_chased = false
	else:
		path_timer.stop()
		path = []
		move_direction = Vector2.ZERO
		being_chased = false


func _get_path_to_corpse() -> void:
	path = navigation.get_simple_path(global_position, corpse.global_position)
	LineTest.points = path
	# temporarily disable physics process to avoid flipping
	#set_physics_process(false)


func _get_path_to_move_away_from_player() -> void:
	var dir: Vector2 = (global_position - Player.global_position).normalized()
	var p:Vector2 = global_position + dir * 100
	p.x = clamp(p.x, room_map.global_position.x + 120, room_map.global_position.x + DungeonGlobal.room_width - 120)
	p.y = clamp(p.y, room_map.global_position.y + 120, room_map.global_position.y + DungeonGlobal.room_height - 120)
	path = navigation.get_simple_path(global_position, p)


func _on_ReviveTimer_timeout():
	can_revive = true


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
