# CardDisplay.gd
extends Control

@onready var name_label: Label = $NameLabel
@onready var mana_cost_label: Label = $ManaCostLabel
@onready var type_label: Label = $TypeLabel
@onready var power_toughness_label: Label = $PowerToughnessLabel

var card: Card

func setup(card_data: Card):
	card = card_data
	name_label.text = card.card_name
	mana_cost_label.text = card.mana_cost
	type_label.text = card.card_type
	
	if card.power > 0 or card.toughness > 0:
		power_toughness_label.text = str(card.power) + "/" + str(card.toughness)
	else:
		power_toughness_label.text = ""

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			# Handle card click
			card_clicked.emit(card)
