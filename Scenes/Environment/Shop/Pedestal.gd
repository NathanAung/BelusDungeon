extends Area2D


var Player
export(NodePath) var dungeon_node_path = MiscGlobal.dungeon_node_path
onready var Dungeon = get_node(dungeon_node_path)
# the item this pedestal contains
var shop_item:Object
var shopkeeper:Object
# name/price labels
onready var Labels:Node2D = get_node("Labels")


# Called when the node enters the scene tree for the first time.
func _ready():
	# set labels
	if shop_item:
		Labels.get_node("Name").text = shop_item.item_name
		Labels.get_node("Price").text = "$ " + String(shop_item.price)


func _physics_process(delta):
	if Input.is_action_just_pressed("input_interact") and Player != null:
		if overlaps_body(Player):
			activate()


func activate():
	# let player buy the item if they have enough gold
	if shop_item.price <= PlayerGlobal.player_Gold_current:
		if !AudioGlobal.sfx_settings:
			$AudioStreamPlayer.volume_db = -80
		else:
			$AudioStreamPlayer.volume_db = -5
		$AudioStreamPlayer.play()
		PlayerGlobal.player_Gold_current -= shop_item.price
		shop_item.in_shop = false
		shopkeeper.sell_item()
		Player.interact_indi.playing = false
		Player.interact_indi.hide()


func _on_Pedestal_body_entered(body):
	if body.name == "Player":
		if Player == null:
			Player = body
		Labels.get_node("Name").text = shop_item.item_name
		Labels.get_node("Price").text = "$ " + String(shop_item.price)
		Labels.show()
		shop_item.show_description()
		
		if shop_item.price <= PlayerGlobal.player_Gold_current:
			Player.interact_indi.playing = true
			Player.interact_indi.show()


func _on_Pedestal_body_exited(body):
	if body.name == "Player":
		Labels.hide()
		shop_item.hide_description()
		Player.interact_indi.playing = false
		Player.interact_indi.hide()


func _on_AudioStreamPlayer_finished():
	queue_free()
