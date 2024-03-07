@tool
extends Node

@export var room_purpose : String
@export var tiles : Array[Node]
@export var bounds_cast : RayCast3D
@export var width : float
@export var length : float

func clear_room_purpose():
	room_purpose = ""	

func set_bounds_cast():
	var room_center = self.position
	bounds_cast.position = Vector3(0,.75,0)
	bounds_cast.target_position = Vector3(0,0,10)
	var half_width = round(room_center.distance_to(bounds_cast.get_collision_point()))
	print("half_width : " + str(half_width))


func create_trigger():
	var raycast = RayCast3D.new()
	var col = CollisionShape3D.new()	
	add_child(col)
	col.set_owner(owner)
	add_child(raycast)
	raycast.set_owner(owner)
	raycast.name = "bounds_cast"
	# raycast.position = Vector3.ZERO
	var box : Shape3D = BoxShape3D.new()
	col.shape = box
	col.name = "room_trigger"
	# col.position = Vector3.ZERO
	bounds_cast = raycast

func set_children_as_tiles():
	tiles = get_children()

func grab_room_data_and_setup_for_room_bounds():
	clear_room_purpose()
	set_children_as_tiles()
	create_trigger()
	set_bounds_cast()

# func set_width_and_height():


func _ready():
	var parent = get_parent()
	parent.connect("ready_room_for_bounds",grab_room_data_and_setup_for_room_bounds)
