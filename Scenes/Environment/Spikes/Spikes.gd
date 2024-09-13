extends Area2D

var Player
export(float) var damage:float = 1
var activated


# Called when the node enters the scene tree for the first time.
func _ready():
	enableTrap(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if activated and !PlayerGlobal.player_dead:
		# deal damage when the player's body overlaps during specific frames
		if overlaps_body(Player) and $AnimatedSprite.frame >= 6 and $AnimatedSprite.frame <= 10:
			Player.take_damage(damage, Vector2.ZERO, 0)
			activated = false
			# activate again if player is still standing
			$Timer.start()


func activate():
	#print("spikes activated")
	$AnimatedSprite.frame = 0
	$AnimatedSprite.play("activate")
	$SFXDelay.start()
	activated = true


func enableTrap(enable: bool):
	if enable:
		$AnimatedSprite.set_animation("activate")
		$AnimatedSprite.frame = 11
		set_physics_process(true)
	else:
		$AnimatedSprite.set_animation("disabled")
		set_physics_process(false)


func _on_Spikes_body_entered(body):
	if is_physics_processing() and body.name == "Player":
		activated = true
		# only start new animation if current one has ended
		if $AnimatedSprite.frame == 11:
			if Player == null:
				Player = body
			activate()


# deactivate and stop timer if player is not overlapping anymore
func _on_Spikes_body_exited(body):
	if body.name == "Player":
		activated = false
		$Timer.stop()


# activate again after 2 seconds
func _on_Timer_timeout():
	activate()


func _on_SFXDelay_timeout():
	if AudioGlobal.sfx_settings:
		$SpikeSFX.play()
