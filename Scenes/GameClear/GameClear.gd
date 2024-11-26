extends Node2D


#onready var win_text_anim:AnimationPlayer = get_node("CanvasLayer/Control/WinText/AnimationPlayer")
onready var score_text:Label = get_node("CanvasLayer/Control/FinalScore")
onready var time_text:Label = get_node("CanvasLayer/Control/PlayTime")
onready var eng_text:Label = get_node("CanvasLayer/Control/EngText")
onready var dif_text:Label = get_node("CanvasLayer/Control/Difficulty")
#onready var label_text:Label = get_node("CanvasLayer/Control/WinText/InstructionText")
onready var credits_text:Label = get_node("CanvasLayer/Control/Credits")
onready var press_space_text:Label = get_node("CanvasLayer/Control/PressSpace")
var fade_in_complete:bool = false
var return_to_menu:bool = false
var in_transition:bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	$CanvasLayer/ColorRect.color = Color(255, 255, 255, 255)
	DungeonGlobal.in_game_clear_scene = true
	game_clear()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if in_transition:
			return
		if event.scancode == KEY_SPACE and press_space_text.visible:
			if !score_text.visible and !credits_text.visible:
				$AnimationPlayer.play("FadeIn")
				AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
				press_space_text.visible = false
				$Timer.start()
			elif score_text.visible:
				$AnimationPlayer.play("FadeOut")
				score_text.visible = false
				time_text.visible = false
				eng_text.visible = false
				dif_text.visible = false
				AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
				press_space_text.visible = false
				$Timer.start()
			elif credits_text.visible:
				$AnimationPlayer.play("HideCredits")
				AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)
				press_space_text.visible = false
#		elif event.scancode == KEY_ESCAPE and label_text.visible:
#			return_to_menu = true
#			$AnimationPlayer.play("to_black")
#			AudioGlobal.play_SFX(AudioGlobal.SFX_type.menu)


func game_clear():
	transition_white(false)
	if PlayerGlobal.player_score_current > PlayerGlobal.player_score_highest:
		score_text.text = "NEW HIGH SCORE: " + String(PlayerGlobal.player_score_current)
		PlayerGlobal.player_score_highest = PlayerGlobal.player_score_current
	else:
		score_text.text = "Final Score: " + String(PlayerGlobal.player_score_current)
		
	var format_string = "%02d:%02d:%02d"
	if PlayerGlobal.play_time_current < PlayerGlobal.play_time_best or PlayerGlobal.play_time_best == 0:
		print("Play Time: ", PlayerGlobal.play_time_current)
		time_text.text = "NEW BEST TIME: " + format_string % [PlayerGlobal.play_time_current/60, fmod(PlayerGlobal.play_time_current, 60), fmod(PlayerGlobal.play_time_current, 1) * 100]
		PlayerGlobal.play_time_best = PlayerGlobal.play_time_current
	else:
		#display current play time
		print("Play Time: ", PlayerGlobal.play_time_current)
		time_text.text = "Play Time: " + format_string % [PlayerGlobal.play_time_current/60, fmod(PlayerGlobal.play_time_current, 60), fmod(PlayerGlobal.play_time_current, 1) * 100]
	
	match MiscGlobal.game_difficulty:
		0:
			dif_text.text = "Difficulty: NORMAL"
		1:
			dif_text.text = "Difficulty: EASY"
	
	SaveGlobal.save_game()


# canvas layer color rect
# true = to black, false = from black
func transition(black):
	if black:
		$AnimationPlayer.play("to_black")
	else:
		$AnimationPlayer.play("from_black")

# true = to white, false = from white
func transition_white(white):
	if white:
		$AnimationPlayer.play("to_white")
	else:
		$AnimationPlayer.play("from_white")


func _on_AnimationPlayer_animation_finished(anim_name):
	in_transition = false
	if anim_name == "to_black":
		if return_to_menu:
			DungeonGlobal.restart(true)
		else:
			DungeonGlobal.restart(false)
#	elif anim_name == "from_white":
#			AudioGlobal.music_off_fixed = false
#			AudioGlobal.change_music(AudioGlobal.victory_track)
#			AudioGlobal.music_on_off(AudioGlobal.music_settings, false)
	elif anim_name == "FadeIn":
		score_text.visible = true
		time_text.visible = true
		eng_text.visible = true
		dif_text.visible = true
		fade_in_complete = true
	elif anim_name == "FadeOut":
		$AnimationPlayer.play("ShowCredits")
	elif anim_name == "HideCredits":
		return_to_menu = true
		$AnimationPlayer.play("to_black")


func _on_AnimationPlayer_animation_started(anim_name):
	in_transition = true
	if anim_name == "from_white":
		AudioGlobal.music_off_fixed = false
		AudioGlobal.change_music(AudioGlobal.victory_track)
		AudioGlobal.music_on_off(AudioGlobal.music_settings, false)


func _on_Timer_timeout():
	press_space_text.visible = true

