extends Control


# player node in main scene
export(NodePath) var player_node_path = MiscGlobal.player_node_path
onready var Player: KinematicBody2D = get_node(player_node_path)
# UI nide
export(NodePath) var UI_node_path = "/root/Main/PlayerUI/CanvasLayer"
onready var UI_node = get_node(UI_node_path)
var options_menu
var quit_menu
var credits_menu
var first_hover:bool = true	# for play button sfx to not activate when the game starts
var movable:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	options_menu = get_parent().get_node("OptionsMenu")
	options_menu.last_menu = self
	quit_menu = get_parent().get_node("QuitMenu")
	quit_menu.last_menu = self
	credits_menu = get_parent().get_node("CreditsMenu")
	$ButtonMenu/PlayBtn.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _input(event):
	if visible and PlayerGlobal.in_menu and movable:
		# remove selection focus if the mouse is moved
		if event is InputEventMouseMotion and get_focus_owner() != null:
			var current_focus = get_focus_owner()
			#current_focus.release_focus()
		elif get_focus_owner() == null:
			if event.is_action_pressed("ui_up"): 
				$ButtonMenu/OptionsBtn.grab_focus()
			elif event.is_action_pressed("ui_down"):
				$ButtonMenu/QuitBtn.grab_focus()


# for play button
func start_game() -> void:
	PlayerGlobal.in_menu = false
	Player.state_machine.set_state(Player.state_machine.states.stand_up)
	#Player.current_weapon.show()
	get_parent().hide()
	visible = false
	UI_node.show_UI()
	AudioGlobal.change_music(DungeonGlobal.room_type.normal)


func _on_MainMenu_visibility_changed():
	if visible:
		$ButtonMenu/PlayBtn.grab_focus()


func _on_PlayBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.start_game)
	get_node("../..").get_node("AnimationPlayer").play("FadeOut")


func _on_OptionsBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	options_menu.visible = true


func _on_CreditsBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	credits_menu.visible = true


func _on_QuitBtn_pressed():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	visible = false
	quit_menu.visible = true


func _on_PlayBtn_focus_entered():
	# make sure the sfx doesn't play on start up
	if !first_hover and $ButtonMenu.visible:
		AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
	elif first_hover:
		first_hover = false
func _on_PlayBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_OptionsBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_OptionsBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_CreditsBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_CreditsBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_QuitBtn_focus_entered():
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
func _on_QuitBtn_mouse_entered():
	if get_focus_owner() != null:
		get_focus_owner().release_focus()
	AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)

