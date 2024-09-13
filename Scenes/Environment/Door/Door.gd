extends Area2D


var Player
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# map node in main scene
export(NodePath) var map_node_path = "/root/Main/PlayerUI/CanvasLayer/MapContainer/Map"
export(NodePath) var canvas_path = "/root/Main/PlayerUI/CanvasLayer"
var Map
# door direction
export var door_dir = "north"
# type of room
# 0 = normal, 1 = starting door, 2 = boss, 3 = healing, 4 = shop, 5 = treasure, 6 = elevator
var type
# for opening/closing door
var door_open = true
# signal for room transition
signal door_entered(door_dir)
var locked:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("door_entered", Dungeon, "_enter_next_room")
	
	# initially disble door
	hide()
	set_physics_process(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if door_open:
		$AnimatedSprite.animation = "Open"
		$Lock.animation = "Unlock"
	else:
		$AnimatedSprite.animation = "Close"
		$Lock.animation = "Lock"
		
	if Input.is_action_just_pressed("input_interact") and Player!= null:
		if overlaps_body(Player):
			# unlock boss door
			if locked and Dungeon.current_room.room_cleared:
				if PlayerGlobal.keys_collected > 0:
					print("Door unlocked!")
					door_open = true
					PlayerGlobal.keys_collected -= 1
					locked = false
					AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorOpen)
					Player.interact_indi.playing = false
					Player.interact_indi.hide()
					Map.show_boss_room()
				else:
					AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorLocked)
					print("Door locked! Find the key")
			# enter room
			elif !locked and visible and door_open:
				# pass if starting door
				if type == 1:
					pass
				# go to game clear screen for exit door
				elif type == 6:
					#DungeonGlobal.next_floor()
					Dungeon.can_pause = false
					AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorEnter)
					Player.set_physics_process(false)
					DungeonGlobal.game_clear()
				# enter to next room
				else:
					AudioGlobal.play_SFX(AudioGlobal.SFX_type.doorEnter)
					emit_signal("door_entered", door_dir)


func _on_Door_body_entered(body):
	if body.name == "Player":
		if Player == null:
			Player = body
		if visible and Dungeon.current_room.room_cleared and (door_open or (locked and PlayerGlobal.keys_collected > 0)):
			Player.interact_indi.playing = true
			Player.interact_indi.show()


func _on_Door_body_exited(body):
	if body.name == "Player" and visible:
		Player.interact_indi.playing = false
		Player.interact_indi.hide()


# set the door icon on visible
func _on_AnimatedSprite_visibility_changed():
	if visible:
		get_node("DoorIcon").frame = type
		if type == 2:
			$Lock.visible = true
	if locked:
		Map = get_node(map_node_path)
