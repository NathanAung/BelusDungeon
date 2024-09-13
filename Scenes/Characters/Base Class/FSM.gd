extends Node
# state machine script for characters
class_name FiniteStateMachine

var states: Dictionary = {}
var previous_state: int = -1
# setget to call automatically if the variable is changed outside of the script
var state: int = -1 setget set_state

onready var parent: Character = get_parent()
onready var animation_player: AnimationPlayer = parent.get_node("AnimationPlayer")
onready var animated_sprite: AnimatedSprite = parent.get_node("AnimatedSprite")


func _physics_process(delta):
	# set logic if the state is not null
	if state != -1:
		_state_logic(delta)
		# get transition and if it's not null, set the new state
		var transition: int = _get_transition()
		if transition != -1:
			set_state(transition)


# put the logic of the state
func _state_logic(_delta: float) -> void:
	pass


# get the state transition
func _get_transition() -> int:
	return -1


# add a new state to the states dictionary
func _add_state(new_state: String) -> void:
	states[new_state] = states.size()


# set the new state
func set_state(new_state: int) -> void:
	_exit_state(state)
	previous_state = state
	state = new_state
	_enter_state(previous_state, state)
	#print("state set" + String(state))


func _enter_state(_previous_state: int, _new_state: int) -> void:
	pass
	
	
func _exit_state(_state_exited: int) -> void:
	pass
