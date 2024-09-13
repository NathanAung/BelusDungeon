extends Node2D

class_name ObstacleGen

export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
export var obstacle_scene:PackedScene
export var falling_rock_scene:PackedScene
# parent room
onready var room = get_parent()
# rng node
var rng = RandomNumberGenerator.new()
# obstacle types
var obs_types:Dictionary = {"bush" : 0, "rock" : 1, "pot" : 2}


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()


func create_obstacles():
	# if its a normal room 
	if room.type == DungeonGlobal.room_type.normal:
		var obstacle_number = rng.randi_range(0, 8)
		
		for i in obstacle_number:
			# instance in available position
			var start_x = 4
			var start_y = 4
			var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
			var pits_map = room.room_map.get_child(1)
			
			while room.taken_positions_floor.has(pos) or pits_map.get_cellv(pos) != -1:
					pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
			room.taken_positions_floor.append(pos)
			var obstacle = obstacle_scene.instance()
			#room.call_deferred("add_child", obstacle)
			room.add_child(obstacle)
			obstacle.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
			obstacle.room_pos = pos
			#obstacle.call_deferred("set_obstacle", rng.randi_range(0,2))
			obstacle.set_obstacle(rng.randi_range(0,2))
			

func drop_rocks() -> void:
	var rock_number = rng.randi_range(8, 15)
	if room.taken_positions_floor.size() + rock_number > 55:
		rock_number -= (room.taken_positions_floor.size() + rock_number) - 55
		print("rock number exceeded, reduced to ", rock_number)
	for i in rock_number:
		# instance in available position
		var start_x = 4
		var start_y = 4
		var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
		var pits_map = room.room_map.get_child(1)

		while room.taken_positions_floor.has(pos) or pits_map.get_cellv(pos) != -1:
				pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
		room.taken_positions_floor.append(pos)
		#print("rock added, size: ", room.taken_positions_floor.size())
		var rock = falling_rock_scene.instance()
		room.add_child(rock)
		rock.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
		rock.room_pos = pos
		$Timer.start()
		yield($Timer, "timeout")


#func drop_rocks() -> void:
#	var obstacle_number = rng.randi_range(4, 7)
#	for i in obstacle_number:
#		# instance in available position
#		var start_x = 4
#		var start_y = 4
#		var pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
#		var pits_map = room.room_map.get_child(1)
#
#		while room.taken_positions_floor.has(pos) or pits_map.get_cellv(pos) != -1:
#				pos = Vector2(rng.randi_range(start_x, DungeonGlobal.room_width_cell - 4), rng.randi_range(start_y, DungeonGlobal.room_height_cell - 4))
#		room.taken_positions_floor.append(pos)
#		var obstacle = obstacle_scene.instance()
#		#room.call_deferred("add_child", obstacle)
#		room.add_child(obstacle)
#		obstacle.position = Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20)
#		obstacle.room_pos = pos
#		#obstacle.set_deferred("position", Vector2((pos.x * DungeonGlobal.CELL_SIZE) + 20, (pos.y * DungeonGlobal.CELL_SIZE) + 20))
#		#obstacle.call_deferred("set_obstacle", 3)
#		obstacle.set_obstacle(3)
#		$Timer.start()
#		yield($Timer, "timeout")
#		#obstacle.get_node("AnimationPlayer").call_deferred("play", "rock2fall")


func _on_Timer_timeout():
	pass # Replace with function body.
