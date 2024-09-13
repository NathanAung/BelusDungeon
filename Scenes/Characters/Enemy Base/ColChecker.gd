extends Node2D

onready var hurtbox = get_parent().get_node("AnimatedSprite/Hurtbox")
onready var collision_shape = get_parent().get_node("CollisionShape2D")
onready var pits_map = get_parent().current_room.get_node("RoomMap").get_child(1)
onready var wall_map = get_parent().current_room.get_node("RoomMap").get_child(2)

# positions traveled, added to not return to them
var pos_traveled:Array = []
# last direction vector(up, down, left, right), to avoid rubber banding
var last_vector:Vector2 = Vector2.ZERO
# current indexed position of the path
var index_pos:Vector2 = Vector2.ZERO


func _ready():
	add_exceptions()


# get a position free from obstacles
func get_free_pos() -> Vector2:
	var Npos = index_pos + Vector2(0,-60)
	var Epos = index_pos +  Vector2(60,0)
	var Wpos = index_pos +  Vector2(-60,0)
	var Spos = index_pos +  Vector2(0,60)
	var Ndist
	var Edist
	var Wdist
	var Sdist
	var dist_arr = []
	
	if not $ColCheckerN.is_colliding() and last_vector != Vector2.DOWN and not pos_traveled.has((Npos/40).floor()*40):
		#Npos = global_position + Vector2(0,-40)
		Ndist = Npos.distance_to(get_parent().Player.global_position)
		dist_arr.append(Ndist)
#	elif $ColCheckerN.is_colliding():
#		print("N colliding with ", $ColCheckerN.get_collider().name, " at ", Npos.floor())
#	else:
#		print("last pos S")
		
	if not $ColCheckerE.is_colliding() and last_vector != Vector2.LEFT and not pos_traveled.has((Epos/40).floor()*40):
		#Epos = global_position +  Vector2(40,0)
		Edist = Epos.distance_to(get_parent().Player.global_position)
		dist_arr.append(Edist)
#	elif $ColCheckerE.is_colliding():
#		print("E colliding with ", $ColCheckerE.get_collider().name, " at ", Epos.floor())
#	else:
#		print("last pos W")
		
	if not $ColCheckerW.is_colliding() and last_vector != Vector2.RIGHT and not pos_traveled.has((Wpos/40).floor()*40):
		#Wpos = global_position +  Vector2(-40,0)
		Wdist = Wpos.distance_to(get_parent().Player.global_position)
		dist_arr.append(Wdist)
#	elif $ColCheckerW.is_colliding():
#		print("W colliding with ", $ColCheckerW.get_collider().name, " at ", Wpos.floor())
#	else:
#		print("last pos E")
		
	if not $ColCheckerS.is_colliding() and last_vector != Vector2.UP and not pos_traveled.has((Spos/40).floor()*40):
		#Spos = global_position +  Vector2(0,40)
		Sdist = Spos.distance_to(get_parent().Player.global_position)
		dist_arr.append(Sdist)
#	elif $ColCheckerS.is_colliding():
#		print("S colliding with ", $ColCheckerS.get_collider().name, " at ", Spos.floor())
#	else:
#		print("last pos N")
	
	var shortest_dist = dist_arr.min()
	match shortest_dist:
		Ndist:
			#print("moved North, ", Npos.floor())
			last_vector = Vector2.UP
			return Npos
		Edist:
			#print("moved East, ", Epos.floor())
			last_vector = Vector2.RIGHT
			return Epos
		Wdist:
			#print("moved West, ", Wpos.floor())
			last_vector = Vector2.LEFT
			return Wpos
		Sdist:
			#print("moved South, ", Spos.floor())
			last_vector = Vector2.DOWN
			return Spos
			
	return get_parent().global_position


# get a path free of obstacles
func get_free_path() -> Array:
	if pos_traveled.size() >= 25:
		pos_traveled = []
	
	var free_path = []
	last_vector = Vector2.ZERO
	var p = (get_parent().global_position/40).floor() * 40
	if pits_map.get_cellv(p) == -1 and wall_map.get_cellv(p) == -1:
		index_pos = (get_parent().global_position/40).floor() * 40
	#index_pos = (get_parent().global_position/40).floor() * 40
	index_pos = global_position
	#print("path start")
	for i in 5:
		var pos = get_free_pos()
		free_path.append(pos)
		pos_traveled.append((pos/40).floor()*40)
		index_pos = pos
		global_position = pos
		if pos.distance_to(get_parent().Player.global_position) < 40:
			break
	global_position = get_parent().global_position
	#print("path end")
	return free_path


# add own collision shapes to the exceptions
func add_exceptions():
	$ColCheckerN.add_exception(get_owner())
	$ColCheckerE.add_exception(get_owner())
	$ColCheckerW.add_exception(get_owner())
	$ColCheckerS.add_exception(get_owner())
	$ColCheckerN.add_exception(hurtbox)
	$ColCheckerE.add_exception(hurtbox)
	$ColCheckerW.add_exception(hurtbox)
	$ColCheckerS.add_exception(hurtbox)
