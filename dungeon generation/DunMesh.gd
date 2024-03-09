@tool
extends Node3D
signal ready_room_for_bounds
signal get_room_width_and_height
var room_script = load("res://dungeon generation/room_script.gd")
@export var start : bool = false : set = set_start
# @export var sort : bool = false : set = sortTiles
@export var grid_map_path : NodePath
@export var debug_rooms : bool
@onready var grid_map : GridMap = get_node(grid_map_path)
var max_width_value : int
var total_distance_from_start : int = 0
@export var scaling_value : float  = 1
var room_parent_index : int = 0
var parent_base : PackedScene = preload("res://dungeon generation/Scenes/parent_base.tscn")
var dun_cell_scene : PackedScene = preload("res://dungeon generation/Scenes/DunCellBasicNoMat.tscn")
var directions : Dictionary = {
	"up" :Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left" : Vector3i.LEFT, "right" : Vector3i.RIGHT
}

func _ready():
	get_parent().connect("scale_mesh",set_scaling_value)
	get_parent().connect("get_max_room_size",set_max_width_value)

func set_start(_val:bool)->void:	
	if Engine.is_editor_hint():
		create_dungeon()
	elif not Engine.is_editor_hint():
		create_dungeon()


func handle_none(cell:Node3D,dir:String):
	cell.call("remove_door_"+dir)
func handle_00(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)
func handle_01(cell:Node3D,dir:String):
	cell.call("remove_door_"+dir)
func handle_02(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)
func handle_10(cell:Node3D,dir:String):
	cell.call("remove_door_"+dir)
func handle_11(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)
func handle_12(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)
func handle_20(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)
func handle_21(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
func handle_22(cell:Node3D,dir:String):
	cell.call("remove_wall_"+dir)
	cell.call("remove_door_"+dir)

func create_dungeon():
	print("create_dungeon has started.")
	set_self_scale(1)
	room_parent_index = 0
	dungeon_data.room_nodes.clear()
	for c in get_children():
		remove_child(c)
		c.queue_free()
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
				if cell_n_index ==-1\
				|| cell_n_index == 3:
					handle_none(dun_cell,directions.keys()[i])
				else:
					var key : String = str(cell_index) + str(cell_n_index)
					call("handle_"+key,dun_cell,directions.keys()[i])
		if t%20 == 9 : await get_tree().create_timer(0).timeout
	print("mesh generation is done. Moving on to room cleanup")
	grid_map.visible = false
	remove_weird_rooms()
	ready_room_for_bounds.emit()
	# set_self_scale(scaling_value)
	offset_room_children_by_new_parent_position()
	emit_signal("get_room_width_and_height",max_width_value)
	dungeon_data.set_used_rooms_to_false()
	# dungeon_data.spawn_player_in_random_room(scaling_value)
	if debug_rooms:
		hide_each_room_for_debugging()



func _on_gun_gen_hallways_done():
	set_start(true)


func add_cells_to_new_room_node(dun_cell_position,last_dun_cell_position):
	if dun_cell_position.distance_to(last_dun_cell_position) == 1:	
		total_distance_from_start += dun_cell_position.distance_to(last_dun_cell_position)
		return false
	if floor(dun_cell_position.distance_to(last_dun_cell_position)) == total_distance_from_start:
		total_distance_from_start = 0
		return false
	print(floor(dun_cell_position.distance_to(last_dun_cell_position)))
	total_distance_from_start = 0
	return true


func add_area_to_dun_mesh():
	var area = parent_base.instantiate()
	add_child(area)
	area.set_owner(owner)
	area.name = "room_" + str(room_parent_index)
	dungeon_data.room_nodes.append(area)
	room_parent_index += 1
	return area


func hide_each_room_for_debugging():
	for i in dungeon_data.room_nodes:
		i.visible = false	
	for i in dungeon_data.room_nodes:
		await get_tree().create_timer(1).timeout
		i.visible = true


func offset_room_children_by_new_parent_position():
	for i in dungeon_data.room_nodes.size():
		var new_parent_position = dungeon_data.room_nodes[i].find_room_nodes_center()
		print("room " + str(i) + " center is : " + str(new_parent_position))
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

func set_self_scale(arg):
	self.scale.x = arg
	self.scale.y = arg
	self.scale.z = arg

func set_scaling_value(arg):
	scaling_value = arg

func set_max_width_value(arg):
	print("max_width_value has been changed to : " + str(arg))
	max_width_value = arg
