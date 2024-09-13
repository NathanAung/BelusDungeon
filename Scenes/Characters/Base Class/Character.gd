extends KinematicBody2D

# base class for player and enemies
class_name Character

const FRICTION: float = 0.15

export(float) var HP: float = 3
export(int) var acceleration: int = 40
export(int) var max_speed: int = 100

onready var state_machine: Node = get_node("FiniteStateMachine")
onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")
var move_direction: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var attacking:bool = false


# apply velocity and friction
func _physics_process(delta):
	velocity = move_and_slide(velocity)
	velocity = lerp(velocity, Vector2.ZERO, FRICTION)


# move the character
func move():
	#move_direction = move_direction
	#print(move_direction)
	velocity += move_direction * acceleration
	velocity = velocity.clamped(max_speed)


# called when the character takes damage
func take_damage(dmg: float, dir: Vector2, force: int) -> void:
	pass
