@tool
extends EditorPlugin

var plugin: EditorInspectorPlugin


func _enter_tree():
	plugin = preload("res://addons/bit_flags/inspector_plugin.gd").new()
	add_inspector_plugin(plugin)


func _exit_tree():
	remove_inspector_plugin(plugin)
