@tool
extends Node
#TODO: create resource that will hold specific room data, like an array of objects to instantiate(with position,rotation ,etc)(this will have to be either centered or computed as a ratio of room size) this resource will also hold a name, and a reference to the enemy_spawn_director
@export var room_purpose : String
@export var tiles : Array[Node]
@export var bounds_cast : RayCast3D
@export var room_trigger : CollisionShape3D 
@export var width : float
@export var length : float

func clear_room_purpose():
	room_purpose = ""	


func set_children_as_tiles():
	for c in get_children().size():
		if get_child(c).name != "bounds_cast" || get_child(c).name != "room_trigger":
			tiles.append(get_child(c))

func room_ready():
	clear_room_purpose()
	set_children_as_tiles()


func _ready():
	var parent = get_parent()
	print("parent is : " + str(parent.name))
	parent.connect("ready_room_for_bounds",room_ready)

func find_room_nodes_center():
	var sum : Vector3 = Vector3.ZERO
	for c in tiles:
		sum += c.global_position
	return sum/tiles.size()

