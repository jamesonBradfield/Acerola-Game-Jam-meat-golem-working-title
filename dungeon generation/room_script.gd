@tool
extends Node
#TODO: create resource that will hold specific room data, like an array of objects to instantiate(with position,rotation ,etc)(this will have to be either centered or computed as a ratio of room size) this resource will also hold a name, and a reference to the enemy_spawn_director
@export var room_purpose : String
@export var tiles : Array[Node]
@export var width : float
@export var length : float
@export var ROOM_TYPE : Room :
	set(value):
		ROOM_TYPE = value
		instantiate_room_objects()


func clear_room_purpose():
	room_purpose = ""	

func set_children_as_tiles():
	for c in get_children().size():
		if get_child(c).name != "bounds_cast" || get_child(c).name != "room_trigger":
			tiles.append(get_child(c))

func room_ready():
	clear_room_purpose()
	set_children_as_tiles()
	assign_door()

func grab_room_resource_values():
	room_purpose = ROOM_TYPE.room_purpose
	for c in ROOM_TYPE.instantiate_objects:
		var inst_object = c.instantiate()
		add_child(inst_object)
		inst_object.set_owner(owner)
		
		

func _ready():
	var parent = get_parent()
	parent.connect("ready_room_for_bounds",room_ready)
	dungeon_data.connect("room_grab_room_type",grab_room_resource_values)

func find_room_nodes_center():
	var sum : Vector3 = Vector3.ZERO
	for c in tiles:
		sum += c.global_position
	return sum/tiles.size()

func assign_door():
	for c in tiles.size():
		if "door_".is_subsequence_of(tiles[c].name):
			for sub_doors in tiles[c].return_door_areas():
				if sub_doors:
					sub_doors.connect("body_entered",player_is_entering_room)

func player_is_entering_room(body: Node3D):
	if body == PlayerGlobals.player:
		print("player is in " + str(self.name))
	# ready_room

func instantiate_room_objects():
	pass

func change_parent(new_parent):
	self.reparent(new_parent)
	self.set_owner(owner)
