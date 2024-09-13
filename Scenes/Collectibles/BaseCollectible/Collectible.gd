extends Node2D

class_name Collectible

onready var player_detector: Area2D = get_node("PlayerDetector")
onready var tween: Tween = get_node("Tween")
# bottom text node from UI
export(NodePath) var btm_text_node_path = "/root/Main/PlayerUI/CanvasLayer/BottomText"
onready var btm_text_UI = get_node(btm_text_node_path)
# power up display node from UI
export(NodePath) var power_up_ui_node_path = "/root/Main/PlayerUI/CanvasLayer/PauseMenu/PowerUps"
onready var power_up_UI = get_node(power_up_ui_node_path)
var using_text:bool = false
# auto collect when player collides or require the player to interact
export var auto_collect:bool = true
var player
# the value of the collectible; gold acquired, health restored, key acquired, etc.
export(int) var value:int = 1
# for power ups
var in_shop:bool = false
export var item_name:String = "Item"
export var price:int = 10
export var upgradable:bool = false
export var item_level:int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func set_collectible(val: int) -> void:
	value = val
	if value > 1:
		get_node("Sprite").frame += 1


func _on_PlayerDetector_body_entered(body: KinematicBody2D):
	if body != null:
		if body.name == "Player":
			if auto_collect:
				Collect()
				queue_free()
			else:
				player = body
				show_description()
	else:
		var __ = tween.stop_all()
		assert(__)
		#player_detector.get_node("CollisionShape2D").disabled = false
		player_detector.set_collision_mask_bit(2, true)


func _on_PlayerDetector_body_exited(body):
	player = null
	hide_description()


# Show the description when player is on the collectible
func show_description():
	if !btm_text_UI.in_use:
		btm_text_UI.bbcode_text = "[right]" + item_name + "[color=lime]" + " [Effect]" + "[/color][/right]" 
		btm_text_UI.visible = true
		btm_text_UI.in_use = true
		using_text = true


func hide_description():
	if using_text:
		btm_text_UI.visible = false
		btm_text_UI.in_use = false
		using_text = false


# event inputs for picking up the power up
#func _input(event):
#	if Input.is_action_just_pressed("input_interact") and !auto_collect and player != null:
#		Collect()
#		player = null	# to avoid multiple collects
#		queue_free()


func Collect():
	pass


func interpolate_pos(initial_pos: Vector2, final_pos: Vector2) -> void:
	var __ = tween.interpolate_property(self, "global_position", initial_pos, final_pos, 0.8, Tween.TRANS_QUART, Tween.EASE_OUT)
	assert(__)
	__ = tween.start()
	assert(__)
	#player_detector.get_node("CollisionShape2D").disabled = true
	player_detector.set_collision_mask_bit(2, false)


func _on_Tween_tween_completed(object, key):
	#player_detector.get_node("CollisionShape2D").disabled = false
	player_detector.set_collision_mask_bit(2, true)
