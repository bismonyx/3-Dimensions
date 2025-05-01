extends MeshInstance3D


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		body.take_dmg(1)
		print("attack")
