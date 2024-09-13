extends Node2D

class_name DungeonGen


# room scene
export var room_scene_path = "res://Scenes/Environment/Room/Room.tscn"
var RoomScene = load(room_scene_path)
# dungeon node in main scene
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# canvas node in PlayerUI scene
export(NodePath) var canvas_path = "/root/Main/PlayerUI/CanvasLayer"
onready var Canvas = get_node(canvas_path)
# rng node
var rng = RandomNumberGenerator.new()
# room position types
var pos_type = {"coupled" : 0, "branch" : 1, "special" : 2}
var gen_error: bool


func _ready():
	rng.randomize()


func create_rooms():
	# first room
	var room = RoomScene.instance()
	room.set_name("Room_1")
	DungeonGlobal.rooms[DungeonGlobal.start_room_y][DungeonGlobal.start_room_x] = room
	room.init(Vector2(DungeonGlobal.start_room_x, DungeonGlobal.start_room_y), DungeonGlobal.room_type.start)
	DungeonGlobal.taken_positions.append(Vector2(DungeonGlobal.start_room_x, DungeonGlobal.start_room_y))
	Dungeon.add_child(room)
	if DungeonGlobal.current_floor > 1:
		DungeonGlobal.ignored_positions.append(Vector2(DungeonGlobal.start_room_x, DungeonGlobal.start_room_y + 1))
	
	# arrary of the rooms with keys and power-ups
	var taken_rooms = []
	# the room the key is in
	var room_with_key = rng.randi_range(1, DungeonGlobal.number_of_rooms - 5)
	# number of power ups on the current floor
	var power_up_no = floor(DungeonGlobal.number_of_rooms/3)
	
	#power_up_no = 0
	
	print("no. of power ups: " , power_up_no)
	# allocate power ups
	for i in power_up_no:
		var pu_room = rng.randi_range(1, DungeonGlobal.number_of_rooms - 5)
		while pu_room == room_with_key or pu_room in taken_rooms:
			pu_room = rng.randi_range(1, DungeonGlobal.number_of_rooms - 5)
		taken_rooms.append(pu_room)
	
	# for checking room positions
	var check_pos = Vector2.ZERO
	
	# add rooms, index starts at 1 because start room is already placed
	for i in range(1, DungeonGlobal.number_of_rooms):
		var room_type = DungeonGlobal.room_type.normal
		# boss room
		if(i == DungeonGlobal.number_of_rooms - 4):
			check_pos = new_position(pos_type.special)
			room_type = DungeonGlobal.room_type.boss
			print("boss room")
			print(check_pos)
		# treasure room
		elif(i == DungeonGlobal.number_of_rooms - 3):
			check_pos = new_position(pos_type.special)
			room_type = DungeonGlobal.room_type.treasure
			print("treasure room")
			print(check_pos)
		# shop
		elif(i == DungeonGlobal.number_of_rooms - 2):
			check_pos = new_position(pos_type.special)
			room_type = DungeonGlobal.room_type.shop
			print("shop")
			print(check_pos)
		# healing room
		elif(i == DungeonGlobal.number_of_rooms - 1):
			check_pos = new_position(pos_type.special)
			room_type = DungeonGlobal.room_type.healing
			print("healing room")
			print(check_pos)
		else:
			if(rng.randi_range(0, 2) == 0):
				#generate coupled
				check_pos = new_position(pos_type.coupled)
				print("coupled room")
				print(check_pos)
			else:
				# generate branch
				check_pos = new_position(pos_type.branch)
				print("branch room")
				print(check_pos)
		
		if gen_error == true:
			print("DUNGEON GEN ERROR, RESTARTING FLOOR")
			DungeonGlobal.restart_floor()
			break
		else:
			room = RoomScene.instance()
			var room_name = "Room_" + String(i + 1)
			room.set_name(room_name)
			DungeonGlobal.rooms[check_pos.y][check_pos.x] = room
			room.init(check_pos, room_type)
			# insert the key or power up in the room
			if i == room_with_key:
				room.key_in_room = true
				print("The key is inserted in Room ", room_with_key + 1)
			elif i in taken_rooms:
				room.power_up_in_room = true
				print("A power up is inserted in Room ", i + 1)
			DungeonGlobal.taken_positions.append(check_pos)
			Dungeon.add_child(room)
	
	if gen_error != true:
		gen_error = false
		print("no gen error")
		if PlayerGlobal.in_menu:
			Canvas.transition_long()
		else:
			Canvas.transition(false)


# add a new room position 
func new_position(type) -> Vector2:
	var iter = 0
	var checking_pos = DungeonGlobal.taken_positions[0]
	
	match type:
		# add a new position adjacent to an existing room
		pos_type.coupled:
			while DungeonGlobal.taken_positions.has(checking_pos) or DungeonGlobal.ignored_positions.has(checking_pos) or checking_pos.x >= DungeonGlobal.dungeon_width or checking_pos.x < 0 or checking_pos.y < 0 or checking_pos.y >= DungeonGlobal.dungeon_height:
				checking_pos = random_pos()
		# add a new position with only one neigbor to branch out
		pos_type.branch:
			while DungeonGlobal.taken_positions.has(checking_pos) or DungeonGlobal.ignored_positions.has(checking_pos) or number_of_neighbors(checking_pos) > 1 or checking_pos.x >= DungeonGlobal.dungeon_width or checking_pos.x < 0 or checking_pos.y < 0 or checking_pos.y >= DungeonGlobal.dungeon_height or iter > 200:
				iter += 1
				if iter >= 200:
					print("CANNOT BRANCH")
					gen_error = true
					break
				checking_pos = random_pos()
		# same as branching, but avoid other special rooms as neigbors
		pos_type.special:
			while DungeonGlobal.taken_positions.has(checking_pos) or DungeonGlobal.ignored_positions.has(checking_pos) or number_of_neighbors(checking_pos) > 1 or check_neighbor_types(checking_pos) or checking_pos.x >= DungeonGlobal.dungeon_width or checking_pos.x < 0 or checking_pos.y < 0 or checking_pos.y >= DungeonGlobal.dungeon_height or iter > 200:
				iter += 1
				if iter >= 200:
					print("CANNOT PLACE SPECIAL")
					gen_error = true
					break
				checking_pos = random_pos()
	return checking_pos


# fetch a random position for the new_position function
func random_pos() -> Vector2:
	var index = 0
	var x = 0
	var y = 0
	var checking_pos = DungeonGlobal.taken_positions[0]
	
	index = rng.randi_range(0, DungeonGlobal.taken_positions.size() - 1)
	
	#print("checking index ", index)
	x = DungeonGlobal.taken_positions[index].x
	y = DungeonGlobal.taken_positions[index].y
	
	# north, south, east, or west of the existing room
	var vertical : bool = randf() < 0.5
	var positive : bool = randf() < 0.5
	
	if vertical:
		if positive:
			y += 1
		else:
			y -= 1
	else:
		if positive:
			x += 1
		else:
			x -= 1
			
	checking_pos = Vector2(x, y)
		
	return checking_pos


# place rooms in their positions
func place_rooms():
	for i in DungeonGlobal.taken_positions.size():
		var room = DungeonGlobal.rooms[DungeonGlobal.taken_positions[i].y][DungeonGlobal.taken_positions[i].x]
		#print("a room moved ", DungeonGlobal.taken_positions[i].y, " ", DungeonGlobal.taken_positions[i].x)
		room.position = Vector2(room.grid_pos.x * DungeonGlobal.room_width, room.grid_pos.y * DungeonGlobal.room_height)


# check neighboring rooms
func number_of_neighbors(check_pos) -> int:
	var neighbor = 0
	if DungeonGlobal.taken_positions.has(check_pos + Vector2.RIGHT):
		neighbor += 1
	if DungeonGlobal.taken_positions.has(check_pos + Vector2.LEFT):
		neighbor += 1
	if DungeonGlobal.taken_positions.has(check_pos + Vector2.UP):
		neighbor += 1
	if DungeonGlobal.taken_positions.has(check_pos + Vector2.DOWN):
		neighbor += 1
	#print(check_pos, " has ", neighbor, " neighbors")
	return neighbor


# check if neighboring rooms are special
func check_neighbor_types(check_pos) -> bool:
	var vectors = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	for i in 4:
		if DungeonGlobal.taken_positions.has(check_pos + vectors[i]):
			var x = (check_pos + vectors[i]).x
			var y = (check_pos + vectors[i]).y
			var room = DungeonGlobal.rooms[y][x]
			if room.type > DungeonGlobal.room_type.normal:
				return true
	return false


# set up doors and traps in each room
func set_up_rooms():
	# check for the rooms' adjacent rooms and open doors to them
	for i in DungeonGlobal.taken_positions.size():
		var room = DungeonGlobal.rooms[DungeonGlobal.taken_positions[i].y][DungeonGlobal.taken_positions[i].x]
		var room_pos = Vector2(room.grid_pos.x, room.grid_pos.y)
		if DungeonGlobal.taken_positions.has(room_pos + Vector2.RIGHT):
			room.door_E = true
		if DungeonGlobal.taken_positions.has(room_pos + Vector2.LEFT):
			room.door_W = true
		if DungeonGlobal.taken_positions.has(room_pos + Vector2.UP):
			room.door_N = true
		if DungeonGlobal.taken_positions.has(room_pos + Vector2.DOWN):
			room.door_S = true
			
		room.set_up_room()
