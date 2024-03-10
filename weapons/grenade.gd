extends Node3D

@export var GRENADE_TYPE : Grenades:
	set(value):
		GRENADE_TYPE = value
		if Engine.is_editor_hint():
			load_grenade()

@onready var explosion_shape : CollisionShape3D = $Area3D/CollisionShape3D
@onready var area3d : Area3D = $Area3D
@onready var mesh_instance_3d = $MeshInstance3D
var damage : float
var fuse_max : float 
var fuse_current : float
var explosion_radius : float

func load_grenade():
	damage = GRENADE_TYPE.damage
	fuse_max = GRENADE_TYPE.fuse_max
	explosion_radius = GRENADE_TYPE.explosion_radius
	fuse_current = fuse_max
	


func _ready():
	load_grenade()

func _process(delta):
	fuse_current = fuse_current - delta
	print("fuse_current : " + str(fuse_current))
	if fuse_current <= 0:
		mesh_instance_3d.visible = true
		fuse_current = fuse_max
		var sphere : Shape3D = SphereShape3D.new()
		sphere.radius = explosion_radius 
		var mesh : Mesh = SphereMesh.new()
		mesh.radius = explosion_radius
		mesh.height = explosion_radius*2
		mesh_instance_3d.mesh = mesh
		explosion_shape.shape = sphere
		area3d.monitorable = true
		area3d.monitoring = true
		explosion_shape.disabled = false


func _physics_process(delta):	
	if fuse_current <= 0:
		for c in area3d.get_overlapping_bodies().size():
			if area3d.get_overlapping_bodies()[c].get_parent().has_method("take_damage"):
					print("area3d overlap : " + str(area3d.get_overlapping_bodies()))
					area3d.get_overlapping_bodies()[c].get_parent().take_damage(damage)
					area3d.queue_free()
