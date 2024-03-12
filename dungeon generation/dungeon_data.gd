@tool
extends Node
signal room_grab_room_type
var room_tiles : Array[PackedVector3Array]
var room_nodes : Array[Node3D] = []
var used_rooms : Array[bool]
var scaling_value : float
var debug_rooms : bool
var player_scene : PackedScene = preload("res://addons/fpc/character.tscn")
@onready var GunGen : Node3D = get_node("/root/GunGen")
@onready var dun_mesh = get_node("/root/GunGen/DunMesh")
@onready var navigation_region : NavigationRegion3D = get_node("/root/GunGen/NavigationRegion3D")
var ROOM_TYPE : Array[Room] :
	set(value):
		ROOM_TYPE = value
# TODO: add navigation_region to dungeon_data, and add scaling_value, along with debug_rooms (might need to go through the dun_gen and dun_mesh signals)

func _ready():
	GunGen.connect("scale_mesh",set_scale)
	dun_mesh.connect("post_process_rooms",post_process_rooms)

func set_scale(val: float):
	scaling_value = val

func post_process_rooms():
	remove_weird_rooms()
	for index in room_nodes.size():
		offset_room_children_by_new_parent_position(index)
		set_used_rooms_to_false(index)
		add_children_to_nav_region(index)
	spawn_player_in_random_room()
	if debug_rooms:
		hide_each_room_for_debugging()


func set_used_rooms_to_false(index):
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

# this should be offloaded to spawnpoint code.
func spawn_player_in_random_room():
	if get_tree().get_root().get_node_or_null("/root/GunGen/Character"):
		get_tree().get_root().get_node("/root/GunGen/Character").free()
	var player = player_scene.instantiate()
	var random_room_node = room_nodes[get_random_unused_room()]
	var new_player_position = random_room_node.position
	new_player_position = Vector3(new_player_position.x,new_player_position.y+1,new_player_position.z)
	player.position = new_player_position 
	var spawn_point_mesh
	for c in ROOM_TYPE[2].instantiate_objects.size():
		spawn_point_mesh = ROOM_TYPE[2].instantiate_objects[c].instantiate()
	random_room_node.ROOM_TYPE = ROOM_TYPE[2]
	random_room_node.add_child(spawn_point_mesh)
	spawn_point_mesh.set_owner(owner)
	print("player is being spawned at : " + str(new_player_position))
	GunGen.add_child(player)
	player.set_owner(owner)

func choose_random_ending_room():
	var random_room_node = room_nodes[get_random_unused_room()]		
	var spawn_point_mesh
	for c in ROOM_TYPE[2].instantiate_objects.size():
		spawn_point_mesh = ROOM_TYPE[2].instantiate_objects[c].instantiate()	
	random_room_node.ROOM_TYPE = ROOM_TYPE[2]
	random_room_node.add_child(spawn_point_mesh)
	spawn_point_mesh.set_owner(owner)


func hide_each_room_for_debugging():
	for i in dungeon_data.room_nodes:
		i.visible = false	
	for i in dungeon_data.room_nodes:
		await get_tree().create_timer(1).timeout
		i.visible = true

func offset_room_children_by_new_parent_position(i):
		var current_room = dungeon_data.room_nodes[i]
		var new_parent_position = current_room.find_room_nodes_center()
		for c in dungeon_data.room_nodes[i].get_children():
			c.position = c.position - new_parent_position	
		dungeon_data.room_nodes[i].position = new_parent_position

func remove_weird_rooms():
		if dungeon_data.room_tiles.size() < dungeon_data.room_nodes.size():
			var offending_room = dungeon_data.room_nodes[0]
			var children = offending_room.get_children()
			for c in children:
				c.reparent(dungeon_data.room_nodes[1])
				c.set_owner(owner)
			dungeon_data.room_nodes.remove_at(0)
			offending_room.free()

# add_self_to_nav_region(navigation_region)
# or even better room_nodes.change_parent()
func add_children_to_nav_region(index):
	var current_room = dungeon_data.room_nodes[index]
	current_room.change_parent(navigation_region)
	navigation_region.navigation_mesh = NavigationMesh.new() 
	var on_thread : bool = true
	navigation_region.bake_navigation_mesh(on_thread)

