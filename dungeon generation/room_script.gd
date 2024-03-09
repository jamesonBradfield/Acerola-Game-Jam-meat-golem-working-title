@tool
extends Node

@export var room_purpose : String
@export var tiles : Array[Node]
@export var bounds_cast : RayCast3D
@export var room_trigger : CollisionShape3D 
@export var width : float
@export var length : float
# @export var get_room_center : bool : set = get_room_center_func

func clear_room_purpose():
	room_purpose = ""	

func set_bounds_cast(max_half_width : int):
	var room_center = self.position
	bounds_cast.position = Vector3(0,.75,0)
	room_trigger.position = Vector3.ZERO
	bounds_cast.target_position = Vector3(0,0,30)
	var half_width = round(room_center.distance_to(bounds_cast.get_collision_point()))
	var box : BoxShape3D = BoxShape3D.new()
	box.size = Vector3(half_width,1,1)
	room_trigger.shape = box

# we need a signal for setting this stuff as child of area
func create_trigger():
	var raycast = RayCast3D.new()
	var col = CollisionShape3D.new()	
	add_child(col)
	col.set_owner(owner)
	add_child(raycast)
	raycast.set_owner(owner)
	raycast.name = "bounds_cast"
	col.name = "room_trigger"
	room_trigger = col
	bounds_cast = raycast


func set_children_as_tiles():
	for c in get_children().size():
		if get_child(c).name != "bounds_cast" || get_child(c).name != "room_trigger":
			tiles.append(get_child(c))

func grab_room_data_and_setup_for_room_bounds():
	clear_room_purpose()
	set_children_as_tiles()
	create_trigger()
# func set_width_and_height():


func _ready():
	var parent = get_parent()
	print("parent is : " + str(parent.name))
	parent.connect("ready_room_for_bounds",grab_room_data_and_setup_for_room_bounds)
	parent.connect("get_room_width_and_height",set_bounds_cast)

func find_room_nodes_center():
	var sum : Vector3 = Vector3.ZERO
	for c in tiles:
		sum += c.global_position
	return sum/tiles.size()

# func get_room_center_func(val:bool):
# 	get_room_center = val
# 	print(find_room_nodes_center(get_parent().scaling_value))
