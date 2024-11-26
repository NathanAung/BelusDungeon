extends Node2D

# bitmasking
const NORTH = 1
const WEST = 2
const EAST = 4
const SOUTH = 8

# 2D array
var map_rooms = []
# the room tile in the map
export var map_room_scene:PackedScene
var boss_room


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# create the map by checking the created rooms
func create_map():
	# create empty 2D array
	for y in range(DungeonGlobal.dungeon_height):
		map_rooms.append([])
		map_rooms[y] = []
		for x in range(DungeonGlobal.dungeon_width):
			map_rooms[y].append([])
			map_rooms[y][x] = null
	
	for i in DungeonGlobal.taken_positions.size():
		# instantiate the room on map
		var map_room = map_room_scene.instance()
		add_child(map_room)
		# get position
		var room_pos_x = DungeonGlobal.taken_positions[i].x
		var room_pos_y = DungeonGlobal.taken_positions[i].y
		# get the actual room
		var room = DungeonGlobal.rooms[room_pos_y][room_pos_x]
		# store in array
		map_rooms[room.grid_pos.y][room.grid_pos.x] = map_room
		# get and set the sprite index
		var sprite_no = NORTH * int(room.door_N) + EAST * int(room.door_E) + WEST * int(room.door_W) + SOUTH * int(room.door_S)
		map_room.set_frame(sprite_no)
		
		map_room.get_node("MapIcon").set_frame(room.type)
		if room.type == DungeonGlobal.room_type.boss:
			boss_room = map_room
		
		map_room.position = Vector2(room.grid_pos.x * 12, room.grid_pos.y * 12)
		
		# hide the room initially
		map_room.hide()


# move to the current room on the map
func map_set_room(old_x, old_y, new_x, new_y):
	# get old room
	var map_room = map_rooms[old_y][old_x]
	# unhighlight the sprite
	var sprite_no = map_room.get_frame() - 16
	if sprite_no >= 0:
		map_room.set_frame(sprite_no)
	# get the new room
	map_room = map_rooms[new_y][new_x]
	# highlight the sprite
	sprite_no = map_room.get_frame() + 16
	map_room.set_frame(sprite_no)
	# make the room visible on the map
	map_room.show()
	
	# make the connected rooms visible on the map
#	if new_x < DungeonGlobal.dungeon_width - 1:
#		if map_rooms[new_y][new_x + 1] != null:
#			map_rooms[new_y][new_x + 1].show()
#	if new_x > 0:
#		if map_rooms[new_y][new_x - 1] != null:
#			map_rooms[new_y][new_x - 1].show()
#	if new_y < DungeonGlobal.dungeon_height - 1:
#		if map_rooms[new_y + 1][new_x] != null:
#			map_rooms[new_y + 1][new_x].show()
#	if new_y > 0:
#		if map_rooms[new_y - 1][new_x] != null:
#			map_rooms[new_y - 1][new_x].show()
	
	# reset the position of the map and move to the new room's position
	position = Vector2(24, 24)
	position -= map_room.position


func show_boss_room() -> void:
	boss_room.show()
