extends AnimatedSprite


var rng = RandomNumberGenerator.new()
export var activate_time:float = 5
export var delay_time_default:float = 1
var first_delay_time:float
var first_delay:bool = true
var random_delay:bool = true
onready var col1:CollisionShape2D = get_node("Hitbox1/CollisionShape2D")
onready var col2:CollisionShape2D = get_node("Hitbox2/CollisionShape2D")


# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	enableTrap(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func enableTrap(enable: bool):
	if enable:
		set_animation("idle")
		$Flame.call_deferred("set_animation", "default")
		set_physics_process(true)
		if random_delay:
			$Timer.wait_time = rng.randf_range(1, activate_time)
		else:
			$Timer.wait_time = delay_time_default
		$Timer.start()
	else:
		set_animation("disabled")
		$Flame.call_deferred("set_animation", "disabled")
		set_physics_process(false)
		$Timer.stop()
		$AnimationPlayer.stop()
		col1.set_deferred("disabled", true)
		col2.set_deferred("disabled", true)
		$AudioStreamPlayer2D.set_deferred("playing", false)


func _on_Timer_timeout():
	$AnimationPlayer.play("Activate")
	if AudioGlobal.sfx_settings:
		$AudioStreamPlayer2D.playing = true


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Activate":
		if first_delay:
			$Timer.wait_time = activate_time
			first_delay = false
		$Timer.start()
		if AudioGlobal.sfx_settings:
			$AudioStreamPlayer2D.playing = false
