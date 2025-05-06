# Animal script
extends Node3D
@export var animal_name: String
@export var scanned_message: String
var scanned = false

func on_scanned():
	if scanned:
		return ""
	scanned = true
	return "%s scanned! %s" % [animal_name, scanned_message]
