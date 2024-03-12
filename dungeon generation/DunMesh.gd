@tool
extends Node3D
signal ready_room_for_bounds
signal post_process_rooms
var room_script = load("res://dungeon generation/room_script.gd")
@export var start : bool = false : set = set_start
# @export var sort : bool = false : set = sortTiles
@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)
@export var nav_region_path : NodePath
@onready var navigation_region : NavigationRegion3D = get_node(nav_region_path)
var total_distance_from_start : int = 0
var room_parent_index : int = 0
var parent_base : PackedScene = preload("res://dungeon generation/Scenes/parent_base.tscn")
var dun_cell_scene : PackedScene = preload("res://dungeon generation/Scenes/DunCellBasicNoMat.tscn")
@export var room_array : Array[Room]
var directions : Dictionary = {
	"up" :Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left" : Vector3i.LEFT, "right" : Vector3i.RIGHT
}

func _ready():
	# connect signals to our various generation scripts
	get_parent().connect("hallwaysDone",create_dungeon)
# start function called by changing the start bool
func set_start(_val:bool)->void:	
	if Engine.is_editor_hint():
		create_dungeon()
	elif not Engine.is_editor_hint():
		create_dungeon()
func handle_all(cell:Node3D,dir:String,key:String) :
	match key :
		""   : cell.call("remove_door_"+dir) # for handle_none
		"00" : cell.call("remove_wall_"+dir) ; cell.call("remove_door_"+dir)
		"01" : cell.call("remove_door_"+dir)
		"02" : cell.call("remove_wall_"+dir) ;	cell.call("remove_door_"+dir)
		"10" : cell.call("remove_door_"+dir)
		"11" : cell.call("remove_wall_"+dir) ; cell.call("remove_door_"+dir)
		"12" : cell.call("remove_wall_"+dir) ; cell.call("remove_door_"+dir)
		"20" : cell.call("remove_wall_"+dir) ; cell.call("remove_door_"+dir)
		"21" : cell.call("remove_wall_"+dir)
		"22" : cell.call("remove_wall_"+dir) ; cell.call("remove_door_"+dir)

func create_dungeon():
	print("create_dungeon has started.")
	# we need to reset the scale (there's a lot of magic numbers)
	set_self_scale(1)
	# naming index for rooms
	room_parent_index = 0
	dungeon_data.room_nodes.clear()
	for c in get_children():
		remove_child(c)
		c.queue_free()
	for n in navigation_region.get_children():
		navigation_region.remove_child(n)
		n.queue_free()
	var t : int = 0
	var parent = add_area_to_dun_mesh()
	var last_dun_cell
	var room_index : int = 0
	var hall_index : int = 0
	var door_index : int = 0
	for cell in grid_map.get_used_cells():
		var cell_index : int = grid_map.get_cell_item(cell)
		# cell id Table of contents
		# ______________________________
		#0.rooms
		#1.hallway corridors.
		#2.doors
		#3.visual-border(red indicator for border size)
		if cell_index <=2\
		&& cell_index >=0:
			var dun_cell : Node3D = dun_cell_scene.instantiate()
			dun_cell.position = Vector3(cell) + Vector3(0.5,0,0.5)
			if cell_index == 1:
				dun_cell.name = "hall_" + str(hall_index)
				hall_index += 1
				add_child(dun_cell)
				dun_cell.set_owner(owner)
			if cell_index == 0 || cell_index == 2:
				if cell_index == 2:
					dun_cell.name = "door_" + str(door_index)
					door_index += 1	
				else:
					dun_cell.name = "room_tile_" + str(room_index)
					room_index += 1
				if last_dun_cell != null:
					var last_dun_cell_position = last_dun_cell.position
					var dun_cell_position = dun_cell.position
					if add_cells_to_new_room_node(dun_cell_position,last_dun_cell_position):
						parent = add_area_to_dun_mesh()
				parent.add_child(dun_cell)
				dun_cell.set_owner(owner)
				last_dun_cell = dun_cell
			t+=1
			for i in 4:
				var cell_n : Vector3i = cell + directions.values()[i]
				var cell_n_index : int = grid_map.get_cell_item(cell_n)
				var key : String = str(cell_index) + str(cell_n_index)
				handle_all(dun_cell,directions.keys()[i],key)
		if t%20 == 9 : await get_tree().create_timer(0).timeout
	print("mesh generation is done. Moving on to room cleanup")
	grid_map.visible = false
	emit_signal("ready_room_for_bounds")
	set_self_scale(dungeon_data.scaling_value)
	emit_signal("post_process_rooms")

func add_area_to_dun_mesh():
	var area = parent_base.instantiate()
	add_child(area)
	area.set_owner(owner)
	area.name = "room_" + str(room_parent_index)
	dungeon_data.room_nodes.append(area)
	room_parent_index += 1
	return area

func add_cells_to_new_room_node(dun_cell_position,last_dun_cell_position):
	if dun_cell_position.distance_to(last_dun_cell_position) == 1:	
		total_distance_from_start += dun_cell_position.distance_to(last_dun_cell_position)
		return false
	if floor(dun_cell_position.distance_to(last_dun_cell_position)) == total_distance_from_start:
		total_distance_from_start = 0
		return false
	total_distance_from_start = 0
	return true

func set_self_scale(arg):
	self.scale.x = arg
	self.scale.y = arg
	self.scale.z = arg
