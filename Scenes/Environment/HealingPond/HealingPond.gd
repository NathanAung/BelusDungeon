extends Area2D


var Player
export(NodePath) var health_node_path = "/root/Main/PlayerUI/CanvasLayer/Health"
onready var Health = get_node(health_node_path)
var activated:bool = false

#var playerInRoom = false

# Called when the node enters the scene tree for the first time.
#func _ready():
#	$AnimatedSprite.animation = "idle"


func _physics_process(delta):
	if Input.is_action_just_pressed("input_interact") and !activated and Player != null:
		if overlaps_body(Player):
			activate()
			activated = true
	
#	if playerInRoom:
#		if AudioGlobal.volume_db > -60:
#			AudioGlobal.volume_db -= 0.5
#	else:
#		if AudioGlobal.volume_db < 0:
#			AudioGlobal.volume_db += 1


func activate():
	#$AnimatedSprite.animation = "activate"
	$AnimationPlayer.play("activate")
	if AudioGlobal.sfx_settings:
		$AudioStreamPlayer.play()
	PlayerGlobal.player_HP_current = PlayerGlobal.player_HP_max
	Health.update_health()
	print("Player HP fully restored!")
	Player.interact_indi.playing = false
	Player.interact_indi.hide()


func _on_HealingPond_body_entered(body):
	if body.name == "Player":
		if Player == null:
			Player = body
		if !activated:
			Player.interact_indi.playing = true
			Player.interact_indi.show()


func _on_HealingPond_body_exited(body):
	if body.name == "Player" and Player != null:
		Player.interact_indi.playing = false
		Player.interact_indi.hide()
