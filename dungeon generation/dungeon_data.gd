@tool
extends Node

var room_tiles : Array[PackedVector3Array]
var room_nodes : Array[Node3D] = []
var used_rooms : Array[bool]
var player_scene : PackedScene = preload("res://addons/fpc/character.tscn")
@onready var GunGen : Node3D = get_node("/root/GunGen")


func find_room_nodes_center(index,dun_mesh_scale):
	var sum : Vector3
	for c in index.get_children():
		sum += c.global_position
	return sum/index.get_children().size()

func set_used_rooms_to_false():
	for index in room_nodes.size():
		print("r is : " + str(index))
		used_rooms.append(false)


func get_random_unused_room():
	var random_int = randi_range(0,room_nodes.size()-1)
	for index in room_nodes.size()-1:
		if used_rooms[index] == false && index == random_int:
			used_rooms[index] = true
			print("WE CHOSE A ROOM!")
			return index
	return 0

func spawn_player_in_random_room(dun_mesh_scale_t : float):
	if get_tree().get_root().get_node("/root/GunGen/Character"):
		get_tree().get_root().get_node("/root/GunGen/Character").free()
	var player = player_scene.instantiate()
	var new_player_position = room_nodes[get_random_unused_room()].position
	new_player_position = Vector3(new_player_position.x*dun_mesh_scale_t,new_player_position.y+1,new_player_position.z*dun_mesh_scale_t)
	player.position = new_player_position 
	print("player is being spawned at : " + str(new_player_position))
	GunGen.add_child(player)
	player.set_owner(owner)


