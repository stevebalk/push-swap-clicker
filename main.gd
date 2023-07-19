extends Control

var stack_size := 10

var start_stack: Array[int]

var stack_a: Array[int]
var stack_b: Array[int]

var undo_stack: Array[String]
var redo_stack: Array[String]

@onready var backgroundA :=			$BackgroundA
@onready var backgroundB :=			$BackgroundB
@onready var redo_button :=			$DoButtons/Redo
@onready var undo_button :=			$DoButtons/Undo
@onready var stacksize_text_edit :=	$Stacksize/HBoxContainer/LineEdit
@onready var command_screen :=		$CommandScreen

var backgroundA_rect : Rect2
var backgroundB_rect : Rect2
var linesize: Vector2

signal stack_changed

# Inverted commands for undo function
var invert_commands := {
	"pa": "pb",
	"pb": "pa",
	"ra": "rra",
	"rb": "rrb",
	"rr": "rrr",
	"rra": "ra",
	"rrb": "rb",
	"rrr": "rr",
	"sa": "sa",
	"sb": "sb",
	"ss": "ss"
	}

func _ready() -> void:
	linesize = backgroundA.size
	backgroundA_rect = backgroundA.get_rect()
	backgroundB_rect = backgroundB.get_rect()
	_initialize_stack()
	self.stack_changed.connect(_clear_redo_stack)
	stacksize_text_edit.text = str(stack_size)

func _draw() -> void:
	_draw_stack(stack_a, backgroundA_rect, linesize)
	_draw_stack(stack_b, backgroundB_rect, linesize)


func _draw_stack(stack: Array[int], rect: Rect2, line_size: Vector2):
	rect.size.y = line_size.y
	for value in stack:
		var rel_value = float(value) / float(stack_size)
		rect.size.x = rel_value * line_size.x
		draw_rect(rect, Color.from_hsv(rel_value, 1.0, 1.0))
		rect.position.y += line_size.y
	queue_redraw()

func _clear_stacks() -> void:
	stack_a.clear()
	stack_b.clear()
	_clear_undo_stack()
	_clear_redo_stack()

func _randomize_stack() -> void:
	_clear_stacks()
	_initialize_stack()
	stack_a.shuffle()
	start_stack = stack_a.duplicate()
	queue_redraw()

func _add(command: String) -> void:
	_add_undo(command)
	command_screen.insert_text_at_caret(command + "\n", -1)

func _add_undo(command: String) -> void:
	undo_stack.append(command)
	undo_button.disabled = false

func _clear_undo_stack() -> void:
	undo_stack.clear()
	undo_button.disabled = true

func _add_redo(command: String) -> void:
	redo_stack.append(command)
	redo_button.disabled = false

func _clear_redo_stack() -> void:
	redo_button.disabled = true
	redo_stack.clear()

func _initialize_stack() -> void:
	stack_a.assign(range(1, stack_size + 1))
	linesize.y = backgroundA.get_rect().size.y / stack_size
	command_screen.clear()
	start_stack = stack_a.duplicate()

func _restart() -> void:
	_clear_stacks()
	stack_a = start_stack.duplicate()
	command_screen.clear()
	queue_redraw()

func _pop_last_text(string_size: int) -> void:
	command_screen.text = command_screen.text.left(command_screen.text.length() - string_size)
	command_screen.set_caret_line(command_screen.get_last_unhidden_line())

# Push swap functions

func _push(src: Array[int],  dst: Array[int]) -> void:
	dst.insert(0, src.pop_front())
	queue_redraw()

func _pa() -> void:
	_push(stack_a, stack_b)

func _pb() -> void:
	_push(stack_b, stack_a)

func _rotate(stack: Array[int]) -> void:
	stack.append(stack.pop_front())
	queue_redraw()

func _ra() -> void:
	_rotate(stack_a)

func _rb() -> void:
	_rotate(stack_b)

func _rr() -> void:
	_rotate(stack_a)
	_rotate(stack_b)

func _swap(stack: Array[int]) -> void:
	var temp := 0
	temp = stack[1]
	stack[1] = stack[0]
	stack[0] = temp
	queue_redraw()

func _sa() -> void:
	_swap(stack_a)

func _sb() -> void:
	_swap(stack_b)

func _ss():
	_swap(stack_a)
	_swap(stack_b)

func _reverse_rotate(stack: Array[int]) -> void:
	stack.insert(0, stack.pop_back())
	queue_redraw()

func _rra() -> void:
	_reverse_rotate(stack_a)

func _rrb() -> void:
	_reverse_rotate(stack_b)

func _rrr() -> void:
	_reverse_rotate(stack_a)
	_reverse_rotate(stack_b)

# Button functions

# Misc buttons

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_undo_pressed() -> void:
	if not undo_stack.is_empty():
		_pop_last_text(undo_stack[-1].length() + 1)
		var expression = Expression.new()
		expression.parse("_" + invert_commands.get(undo_stack[-1]) + "()")
		_add_redo(undo_stack[-1])
		undo_stack.pop_back()
		expression.execute([], self)
		redo_button.disabled = false
		if undo_stack.is_empty():
			undo_button.disabled = true

func _on_redo_pressed() -> void:
	if not redo_stack.is_empty():
		var expression = Expression.new()
		expression.parse("_" + redo_stack[-1] + "()")
		_add(redo_stack[-1])
		redo_stack.pop_back()
		expression.execute([], self)
		if redo_stack.is_empty():
			redo_button.disabled = true

func _on_randomize_button_pressed() -> void:
	_randomize_stack()

# Push swap buttons
func _on_pa_pressed() -> void:
	if not stack_a.is_empty():
		_pa()
		_add("pa")
		stack_changed.emit()


func _on_pb_pressed() -> void:
	if not stack_b.is_empty():
		_pb()
		_add("pb")
		stack_changed.emit()


func _on_ra_pressed() -> void:
	if stack_a.size() > 1:
		_ra()
		_add("ra")
		stack_changed.emit()


func _on_rb_pressed() -> void:
	if stack_b.size() > 1:
		_rb()
		_add("rb")
		stack_changed.emit()


func _on_rr_pressed() -> void:
	if stack_a.size() > 1 and stack_b.size() > 1:
		_rr()
		_add("rr")
		stack_changed.emit()

func _on_sa_pressed() -> void:
	if stack_a.size() > 1:
		_sa()
		_add("sa")
		stack_changed.emit()


func _on_sb_pressed() -> void:
	if stack_b.size() > 1:
		_sb()
		_add("sb")
		stack_changed.emit()


func _on_ss_pressed() -> void:
	if stack_a.size() > 1 and stack_b.size() > 1:
		_ss()
		_add("ss")
		stack_changed.emit()


func _on_rra_pressed() -> void:
	if stack_a.size() > 1:
		_rra()
		_add("rra")
		stack_changed.emit()


func _on_rrb_pressed() -> void:
	if stack_b.size() > 1:
		_rrb()
		_add("rrb")
		stack_changed.emit()


func _on_rrr_pressed() -> void:
	if stack_a.size() > 1 and stack_b.size() > 1:
		_rrr()
		_add("rrr")
		stack_changed.emit()


func _on_line_edit_text_submitted(new_text: String) -> void:
	stack_size = int(new_text)
	_clear_stacks()
	_initialize_stack()
	queue_redraw()
	

func _on_restart_button_pressed() -> void:
	_restart()
