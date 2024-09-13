extends AnimatedSprite


# Called when the node enters the scene tree for the first time.
func _ready():
	playing = true


func _on_Explosion_animation_finished():
	queue_free()
