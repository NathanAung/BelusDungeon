extends Node2D

export var campfire_scene = preload("res://Scenes/Environment/Campfire/Campfire.tscn")
export var spikes_scene = preload("res://Scenes/Environment/Spikes/Spikes.tscn")
export var arrow_trap_scene = preload("res://Scenes/Environment/ArrowTrap/ArrowTrap.tscn")
export var flame_trap_scene = preload("res://Scenes/Environment/FlameTrap/FlameTrap.tscn")
export var healing_pond_scene = preload("res://Scenes/Environment/HealingPond/HealingPond.tscn")
export var shopkeeper_scene = preload("res://Scenes/Environment/Shop/Shopkeeper.tscn")
export var pedestal_scene = preload("res://Scenes/Environment/Shop/Pedestal.tscn")
export var chest_scene = preload("res://Scenes/Environment/Chest/Chest.tscn")
export var weapon_pot_scene = preload("res://Scenes/Collectibles/PowerUps/WeaponPot/WeaponPot.tscn")
export var obstacle_scene = preload("res://Scenes/Environment/Obstacle/Obstacle.tscn")
export var explosion_scene = preload("res://Scenes/Effects/Explosion/Explosion.tscn")
#export var test_weapon_1_scene = preload("res://Scenes/Weapons/Sword/Sword.tscn")
#export var test_weapon_2_scene = preload("res://Scenes/Weapons/Spear/Spear.tscn")
#export var test_weapon_3_scene = preload("res://Scenes/Weapons/Bow/Bow.tscn")
#export var test_weapon_4_scene = preload("res://Scenes/Weapons/Shield/Shield.tscn")

onready var room_map = get_node("RoomMap")
onready var enemy_gen = get_node("EnemyGen")
onready var obstacle_gen = get_node("ObstacleGen")
# YSort node to instantiate the explosion into
export(NodePath) var YSort_node_path = "/root/Main/Dungeon/YSort"
onready var YSort_node = get_node("/root/Main/Dungeon/YSort")
onready var boss_intro = get_node("/root/Main/PlayerUI/CanvasLayer/BossIntro");

var rng = RandomNumberGenerator.new()

# position in the grid
var grid_pos := Vector2()

# type of room
# 0 = normal, 1 = starting room, 2 = boss, 3 = healing, 4 = shop, 5 = treasure
var type
# room name for UI
var room_name:String = ""

# doors in cardinal directions
var door_N = false
var door_E = false
var door_W = false
var door_S = false
# whether the doors are open or not
var doors_open = true

# TRAPS
var number_of_traps = 0
var traps = []
# ENEMIES
var enemy_waves = 0
var waves_left = 0
var enemies = []
var enemies_in_room:int = 0

var four_pos = [Vector2(DungeonGlobal.room_width/2 - 40, DungeonGlobal.room_height/2 - 20),
	Vector2(DungeonGlobal.room_width/2 + 40, DungeonGlobal.room_height/2 - 20),
	Vector2(DungeonGlobal.room_width/2 - 40, DungeonGlobal.room_height/2 + 20),
	Vector2(DungeonGlobal.room_width/2 + 40, DungeonGlobal.room_height/2 + 20)]

# positions in the room taken by enemies, tall objects
var taken_positions = []
# positions in the room taken by floor traps, obstacles
var taken_positions_floor = []
var room_cleared = false

# put key/power up in the chest if allocated by DungeonGen
var key_in_room:bool = false
var power_up_in_room:bool = false

export var normal_room_points:int = 500
export var special_room_points:int = 700
var points_allocated:bool = false

# for spawning items in the room
var item_no:Dictionary = {"chest":0, "weapon_pot":1}


# set the grid pos and room type on init
func init(p_grid_pos, p_type):
	grid_pos = p_grid_pos
	# print(grid_pos)
	type = p_type


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
	# no traps in special rooms 
	if type == DungeonGlobal.room_type.normal:
		number_of_traps = rng.randi_range(3, 5)
#		if DungeonGlobal.current_floor > 1 and rng.randi_range(0,1) == 0:
#			enemy_waves = 2
#		else:
#			enemy_waves = 1
		match DungeonGlobal.floor_level:
			1:
				if rng.randi_range(0, 3) == 0:
					enemy_waves = 2
				else:
					enemy_waves = 1
			2:
				if rng.randi_range(0, 2) == 0:
					enemy_waves = 2
				else:
					enemy_waves = 1
			3:
				if rng.randi_range(0, 5) == 0:
					enemy_waves = 3
				elif rng.randi_range(0, 2) == 0:
					enemy_waves = 2
				else:
					enemy_waves = 1
		waves_left = enemy_waves
		#enemy_waves = 3
	elif type == DungeonGlobal.room_type.boss:
		number_of_traps = rng.randi_range(5, 8)
		enemy_waves = 1
		waves_left = 1
		

	if type != DungeonGlobal.room_type.normal and type != DungeonGlobal.room_type.boss:
		room_cleared = true
	
	# corner wall tiles
	taken_positions_floor.append(Vector2(2, 2))
	taken_positions_floor.append(Vector2(15, 2))
	taken_positions_floor.append(Vector2(2, 8))
	taken_positions_floor.append(Vector2(15, 8))


func set_up_room():
	set_room_doors()
	room_map.set_room_map(type, door_N, door_E, door_W, door_S)
	if type == DungeonGlobal.room_type.boss:
		set_boss_room_traps()
		var boss = enemy_gen.create_boss()
		boss_intro.set_deferred("boss", boss)
		boss_intro.set_deferred("room", self)
	else:
		set_room_traps()
	obstacle_gen.create_obstacles()
	if type == DungeonGlobal.room_type.healing:
		var pond = healing_pond_scene.instance()
		pond.position = Vector2(7 * DungeonGlobal.CELL_SIZE, 4 * DungeonGlobal.CELL_SIZE)
		self.add_child(pond)
		room_name = "Healing Pond"
	elif type == DungeonGlobal.room_type.shop:
		var shopkeeper = shopkeeper_scene.instance()
		shopkeeper.position = Vector2(DungeonGlobal.room_width/2, DungeonGlobal.room_height/2 - 30)
		self.add_child(shopkeeper)
		room_name = "Shop"
	elif type == DungeonGlobal.room_type.treasure:
		for i in 4:
			var chest = chest_scene.instance()
			chest.position = four_pos[i]
			self.add_child(chest)
			if rng.randi_range(0,2) == 0:
				chest.set_chest(chest.chest_types.power_up, self)
			else:
				chest.set_chest(chest.chest_types.treasure, self)
		room_name = "Treasure Room"
	elif type == DungeonGlobal.room_type.start:
		var campfire = campfire_scene.instance()
		campfire.position = Vector2(DungeonGlobal.room_width/2, DungeonGlobal.room_height/2)
		self.add_child(campfire)
#		for i in 4:
#			var weapon
#			match i:
#				0:
#					weapon = test_weapon_1_scene.instance()
#				1:
#					weapon = test_weapon_2_scene.instance()
#				2:
#					weapon = test_weapon_3_scene.instance()
#				3:
#					weapon = test_weapon_4_scene.instance()
#			weapon.position = four_pos[i]
#			weapon.on_floor = true
#			self.add_child(weapon)


# show the hidden doors if they exist in this room
func set_room_doors():
	var doors = [door_N, door_E, door_W, door_S]
	var doors_S = ["DoorN", "DoorE", "DoorW", "DoorS"]
	var vectors = [Vector2.UP, Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN]
	# positions to ignore on the floor map if a door is added
	var N_positions = [Vector2(8,2), Vector2(9,2), Vector2(8,3), Vector2(9,3)]
	var E_positions = [Vector2(14,5), Vector2(15,5)]
	var W_positions = [Vector2(2,5), Vector2(3,5)]
	var S_positions = [Vector2(8,7), Vector2(9,7), Vector2(8,8), Vector2(9,8)]
	var pos_arr = [N_positions, E_positions, W_positions, S_positions]
	# for setting elevator
	var door_special = false
	
	for i in 4:
		if(doors[i]):
			# get the room behind the door
			var room = DungeonGlobal.rooms[(grid_pos + vectors[i]).y][(grid_pos + vectors[i]).x]
			# set to normal door if it's the starting room since starting door is locked
			if room.type == 1:
				get_node(doors_S[i]).type = 0
			# lock the door if it's a boss room
			elif room.type == 2:
				get_node(doors_S[i]).type = 2
				get_node(doors_S[i]).locked = true
			# set the type for other doors
			else:
				get_node(doors_S[i]).type = room.type
			get_node(doors_S[i]).show()
			get_node(doors_S[i]).set_physics_process(true)
		# set elevator to next floor if boss room and there isn't a door here
		elif type == 2 and !door_special:
			get_node(doors_S[i]).type = 6
			get_node(doors_S[i]).show()
			get_node(doors_S[i]).set_physics_process(true)
			door_special = true
			doors[i] = true
		# starting door for upper floors if there is no door, does not open
		elif i == 3 and type == 1 and DungeonGlobal.current_floor > 1:
			get_node(doors_S[i]).type = 1
			get_node(doors_S[i]).show()
			get_node(doors_S[i]).set_physics_process(true)
			get_node(doors_S[i]).door_open = false
			doors[i] = true
		
		# add empty positions on the floor if there is a door
		if doors[i] == true:
			for t in pos_arr[i].size():
				taken_positions_floor.append(pos_arr[i][t])


# opening and closing the doors of this room
# enemies are generated here
func open_doors(open_close):
	doors_open = open_close
	if doors_open:
		if type == DungeonGlobal.room_type.boss:
			if get_node("DoorN").locked == false and get_node("DoorN").type == 6:
				get_node("DoorN").door_open = true
			if get_node("DoorE").locked == false and get_node("DoorE").type == 6:
				get_node("DoorE").door_open = true
			if get_node("DoorW").locked == false and get_node("DoorW").type == 6:
				get_node("DoorW").door_open = true
			if get_node("DoorS").locked == false and get_node("DoorS").type == 6:
				get_node("DoorS").door_open = true
		else:
			if get_node("DoorN").locked == false:
				get_node("DoorN").door_open = true
			if get_node("DoorE").locked == false:
				get_node("DoorE").door_open = true
			if get_node("DoorW").locked == false:
				get_node("DoorW").door_open = true
			if get_node("DoorS").type != 1 and get_node("DoorS").locked == false:
				get_node("DoorS").door_open = true
		# disable traps
		for i in traps.size():
			traps[i].enableTrap(false)
		# clear enemies
		if enemies:
			for i in enemies.size():
				enemies[i].queue_free()
			enemies = []
		room_cleared = true
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorOpen)
	else:
		get_node("DoorN").door_open = false
		get_node("DoorE").door_open = false
		get_node("DoorW").door_open = false
		if get_node("DoorS").type != 1:
			get_node("DoorS").door_open = false
		
		if not room_cleared and waves_left > 0:
			if type == DungeonGlobal.room_type.normal:
				match DungeonGlobal.floor_level:
					1:
						if rng.randi_range(0, 3) == 0:
							enemy_waves = 2
						else:
							enemy_waves = 1
					2:
						if rng.randi_range(0, 2) == 0:
							enemy_waves = 2
						else:
							enemy_waves = 1
					3:
						if rng.randi_range(0, 5) == 0:
							enemy_waves = 3
						elif rng.randi_range(0, 2) == 0:
							enemy_waves = 2
						else:
							enemy_waves = 1
				waves_left = enemy_waves
				enemy_gen.create_enemies(0)
				enable_room_traps(true)
			elif type == DungeonGlobal.room_type.boss:
				boss_intro.get_node("AnimationPlayer").play("IntroPlay")
				#enemy_gen.create_boss()
				AudioGlobal.change_music(AudioGlobal.boss_intro_track)
		
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorClose)


func set_room_traps():
	var start_x = 2
	var start_y = 2
	var trap
	var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 3), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 3))
	var pits_map = room_map.get_child(1)
		
	for i in number_of_traps:
		# arrow trap
		if rng.randi_range(0, 3) == 0:
			# while the position is taken
			while taken_positions_floor.has(pos) or (pos.x > 2 and pos.x < 15 and pos.y > 2 and pos.y < 8):
				pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 3), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 3))
		# spike trap
		else:
			# while the position is taken
			while taken_positions_floor.has(pos) or pits_map.get_cellv(pos) != -1:
				pos = Vector2(rng.randi_range(start_x + 1, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y + 1, DungeonGlobal.room_height_cell - 4))
		
		taken_positions_floor.append(pos)
		
		# if wall position, generate arrow trap
		if pos.x == 2 or pos.x == 15 or pos.y == 2 or pos.y == 8:
			if rng.randi_range(0,2) == 0:
				trap = flame_trap_scene.instance()
			else:
				trap = arrow_trap_scene.instance()
			if pos.x == 2:
				trap.rotation_degrees = 270
			elif pos.x == 15:
				trap.rotation_degrees = 90
			elif pos.y == 2:
				trap.rotation_degrees = 0
			elif pos.y == 8:
				trap.rotation_degrees = 180
			trap.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
		# generate spike trap
		else:
			trap = spikes_scene.instance()
			trap.position = Vector2(pos.x * DungeonGlobal.CELL_SIZE, pos.y * DungeonGlobal.CELL_SIZE)
		
		traps.append(trap)
		self.add_child(trap)


func set_boss_room_traps() -> void:
	var trap_pos = [Vector2(3,3),Vector2(4,3),Vector2(5,3),Vector2(6,3),Vector2(7,3), 
		Vector2(10,3),Vector2(11,3),Vector2(12,3),Vector2(13,3),Vector2(14,3),
		Vector2(3,4),Vector2(14,4),Vector2(3,6),Vector2(14,6),
		Vector2(3,7),Vector2(4,7),Vector2(5,7),Vector2(6,7),Vector2(7,7), 
		Vector2(10,7),Vector2(11,7),Vector2(12,7),Vector2(13,7),Vector2(14,7),
		Vector2(2,3),Vector2(3,2),Vector2(2,7),Vector2(3,8),Vector2(14,2),Vector2(15,3),Vector2(14,8),Vector2(15,7)
		]
	var pits_map = room_map.get_child(1)
	var trap
	for i in trap_pos.size():
		taken_positions_floor.append(trap_pos[i])
		if trap_pos[i].x == 2 or trap_pos[i].x == 15 or trap_pos[i].y == 2 or trap_pos[i].y == 8:
			trap = flame_trap_scene.instance()
			trap.set_deferred("random_delay", false)
			if trap_pos[i].x == 2:
				trap.rotation_degrees = 270
			elif trap_pos[i].x == 15:
				trap.rotation_degrees = 90
			elif trap_pos[i].y == 2:
				trap.rotation_degrees = 0
			elif trap_pos[i].y == 8:
				trap.rotation_degrees = 180
			trap.position = Vector2((trap_pos[i].x * DungeonGlobal.CELL_SIZE) + 20, (trap_pos[i].y * DungeonGlobal.CELL_SIZE) + 20)
			trap.get_node("AudioStreamPlayer2D").volume_db = -10
		else:
			trap = spikes_scene.instance()
			trap.position = Vector2(trap_pos[i].x * DungeonGlobal.CELL_SIZE, trap_pos[i].y * DungeonGlobal.CELL_SIZE)
		traps.append(trap)
		self.add_child(trap)


func enable_room_traps(enable:bool) -> void:
	for i in traps.size():
		traps[i].enableTrap(enable)


func enable_room_enemies(enable:bool) -> void:
	for i in enemies.size():
		enemies[i].set_physics_process(false)
	
	
# called by a signal in Enemy class, checks if there are enemies left in the room
func check_enemies(enemy):
	enemies.erase(enemy)
	enemies_in_room -= 1
	if not enemies and enemies_in_room <= 0:
		#print("no enemies left")
		enemies = []
		enemies_in_room = 0
		waves_left -= 1
		if waves_left > 0:
			enemy_gen.create_enemies(0)
		# open doors and add score
		else:
			open_doors(true)
			allocate_room_points()
			DungeonGlobal.cleared_rooms += 1
			print("Cleared ", DungeonGlobal.cleared_rooms, " rooms")
			if DungeonGlobal.cleared_rooms == DungeonGlobal.lv3_cleared_rooms:
				DungeonGlobal.floor_level = 3
				print("FLOOR LEVEL 3")
			elif DungeonGlobal.cleared_rooms == DungeonGlobal.lv2_cleared_rooms:
				DungeonGlobal.floor_level = 2
				print("FLOOR LEVEL 2")
			if type == DungeonGlobal.room_type.normal:
				# spawn reward chest
				spawn_item(item_no.chest)
	else:
		#print("enemies left")
		pass


# randomly place requested item in the room
func spawn_item(item):
	# get a random position
	var start_x = 4
	var start_y = 4
	var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
	var pits_map = room_map.get_child(1)
	
	while taken_positions_floor.has(pos) or pits_map.get_cellv(pos) != -1:
		pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
	taken_positions_floor.append(pos)
	
	match item:
		item_no.chest:
			# add the explosion
			var explosion = explosion_scene.instance()
			explosion.position = Vector2(pos.x * DungeonGlobal.CELL_SIZE + 20 + grid_pos.x * DungeonGlobal.room_width, pos.y * DungeonGlobal.CELL_SIZE + 40 + grid_pos.y * DungeonGlobal.room_height)
			YSort_node.add_child(explosion)
			var chest = chest_scene.instance()
			#add_child(chest)
			call_deferred("add_child", chest)
			chest.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
			if key_in_room:
				#chest.set_chest(chest.chest_types.key, self)
				chest.call_deferred("set_chest", chest.chest_types.key, self)
			elif power_up_in_room:
				#chest.set_chest(chest.chest_types.power_up, self)
				chest.call_deferred("set_chest", chest.chest_types.power_up, self)
			else:
				#chest.set_chest(chest.chest_types.treasure, self)
				chest.call_deferred("set_chest", chest.chest_types.treasure, self)
		item_no.weapon_pot:
			# only spawn if there are no other weapons in the room
			var no_weapons = true
			var room_children:Array = get_children()
			for i in room_children.size():
				if room_children[i].is_in_group("Weapon"):
					no_weapons = false
					#print("weapons in room")
					break
			if no_weapons and !room_cleared and PlayerGlobal.player_weapon_pot_current > 0:
				# add the explosion
				var explosion = explosion_scene.instance()
				explosion.position = Vector2(pos.x * DungeonGlobal.CELL_SIZE + 20 + grid_pos.x * DungeonGlobal.room_width, pos.y * DungeonGlobal.CELL_SIZE + 40 + grid_pos.y * DungeonGlobal.room_height)
				YSort_node.add_child(explosion)
				var weapon_pot = weapon_pot_scene.instance()
				add_child(weapon_pot)
				weapon_pot.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
				weapon_pot.room_pos = pos


# remove unwanted items after room change
func clear_items():
	var room_children:Array = get_children()
	for i in room_children.size():
		if room_children[i].name == "WeaponPot":
			room_children[i].call_deferred("queue_free")


# give points to player for clearing the room
func allocate_room_points():
	if room_cleared and !points_allocated and type != DungeonGlobal.room_type.start:
		if type == DungeonGlobal.room_type.normal:
			PlayerGlobal.player_score_current += normal_room_points
		else:
			PlayerGlobal.player_score_current += special_room_points
		points_allocated = true
