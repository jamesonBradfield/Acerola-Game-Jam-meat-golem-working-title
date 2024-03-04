@tool
extends Node3D

@export var start : bool = false : set = set_start
# @export var sort : bool = false : set = sortTiles
@export var grid_map_path : NodePath
@onready var grid_map : GridMap = get_node(grid_map_path)
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
	var parent = parent_base.instantiate()
	add_child(parent)
	parent.set_owner(owner)
	var last_dun_cell
	var total_distance_from_start : int = 0
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
			# print("last_dun_cell : " + str(last_dun_cell.position))
			if last_dun_cell != null:
				if cell_index != 1:
					print("distance between cells : "+ str(floor(dun_cell.position.distance_to(last_dun_cell.position))))
					if dun_cell.position.distance_to(last_dun_cell.position) == 1:	
						total_distance_from_start += dun_cell.position.distance_to(last_dun_cell.position)
					if dun_cell.position.distance_to(last_dun_cell.position) > 1:
						print("total distance from start : " + str(total_distance_from_start))
						if floor(dun_cell.position.distance_to(last_dun_cell.position)) == total_distance_from_start:
							parent.add_child(dun_cell)
							dun_cell.set_owner(owner)
							total_distance_from_start = 0
						elif floor(dun_cell.position.distance_to(last_dun_cell.position)) < total_distance_from_start \
							|| floor(dun_cell.position.distance_to(last_dun_cell.position)) > total_distance_from_start:
						# print("new room is being made")
							parent = parent_base.instantiate()
							add_child(parent)
							parent.set_owner(owner)
							total_distance_from_start = 0
						# print("cell_index : " + str(cell_index))
					parent.add_child(dun_cell)
					dun_cell.set_owner(owner)
				else:
					add_child(dun_cell)
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



func _on_gun_gen_hallways_done():
	set_start(true)
