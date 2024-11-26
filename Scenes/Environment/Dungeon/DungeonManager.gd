extends Navigation2D


# camera node in main scene
export(NodePath) var cam_node_path = "/root/Main/CameraKB"
onready var Cam = get_node(cam_node_path)
# player node in main scene
export var player_scene:PackedScene
var Player
# map node in main scene
export(NodePath) var map_node_path = "/root/Main/PlayerUI/CanvasLayer/MapContainer/Map"
onready var Map = get_node(map_node_path)
# room name node from UI
export(NodePath) var room_name_node_path = "/root/Main/PlayerUI/CanvasLayer/RoomName"
onready var room_name_UI = get_node(room_name_node_path)
# dungeon generation script
onready var DungeonGen = get_node("DungeonGen")
# current room position + instance
export var current_room_x = 0
export var current_room_y = 0
var current_room
var first_enemy:bool = true # for spawning a single ogre as first enemy
var boss_defeated:bool = false
var can_pause:bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	# random seed
	randomize()
	
	current_room_x = DungeonGlobal.start_room_x
	current_room_y = DungeonGlobal.start_room_y
	
	# create empty 2D array
	for y in range(DungeonGlobal.dungeon_height):
		DungeonGlobal.rooms.append([])
		DungeonGlobal.rooms[y] = []
		for x in range(DungeonGlobal.dungeon_width):
			DungeonGlobal.rooms[y].append([])
			DungeonGlobal.rooms[y][x] = null
	
	
	# generate dungeon with the script
	DungeonGen.create_rooms()
	if !DungeonGen.gen_error:
		DungeonGen.set_up_rooms()
		DungeonGen.place_rooms()
		
		# generate map based on the dungeon
		Map.create_map()
		Map.map_set_room(current_room_x, current_room_y, current_room_x, current_room_y)
		
		# set current room
		current_room = DungeonGlobal.rooms[current_room_y][current_room_x]
		
		# move the player into the room
		Player = player_scene.instance()
		get_node("YSort").add_child(Player)
		if DungeonGlobal.current_floor == 1:
			Player.position = Vector2(current_room_x * DungeonGlobal.room_width + DungeonGlobal.room_width/2 - 35, current_room_y * DungeonGlobal.room_height + DungeonGlobal.room_height/2 + 10)
		else:
			Player.position = Vector2(current_room_x * DungeonGlobal.room_width + (DungeonGlobal.CELL_SIZE * 9), current_room_y * DungeonGlobal.room_height + (DungeonGlobal.CELL_SIZE * 8))
		# move the camera
		Cam.position = (Vector2(current_room_x * DungeonGlobal.room_width + DungeonGlobal.CELL_SIZE, current_room_y * DungeonGlobal.room_height + DungeonGlobal.CELL_SIZE))
		#current_room.open_doors(false)
		print("Number of rooms: ", DungeonGlobal.number_of_rooms)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#	if timer_on:
#		play_time += delta
#		print(play_time)


func _input(event):
	if event is InputEventKey:
		# open doors in current room when O Key is pressed
		if event.pressed and event.scancode == KEY_O:
			current_room.open_doors(!current_room.doors_open)


# room transition
func _enter_next_room(door_dir):
	#print(door_dir)
	var old_x = current_room_x
	var old_y = current_room_y
	var spawn_x
	var spawn_y
	
	match door_dir:
		"east":
			current_room_x += 1
			spawn_x = 3.5
			spawn_y = 5.5
		"west":
			current_room_x -= 1
			spawn_x = 14.5
			spawn_y = 5.5
		"north":
			current_room_y -= 1
			spawn_x = 9
			spawn_y = 8
		"south":
			current_room_y += 1
			spawn_x = 9
			spawn_y = 3.5
	
	var last_room = current_room
	current_room = DungeonGlobal.rooms[current_room_y][current_room_x]
	
	Map.map_set_room(old_x, old_y, current_room_x, current_room_y)
	
	var room_pos_x = current_room_x * DungeonGlobal.room_width
	var room_pos_y = current_room_y * DungeonGlobal.room_height
	
	Player.position.x = room_pos_x + (DungeonGlobal.CELL_SIZE * spawn_x)
	Player.position.y = room_pos_y + (DungeonGlobal.CELL_SIZE * spawn_y)
	if door_dir == "east":
		#print("sprite unflipped")
		Player.animated_sprite.flip_h = false
	elif door_dir == "west":
		#print("sprite flipped")
		Player.animated_sprite.flip_h = true
	Player.in_transition = true
	Cam.cam_move(Vector2(room_pos_x, room_pos_y))
	
	yield(Cam, "finished_moving")
	
	# clear the powerup items from the last room
	last_room.clear_items()
	
	if !current_room.room_cleared:
		# close doors only when camera finishes moving
		current_room.open_doors(false)
	
	if current_room.type in range(2,6):
		room_name_UI.text = current_room.room_name
		room_name_UI.get_node("AnimationPlayer").play("Drop")
		
		current_room.allocate_room_points()
	
	# spawn weapon pot
	if current_room.type in range(0,2) and Player.unarmed:
		current_room.spawn_item(current_room.item_no.weapon_pot)
	
	AudioGlobal.change_music(current_room.type)

