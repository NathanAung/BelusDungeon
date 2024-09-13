extends Area2D

export(NodePath) var player_node_path = MiscGlobal.player_node_path
onready var Player = get_node(player_node_path)
export(float) var damage:float = 1
export var speed = 300
var direction = Vector2.ZERO
var velocity
var hit = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func playSFX():
	if AudioGlobal.sfx_settings:
		$ExplodeAudio.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# when a direction is given, move towards it
	if direction != Vector2.ZERO and !hit:
		velocity = direction * speed * delta
		position += velocity


# for detecting walls and player
func _on_Arrow_body_entered(body):
	if body.is_in_group("Walls") and !hit:
		$AnimatedSprite.play("hit")
		playSFX()
		hit = true
	elif body.name == "Player" and !hit:
		#print("Player entered")
		Player.take_damage(damage, Vector2.ZERO, 0)
		$AnimatedSprite.play("hit")
		playSFX()
		hit = true
		


func _on_Arrow_area_entered(area):
	if area.name == "Hurtbox" and !hit:
		if area.get_owner().name == "Player":
			#print("Player entered")
			Player.take_damage(damage, Vector2.ZERO, 0)
			$AnimatedSprite.play("hit")
			playSFX()
			hit = true
			


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.get_animation() == "hit":
		queue_free()


