extends HBoxContainer

@onready var shells_amount_label: Label = %ShellsAmountLabel

var amount: int: set = set_amount

func _ready() -> void:
	Globals.shells_changed.connect(_on_shells_changed)

func set_amount(v: int):
	amount = v
	shells_amount_label.text = str(v)

func _on_shells_changed():
	create_tween().tween_property(self, "amount", Globals.shells, 0.5)
