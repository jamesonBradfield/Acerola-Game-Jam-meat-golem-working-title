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

func _ready():
	GunGen.connect("scale_mesh",func(val):
		scaling_value = val
	)
	dun_mesh.connect("post_process_rooms",post_process_rooms)

func post_process_rooms():
	remove_weird_rooms()
	for index in room_nodes.size():	
		var current_room = room_nodes[index]
		offset_room_children_by_new_parent_position(current_room)
		used_rooms.append(false)
		add_children_to_nav_region(current_room)
	spawn_player_in_random_room()
	if debug_rooms:
		hide_each_room_for_debugging()

# TODO: we need to rewrite the room choosing algorithm to use our resource, and store our width and height in our room_script.
func get_random_unused_room():
	var random_int = randi_range(0,room_nodes.size()-1)
	for index in room_nodes.size()-1:
		if used_rooms[index] == false && index == random_int:
			used_rooms[index] = true
			return index
	return 0

# this should be offloaded to spawnpoint code.
func spawn_player_in_random_room():
	if get_tree().get_root().get_node_or_null("/root/GunGen/Character"):
		get_tree().get_root().get_node("/root/GunGen/Character").free()
	var player = player_scene.instantiate()
	# TODO:room_node position is something insane. we need to investigate this later
	var random_room_node = room_nodes[get_random_unused_room()]
	player.position = Vector3(random_room_node.position.x,random_room_node.position.y+1, random_room_node.position.z)/scaling_value
	print("player is being spawned at " + str(player.position))
	var spawn_point_mesh
	for c in ROOM_TYPE[2].instantiate_objects.size():
		spawn_point_mesh = ROOM_TYPE[2].instantiate_objects[c].instantiate()
	random_room_node.ROOM_TYPE = ROOM_TYPE[2]
	random_room_node.add_child(spawn_point_mesh)
	spawn_point_mesh.set_owner(owner)
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

func offset_room_children_by_new_parent_position(current_room):
		var new_parent_position = current_room.find_room_nodes_center()
		for c in current_room.get_children():
			c.position = c.position - new_parent_position	
		current_room.position = new_parent_position

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
func add_children_to_nav_region(current_room):
	current_room.change_parent(navigation_region)
	navigation_region.navigation_mesh = NavigationMesh.new() 
	var on_thread : bool = true
	navigation_region.bake_navigation_mesh(on_thread)

