@tool
extends Node3D

@export var start : bool = false : set = set_start
# @export var sort : bool = false : set = sortTiles
@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)
var total_distance_from_start : int = 0
var room_parent_index : int = 0
var hall_parent_index : int = 0
var parent_base : PackedScene = preload("res://dungeon generation/Scenes/parent_base.tscn")
var dun_cell_scene : PackedScene = preload("res://dungeon generation/Scenes/DunCellBasicNoMat.tscn")
var directions : Dictionary = {
	"up" :Vector3i.FORWARD, "down" : Vector3i.BACK,
	"left" : Vector3i.LEFT, "right" : Vector3i.RIGHT
}

func set_start(val:bool)->void:	
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
	print("create_dungeone has started.")
	for c in get_children():
		remove_child(c)
		c.queue_free()
	var t : int = 0
	var parent = add_parent_to_dun_mesh("room_")
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
						parent = add_parent_to_dun_mesh("room_")
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
	print("mesh generation is done.")
	grid_map.visible = false
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
	total_distance_from_start = 0
	return true


func add_parent_to_dun_mesh(parentName):
	var parent = parent_base.instantiate()
	add_child(parent)
	parent.set_owner(owner)
	if parentName == "room_":
		parent.name = parentName + str(room_parent_index)
		DungeonData.room_nodes.append(parent)
		room_parent_index += 1
	elif parentName == "hall_":
		parent.name = parentName + str(hall_parent_index)
		DungeonData.room_nodes.append(parent)
		hall_parent_index += 1
	return parent

func hide_each_room_for_debugging():
	for i in DungeonData.room_nodes:
		i.visible = false
	
	for i in DungeonData.room_nodes:
		await get_tree().create_timer(.25).timeout
		i.visible = true
