extends Node2D


# player node in main scene
export(NodePath) var player_node_path = MiscGlobal.player_node_path
onready var player: KinematicBody2D = get_node(player_node_path)
var boss: KinematicBody2D
var room: Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_started(anim_name):
	player.set_deferred("movement_disabled", true)
	boss.call_deferred("activate_boss")


func _on_AnimationPlayer_animation_finished(anim_name):
	player.set_deferred("movement_disabled", false)
	room.enable_room_traps(true)
