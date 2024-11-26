extends Node2D

# DUNGEON
# dungeon width/height in rooms
#10,10
export var dungeon_width = 20
export var dungeon_height = 20
#4,9
export var start_room_x = 10
export var start_room_y = 10
# 2D array of rooms
var rooms = []
# array of taken positions in the room grid
var taken_positions = []
# array if ignored positions in the dungeon generation
var ignored_positions = []
export var number_of_rooms_default = 23
var number_of_rooms = number_of_rooms_default
export var max_rooms = 50
export var current_floor = 1
export var cleared_rooms:int = 0
export var lv2_cleared_rooms:int = 6
export var lv3_cleared_rooms:int = 12
export var floor_level:int = 1 # for difficulty
var in_game_clear_scene:bool = false

# ROOM
# width/height of a tile
const CELL_SIZE = 40
export var room_width_cell = 18
export var room_height_cell = 11
# width/height of the room in pixels
var room_width = room_width_cell * CELL_SIZE
var room_height = room_height_cell * CELL_SIZE
# types of rooms
var room_type = {"normal" : 0, "start" : 1, "boss" : 2, "healing" : 3, "shop" : 4, "treasure" : 5}
# canvas node path
export(NodePath) var canvas_path = "/root/Main/PlayerUI/CanvasLayer"
# points for clearing the floor
export var floor_clear_points:int = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		# F to go to new floor
#		if event.scancode == KEY_F:
#			next_floor()
		# R to restart
		if event.scancode == KEY_R:
			restart(false)
		if event.scancode == KEY_I and !in_game_clear_scene:
			PlayerGlobal.play_timer_on = false
			game_clear()
#		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# going to the next floor, adds a room to number of rooms
func next_floor():
	PlayerGlobal.player_score_current += floor_clear_points
	# fade in to black with canvas
	var canvas = get_node(canvas_path)
	if !canvas.in_transition:
		canvas.transition(true)
		yield(canvas, "transitioned")
	# increase no. of rooms, reset rooms
	if number_of_rooms < max_rooms:
		number_of_rooms += 2
	current_floor += 1
	DungeonGlobal.rooms = []
	DungeonGlobal.taken_positions = []
	
	ItemGlobal.save_weapons()
	
	get_tree().change_scene("res://Scenes/Main/Main.tscn")
	# unpause if paused
	canvas.get_node("PauseMenu").pause_game(false)


# for restarting the game
func restart(back_to_menu):
	# fade in to black with canvas
	if !in_game_clear_scene:
		var canvas = get_node(canvas_path)
		if !canvas.in_transition:
			canvas.transition(true)
			yield(canvas, "transitioned")
	if back_to_menu:
		PlayerGlobal.in_menu = true
	# reset globals
	number_of_rooms = number_of_rooms_default
	current_floor = 1
	floor_level = 1
	cleared_rooms = 0
	DungeonGlobal.rooms = []
	DungeonGlobal.taken_positions = []
	# reset player
	PlayerGlobal.reset_player()
	
	get_tree().change_scene("res://Scenes/Main/Main.tscn")
	# restart the music
	AudioGlobal.music_off_fixed = false 
	AudioGlobal.music_on_off(AudioGlobal.music_settings, false)
	if back_to_menu:
		AudioGlobal.change_music(AudioGlobal.title_track)
	else:
		AudioGlobal.change_music(room_type.normal)
	AudioGlobal.seek(0)
	# unpause if paused
	if !in_game_clear_scene:
		var canvas = get_node(canvas_path)
		canvas.get_node("PauseMenu").pause_game(false)
	in_game_clear_scene = false
	
	if back_to_menu:
		PlayerGlobal.play_timer_on = false


# for restarting a floor if there's an error
func restart_floor():
	print("restarting floor")
	DungeonGlobal.rooms = []
	DungeonGlobal.taken_positions = []
	get_tree().change_scene("res://Scenes/Main/Main.tscn")


func game_clear():
	var canvas = get_node(canvas_path)
	canvas.transition_white(true)
	yield(canvas, "transitioned")
	get_tree().change_scene("res://Scenes/GameClear/GameClear.tscn")
