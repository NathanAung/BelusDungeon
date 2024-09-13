extends AnimatedSprite


export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
export(NodePath) var cam_node_path = "/root/Main/CameraKB"
onready var Cam = get_node(cam_node_path)
export var food_scene:PackedScene
onready var rock_sfx = load("res://SFX/Environment/hurt4.wav")
var rng = RandomNumberGenerator.new()
var room_pos:Vector2 # tile pos in room


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	$AnimationPlayer.play("Falling")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func drop_item():
	if rng.randi_range(0, 5) == 0:
		var item  = food_scene.instance()
		Dungeon.current_room.call_deferred("add_child", item)
		item.call_deferred("set_owner", Dungeon.current_room)
		item.global_position = position


func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	$AnimationPlayer.play("Break")
	Dungeon.current_room.taken_positions_floor.erase(room_pos)
	print("rock removed, size: ", Dungeon.current_room.taken_positions_floor.size())
	playSFX()


func playSFX():
	if AudioGlobal.sfx_settings:
		$AudioStreamPlayer.stream = rock_sfx
		$AudioStreamPlayer.play()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Falling" and AudioGlobal.sfx_settings:
		$AudioStreamPlayer.play()
		Cam.cam_shake(2)
