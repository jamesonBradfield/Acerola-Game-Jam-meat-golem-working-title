@tool
extends Node3D


func remove_wall_up():
	$wall_up.free()
func remove_wall_down():
	$wall_down.free()
func remove_wall_left():
	$wall_left.free()
func remove_wall_right():
	$wall_right.free()
func remove_door_up():
	$door_up.free()
func remove_door_down():
	$door_down.free()
func remove_door_left():
	$door_left.free()
func remove_door_right():
	$door_right.free()

func return_door_areas() -> Array[Area3D]:
	var temp_array : Array[Area3D]
	temp_array.append(get_node_or_null("door_right/Area3D"))
	temp_array.append(get_node_or_null("door_left/Area3D"))
	temp_array.append(get_node_or_null("door_down/Area3D"))
	temp_array.append(get_node_or_null("door_up/Area3D"))
	return temp_array
