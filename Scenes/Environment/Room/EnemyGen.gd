extends Node2D

class_name EnemyGen

# explosion effect when enemies spawn
export var explosion_scene:PackedScene
# path to folder containing enemy scenes
export var enemy_folder_path = "res://Scenes/Characters/Enemies/"
# lv1 enemies
export var lv1_melee = preload("res://Scenes/Characters/Enemies/Melee/Melee1.tscn")
export var lv1_ranged = preload("res://Scenes/Characters/Enemies/Ranged/Ranged1.tscn")
export var lv1_flying = preload("res://Scenes/Characters/Enemies/Flying/Flying1.tscn")
export var lv1_tank = preload("res://Scenes/Characters/Enemies/Tank/Tank1.tscn")
# lv2 enemies
export var lv2_melee = preload("res://Scenes/Characters/Enemies/Melee/Melee2.tscn")
export var lv2_ranged = preload("res://Scenes/Characters/Enemies/Ranged/Ranged2.tscn")
export var lv2_flying = preload("res://Scenes/Characters/Enemies/Flying/Flying2.tscn")
export var lv2_tank = preload("res://Scenes/Characters/Enemies/Tank/Tank2.tscn")
# lv3 enemies
export var lv3_melee = preload("res://Scenes/Characters/Enemies/Melee/Melee3.tscn")
export var lv3_ranged = preload("res://Scenes/Characters/Enemies/Ranged/Ranged3.tscn")
export var lv3_flying = preload("res://Scenes/Characters/Enemies/Flying/Flying3.tscn")
export var lv3_tank = preload("res://Scenes/Characters/Enemies/Tank/Tank3.tscn")

export var zombie = preload("res://Scenes/Characters/Enemies/Melee/Zombie/Zombie.tscn")
# bosses
export var boss1 = preload("res://Scenes/Characters/Bosses/WarriorOgre/WarriorOgre.tscn")
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# parent room
onready var room = get_parent()
# YSort node to instantiate the enemies into
export(NodePath) var YSort_node_path = "/root/Main/Dungeon/YSort"
onready var YSort_node = get_node("/root/Main/Dungeon/YSort")
# rng node
var rng = RandomNumberGenerator.new()
var enemy_types = {"melee":0, "ranged":1, "flying":2, "tank":3}
var gen_types = {"normal":0, "boss1":1, "minions":2}
var melee_enemies = [lv1_melee, lv2_melee, lv3_melee]
var ranged_enemies = [lv1_ranged, lv2_ranged, lv3_ranged]
var flying_enemies = [lv1_flying, lv2_flying, lv3_flying]
var tank_enemies = [lv1_tank, lv2_tank, lv3_tank]

var boss_first_spawn:bool = true #for spawning boss as first enemy in boss room
var tanks_spawned:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


# generate enemies in the room
func create_enemies(gen_type):
	#print("creating enemies")
	# random enemy number
	var enemy_number = 0
	if gen_type == gen_types.normal:
		if DungeonGlobal.floor_level == 1:
			if Dungeon.first_enemy:
				enemy_number = 1
			else:
				if room.enemy_waves > 1:
					enemy_number = rng.randi_range(2, 3)
				else:
					enemy_number = rng.randi_range(3, 5)
			#enemy_number = 1	# debug
		elif DungeonGlobal.floor_level >= 2:
			if room.enemy_waves > 1:
				enemy_number = rng.randi_range(2, 4)
			else:
				enemy_number = rng.randi_range(3, 6)
#	elif gen_type == gen_types.boss1:
#		enemy_number = 1
	else:
		enemy_number = rng.randi_range(2, 4)
	#print(enemy_number)
	
	# indexes of taken_positions array occupied by enemies during spawning for debug
	var taken_position_indexes = []
	for i in enemy_number:
		var enemy_type = enemy_types.melee
		var enemy_strength = 1
		# ENEMY TYPE
		if gen_type == gen_types.normal and !Dungeon.first_enemy: 	# get random enemy type
			if rng.randi_range(0,8) == 0 and tanks_spawned < 2:
				enemy_type = enemy_types.tank
				tanks_spawned += 2
			elif rng.randi_range(0,3) == 0:
				enemy_type = enemy_types.ranged
			else:
				var t = rng.randi_range(0,1)
				match t:
					0:
						enemy_type = enemy_types.melee
					1:
						enemy_type = enemy_types.flying
			
			#enemy_type = enemy_types.tank 	# debug
			# ENEMY STRENGTH
			match DungeonGlobal.floor_level:
				2:
					if rng.randi_range(0, 2) == 0:
						enemy_strength = 2
				3:
					if rng.randi_range(0, 2) == 0:
						enemy_strength = 3
					elif rng.randi_range(0, 1) == 0:
						enemy_strength = 2
		elif gen_type == gen_types.minions:
			if rng.randi_range(0, 1) == 0:
				enemy_type = enemy_types.ranged
			
			if rng.randi_range(0, 5) == 0:
				enemy_strength = 3
			elif rng.randi_range(0, 3) == 0:
				enemy_strength = 2
		
		# ENEMY SCENE
		var enemy_scene
#		if gen_type == gen_types.boss1 and boss_first_spawn:
#			enemy_scene = boss1
#			boss_first_spawn = false
#		else:
		match enemy_type:
			enemy_types.melee:
				#zombie
				if DungeonGlobal.floor_level > 1 and rng.randi_range(0,3) == 0:
					enemy_scene = zombie
				else:
					enemy_scene = melee_enemies[enemy_strength - 1]
			enemy_types.ranged:
				enemy_scene = ranged_enemies[enemy_strength - 1]
			enemy_types.flying:
				enemy_scene = flying_enemies[enemy_strength - 1]
			enemy_types.tank:
				enemy_scene = tank_enemies[enemy_strength - 1]
		
		if Dungeon.first_enemy:
			Dungeon.first_enemy = false
		
		#enemy_scene = tank_enemies[0]     #DEBUG
		
		# instance in available position
		var start_x = 4
		var start_y = 4
		var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
		var pits_map = room.room_map.get_child(1)
		var iter:int = 0
		
		while room.taken_positions.has(pos) or pits_map.get_cellv(pos) != -1:
				pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
				iter += 1
				if iter > 100:
					print("Cannot place enemy")
		room.taken_positions.append(pos)
		# add the taken index to the array
		taken_position_indexes.append(room.taken_positions.size() - 1)
		var e_pos = Vector2(pos.x * DungeonGlobal.CELL_SIZE + room.grid_pos.x * DungeonGlobal.room_width, pos.y * DungeonGlobal.CELL_SIZE + room.grid_pos.y * DungeonGlobal.room_height)
		var explosion = explosion_scene.instance()
		explosion.position = e_pos
		YSort_node.add_child(explosion)
		var enemy = enemy_scene.instance()
		# play the explosion sound
		enemy.playSFX(0)
		enemy.position = e_pos
		enemy.navigation = get_node(MiscGlobal.dungeon_node_path)
		enemy.connect_signal(room)
		room.enemies.append(enemy)
		#YSort_node.add_child(enemy)
		YSort_node.call_deferred("add_child", enemy)
		# create a small time gap between spawns
		$Timer.start()
		yield($Timer, "timeout")
	
	# remove taken positions of enemies in the room after spawning
	var n = taken_position_indexes.size() - 1
	for i in taken_position_indexes.size():
		#print(room.taken_positions[taken_position_indexes[n]])
		room.taken_positions.remove(taken_position_indexes[n])
		n -= 1
	taken_position_indexes = []
	# reset tanks spawned for next gen
	tanks_spawned = 0


func create_boss():
	var pos:Vector2 = Vector2(9,6)
	var e_pos = Vector2(pos.x * DungeonGlobal.CELL_SIZE + room.grid_pos.x * DungeonGlobal.room_width, pos.y * DungeonGlobal.CELL_SIZE + room.grid_pos.y * DungeonGlobal.room_height)
	var enemy = boss1.instance()
	enemy.position = e_pos
	enemy.navigation = get_node(MiscGlobal.dungeon_node_path)
	enemy.connect_signal(room)
	room.enemies.append(enemy)
	#YSort_node.add_child(enemy)
	YSort_node.call_deferred("add_child", enemy)
	
	return enemy
	
func _on_Timer_timeout():
	pass # Replace with function body.
