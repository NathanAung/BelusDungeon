extends KinematicBody2D


var Player
export var camera_speed = 800
var current_position
var new_position
var velocity
var moving = false
signal finished_moving()


# Called when the node enters the scene tree for the first time.
func _ready():
	Player = get_node(MiscGlobal.player_node_path)
	current_position = position
	new_position = position


func _physics_process(delta):
	# only update when moving
	if moving:
		velocity = position.direction_to(new_position) * camera_speed

		if position.distance_to(new_position) > 5:
			# disable player process
			Player.set_physics_process(false)
			Player.state_machine.set_state(Player.state_machine.states.idle)
			# add velocity
			velocity = move_and_slide(velocity)
		else:
			Player.in_transition = false
			# enable player process
			Player.set_physics_process(true)
			emit_signal("finished_moving")
			moving = false


func cam_move(new_pos):
	#print("new pos is ", new_pos)
	new_position = Vector2.ZERO
	# add cell size for padding
	new_position.x = new_pos.x + DungeonGlobal.CELL_SIZE
	new_position.y = new_pos.y + DungeonGlobal.CELL_SIZE
	moving = true


func cam_shake(shake_no):
	match shake_no:
		0:
			$AnimationPlayer.play("cam_shake")
		1:
			$AnimationPlayer.play("cam_slam")
		2:
			$AnimationPlayer.play("cam_hit")


#func cam_slam():
#	$AnimationPlayer.play("cam_slam")


#func cam_hit():
#	$AnimationPlayer.play("cam_hit")


func _on_CameraKB_finished_moving():
	pass # Replace with function body.
