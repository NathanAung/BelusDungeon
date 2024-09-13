extends Node2D

# folder path for the template scenes
export var folder_path = "res://Scenes/Environment/RoomTileMap/"
# max number of floor and pits scenes
export var floor_max = 4
export var pits_4_way_max = 14
export var pits_NS_max = 3
export var pits_WE_max = 3
export var pits_SE_max = 3
export var pits_SW_max = 3
export var pits_NW_max = 3
export var pits_NE_max = 3
export var pits_NWE_max = 4
export var pits_SWE_max = 4
export var pits_NWS_max = 4
export var pits_NES_max = 4

# floor/pits number to be selected
var floor_no = 0
var pits_no = 0
var rng = RandomNumberGenerator.new()
var pits_map

# A-Star node for path-finding
onready var astar_node = AStar.new()
# for a-star pathfinding
export(Vector2) var map_size = Vector2(16, 9)
var _point_path = []
# start/end pos of pathfinding uses setter/getters
var path_start_position = Vector2() setget _set_path_start_position
var path_end_position = Vector2() setget _set_path_end_position
var obstacles
var half_cell_size

var enemy_dir:Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


# randomly select a floor map and pits map depending on the room type and doors
func set_room_map(room_type, door_N, door_E, door_W, door_S):
	floor_no = rng.randi_range(0, floor_max)
	
	var floor_scene = load(folder_path + "Floor" + String(floor_no) + ".tscn")
	var floor_instance = floor_scene.instance()
	add_child(floor_instance)
	move_child(floor_instance, 0)
	#floor_instance.hide()
	
	pits_no = rng.randi_range(0, pits_4_way_max)
	var pits_scene
	
	# Don't add pits to special rooms
	if room_type != DungeonGlobal.room_type.normal:
		pits_no = 0
		pits_scene = load(folder_path + "Pit4Way" + String(pits_no) + ".tscn")
	#and rng.randi_range(0,1) == 0
	elif door_N and door_S and !door_W and !door_E:
		pits_no = rng.randi_range(0, pits_NS_max)
		pits_scene = load(folder_path + "PitNS" + String(pits_no) + ".tscn")
	elif door_W and door_E and !door_N and !door_S:
		pits_no = rng.randi_range(0, pits_WE_max)
		pits_scene = load(folder_path + "PitWE" + String(pits_no) + ".tscn")
	elif door_S and door_E and !door_N and !door_W:
		pits_no = rng.randi_range(0, pits_SE_max)
		pits_scene = load(folder_path + "PitSE" + String(pits_no) + ".tscn")
		#pits_scene = load(folder_path + "PitSE" + String(1) + ".tscn")
	elif door_S and door_W and !door_N and !door_E:
		pits_no = rng.randi_range(0, pits_SW_max)
		pits_scene = load(folder_path + "PitSW" + String(pits_no) + ".tscn")
		#pits_scene = load(folder_path + "PitSW" + String(1) + ".tscn")
	elif door_N and door_W and !door_S and !door_E:
		pits_no = rng.randi_range(0, pits_NW_max)
		pits_scene = load(folder_path + "PitNW" + String(pits_no) + ".tscn")
		#pits_scene = load(folder_path + "PitNW" + String(1) + ".tscn")
	elif door_N and door_E and !door_W and !door_S:
		pits_no = rng.randi_range(0, pits_NE_max)
		pits_scene = load(folder_path + "PitNE" + String(pits_no) + ".tscn")
		#pits_scene = load(folder_path + "PitNE" + String(1) + ".tscn")
	elif door_N and door_E and door_W and !door_S:
		pits_no = rng.randi_range(0, pits_NWE_max)
		pits_scene = load(folder_path + "PitNWE" + String(pits_no) + ".tscn")
	elif !door_N and door_E and door_W and door_S:
		pits_no = rng.randi_range(0, pits_SWE_max)
		pits_scene = load(folder_path + "PitSWE" + String(pits_no) + ".tscn")
	elif door_N and !door_E and door_W and door_S:
		pits_no = rng.randi_range(0, pits_NWS_max)
		pits_scene = load(folder_path + "PitNWS" + String(pits_no) + ".tscn")
	elif door_N and door_E and !door_W and door_S:
		pits_no = rng.randi_range(0, pits_NES_max)
		pits_scene = load(folder_path + "PitNES" + String(pits_no) + ".tscn")
	else:
		pits_scene = load(folder_path + "Pit4Way" + String(pits_no) + ".tscn")
	
	#Debug
#	pits_no = 3
#	pits_scene = load(folder_path + "PitNES" + String(pits_no) + ".tscn")
	
	pits_map = pits_scene.instance()
	add_child(pits_map)
	move_child(pits_map, 1)
	_set_astar()


# set up the AStar pathfinding
func _set_astar() -> void:
	obstacles = pits_map.get_used_cells()
	obstacles += $Walls.get_used_cells()
	#print(obstacles.size())
	half_cell_size = pits_map.cell_size / 2
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)


# Loops through all cells within the map's bounds and adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	for y in range(map_size.y):
		for x in range(map_size.x):
			var point = Vector2(x, y)
			if point in obstacles:
				continue

			points_array.append(point)
			# The AStar class references points with indices
			var point_index = calculate_point_index(point)
			# AStar uses Vector3
			astar_node.add_point(point_index, Vector3(point.x, point.y, 0.0))
	return points_array


# connects the walkable cells on the tilemap
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# Check up, down, left, right of every cell, connect if there is no obstacle
		var points_relative = PoolVector2Array([
			Vector2(point.x + 1, point.y),
			Vector2(point.x - 1, point.y),
			Vector2(point.x, point.y + 1),
			Vector2(point.x, point.y - 1)])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if is_outside_map_bounds(point_relative):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# 3rd argument is reverse direction, set to false
			astar_node.connect_points(point_index, point_relative_index, false)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


# calculate the grid index (e.g. 0 to 122) from the Vector 2 point (e.g. (2,3))
func calculate_point_index(point):
#	print("calculating point to index")
#	print(point.x, " , ", map_size.x, " , ", point.y)
#	print(point.x + map_size.x * point.y)
#	print("end")
	return point.x + map_size.x * point.y


func find_path(world_start, world_end, move_dir):
#	print("FINDING PATH")
	enemy_dir = move_dir
	# set functions are called here
	var local_start = pits_map.to_local(world_start)
	self.path_start_position = pits_map.world_to_map(local_start)
	#print("start pos: ", path_start_position)
	var local_end = pits_map.to_local(world_end)
	self.path_end_position = pits_map.world_to_map(local_end)
	#print("end pos: ", path_end_position)
	_recalculate_path()
	var path_world = []
	if _point_path.empty():
		print("path empty")
	for point in _point_path:
		var point_world = pits_map.to_global(pits_map.map_to_world(Vector2(point.x, point.y)) + Vector2(20, 38))
		path_world.append(point_world)
	#print("path array: ", path_world)
	return path_world


func _recalculate_path():
	#clear_previous_path_drawing()
	# get the grid indexes
	var start_point_index = calculate_point_index(path_start_position)
	#print("start point index: ", start_point_index)
	var end_point_index = calculate_point_index(path_end_position)
	#print("end point index: ", end_point_index)
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
	#update()


func _set_path_start_position(value):
	var nx = min(max(value.x, 3), 14)
	var ny = min(max(value.y, 3), 7)
	# return if an obstacle is at the position
	if is_outside_map_bounds(value):
		return
	elif value in obstacles:
#		print("start point in obstacle")
#		print("current point: ", Vector2(nx, ny))
#		print("Enemy V2 dir is: ", enemy_dir)
		
#		var points_relative = PoolVector2Array([
#			Vector2(value.x + 1, value.y),
#			Vector2(value.x - 1, value.y),
#			Vector2(value.x, value.y + 1),
#			Vector2(value.x, value.y - 1)])
#		for point_relative in points_relative:
#			if not point_relative in obstacles and not is_outside_map_bounds(point_relative):
#				path_start_position = point_relative
#				print("fixed start pos: ", point_relative)
#				break
		if enemy_dir.x > 0:
			nx = value.x - 1
		elif enemy_dir.x < 0:
			nx = value.x + 1
		if enemy_dir.y > 0:
			ny = value.y - 1
		elif enemy_dir.y < 0:
			ny = value.y + 1
		
		if Vector2(nx, ny) in obstacles:
			#print("NEW START POINT IN OBSTACLES")
			var points_relative = PoolVector2Array([
			Vector2(nx + 1, ny),
			Vector2(nx - 1, ny),
			Vector2(nx, ny + 1),
			Vector2(nx, ny - 1)])
			for point_relative in points_relative:
				if not point_relative in obstacles and not is_outside_map_bounds(point_relative):
					nx = point_relative.x
					ny = point_relative.y
					break
		#print("START POINT FIXED")
		
	path_start_position = Vector2(nx, ny)
	
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	var nx = min(max(value.x, 3), 14)
	var ny = min(max(value.y, 3), 7)
	if is_outside_map_bounds(value):
		return
	elif value in obstacles:
#		print("end point in obstacle")
#		print("current point: ", Vector2(nx, ny))
		var points_relative = PoolVector2Array([
			Vector2(nx + 1, ny),
			Vector2(nx - 1, ny),
			Vector2(nx, ny + 1),
			Vector2(nx, ny - 1)])
		for point_relative in points_relative:
			if not point_relative in obstacles and not is_outside_map_bounds(point_relative):
				path_end_position = point_relative
				#print("END POINT FIXED")
				break
	else:
		path_end_position = Vector2(nx, ny)
	
	if path_start_position != value:
		_recalculate_path()

