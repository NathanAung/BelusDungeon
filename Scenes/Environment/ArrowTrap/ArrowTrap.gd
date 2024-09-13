extends AnimatedSprite

export var arrow_scene:PackedScene
var collider
var arrow_dir = Vector2(0, 1)
var shot = false


# Called when the node enters the scene tree for the first time.
func _ready():
	enableTrap(false)


func _physics_process(delta):
	if $RayCast2D.is_colliding():
		collider = $RayCast2D.get_collider()
		#print(collider.name)
		#print(collider.get_owner().name)
		
		# add collision exception for shields
		if collider.get_owner().name == "Shield":
			$RayCast2D.add_exception(collider)
			#print("arrow trap exception added")
		
		# shoot if raycast is colliding with the player and haven't shot yet
		if collider.get_owner().name == "Player" and !shot and !PlayerGlobal.player_dead:
			self.frame = 0;
			self.play("activate")
			shot = true
			$Timer.start()


func enableTrap(enable: bool):
	if enable:
		set_animation("idle")
		set_physics_process(true)
	else:
		set_animation("disabled")
		set_physics_process(false)


func playSFX():
	if AudioGlobal.sfx_settings:
		$ShootAudio.play()

# trap can shoot again after timer runs out
func _on_Timer_timeout():
	shot = false


func _on_ArrowTrap_animation_finished():
	if get_animation() == "activate":
		playSFX()
		var arrow = arrow_scene.instance()
		add_child(arrow)
		arrow.position = $Position2D.position
		arrow.direction = arrow_dir
		play("retract")
