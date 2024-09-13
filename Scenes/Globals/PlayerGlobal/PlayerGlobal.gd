extends Node2D

# signal for updating the UI
signal score_changed()
signal gold_changed()
signal keys_changed()

# HP
var player_HP_default:float = 8 #8
var player_HP_current:float = player_HP_default
var player_HP_max:float = player_HP_default
var player_HP_limit:float = 20
# for disabling hostile attacks when dead
var player_dead:bool = false
# weapon slots
var player_WS_default:int = 3 #2
var player_WS_current:int = player_WS_default
var player_WS_limit:int = 6
# for saving weapons to next floor
var current_weapons = []
var last_weapon_index = 0
# gold
var player_Gold_default:int = 0
var player_Gold_current:int = player_Gold_default setget _set_player_gold
var player_Gold_limit:int = 1000
# score
var player_score_current:int = 0 setget _set_player_score
var player_score_highest:int = 0
# dash count
var player_DC_default:int = 1 #1
export(int) var player_DC_current:int = player_DC_default
var player_DC_limit:int = 5
# boss room key
var keys_collected:int = 0 setget _set_player_keys
# power ups
var power_up_dict = {"extra_heart":0, "weapon_slot":1, "boot":2, "revive":3, "banana":4, "weapon_pot":5}
var collected_power_ups = []
# death protection
var player_death_protection:bool = false
# bonus damage
var player_bonus_dmg_current:float = 0
var player_bonus_dmg_limit:float = 1
# weapon pot
var player_weapon_pot_current:int = 0
var player_weapon_pot_limit:int = 3
# armor
var player_armor_level:int = 1 # Bronze = 1, Silver = 2, Gold = 3
var player_armor_current:float = 0
var player_armor_max:float = 0
# for main menu
var in_menu:bool = true


# Called when the node enters the scene tree for the first time.
#func _ready():
#	player_HP_current = player_HP_max


func _set_player_score(score):
	player_score_current = score
	emit_signal("score_changed")


func _set_player_gold(gold):
	player_Gold_current = gold
	emit_signal("gold_changed")


func _set_player_keys(key):
	keys_collected = key
	emit_signal("keys_changed")


# reset all player attributes
func reset_player():
	player_dead = false
	player_HP_max = player_HP_default
	player_HP_current = player_HP_default
	player_score_current = 0
	keys_collected = 1
	collected_power_ups = []
	player_WS_current = player_WS_default
	player_Gold_current = player_Gold_default
	player_DC_current = player_DC_default
	player_death_protection = false
	player_bonus_dmg_current = 0
	player_weapon_pot_current = 0
	player_armor_current = 0
