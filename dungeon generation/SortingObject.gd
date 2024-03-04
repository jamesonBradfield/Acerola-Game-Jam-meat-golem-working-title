extends Node
@export var index : int = 0
@export var object_array : Array[Node3D]
@export var object_center : Vector3

func find_center_of_object_array():
	var sum : Vector3 = Vector3.ZERO
	for i in object_array:
		sum += i.position
	object_center = sum/object_array.size()

func increment_index(inc):
	index += inc

func reset_index():
	index = 0


