@tool
extends EditorPlugin


var dock = preload("res://addons/playtest/play_test_dock.tscn").instantiate()
var icon = load("res://addons/playtest/icon.svg")
var save_path = "res://addons/playtest/play_test.cfg"
var run_button: Button
var open_scene_button: Button
var scene_picker: EditorResourcePicker
var test_scene_path: String


func _enter_tree():
	if FileAccess.file_exists(save_path):
		var save_file = FileAccess.open(save_path, FileAccess.READ)
		test_scene_path = save_file.get_var()
	_setup_run_button()
	_setup_open_scene_button()
	_settup_scene_picker()
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, run_button)
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_UL, dock)
	if !scene_picker.edited_resource:
		open_scene_button.disabled = true
		var parent = dock.get_parent() as TabContainer
		var idx = parent.get_tab_idx_from_control(dock)
		parent.current_tab = idx
	var run_button_parent = run_button.get_parent()
	run_button_parent.move_child(run_button, run_button_parent.get_child_count()-3 )


func _exit_tree():
	remove_control_from_docks(dock)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, run_button)
	dock.queue_free()
	run_button.queue_free()


func _setup_run_button():
	run_button = Button.new()
	run_button.icon = icon
	run_button.tooltip_text = "%s %s" % [tr("Run"), tr("Scene")]
	run_button.connect("pressed", _on_play_pressed)


func _setup_open_scene_button():
	open_scene_button = Button.new()
	open_scene_button.text = tr("Open Scene")
	open_scene_button.pressed.connect(_open_scene)


func _settup_scene_picker():
	scene_picker = EditorResourcePicker.new()
	scene_picker.set_toggle_pressed(true)
	scene_picker.base_type = "PackedScene"
	if test_scene_path and FileAccess.file_exists(test_scene_path):
		scene_picker.edited_resource = load(test_scene_path)
	scene_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scene_picker.resource_changed.connect(_set_scene)
	scene_picker.add_child(open_scene_button)
	dock.get_node("Container/Configuration/Label").text = tr("Scene") + ": "
	dock.get_node("Container/Configuration").add_child(scene_picker)


func _set_scene(scene):
	if !scene:
		test_scene_path = ""
		open_scene_button.disabled = true
	else:
		open_scene_button.disabled = false
		test_scene_path = scene.resource_path
	var save_file = FileAccess.open(save_path, FileAccess.WRITE)
	save_file.store_var(test_scene_path)
	save_file.close()


func _open_scene():
	if test_scene_path:
		EditorInterface.open_scene_from_path(test_scene_path)
		EditorInterface.set_main_screen_editor("2D")


func _on_play_pressed():
	if test_scene_path:
			EditorInterface.play_custom_scene(test_scene_path)
