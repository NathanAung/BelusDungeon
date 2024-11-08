extends Node2D

# NODE PATHS
export(NodePath) var player_node_path = "/root/Main/Dungeon/YSort/Player"
export(NodePath) var dungeon_node_path = "/root/Main/Dungeon"

var fullscreen:bool = true
# 0:NORMAL, 1:EASY
var game_difficulty:int = 0
