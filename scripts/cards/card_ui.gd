extends Control

@onready var name_label = $NameLabel
@onready var mana_cost_label = $ManaCostLabel
@onready var type_label = $TypeLabel
@onready var pt_label = $PTLabel

func update_display(card: Card):
	name_label.text = card.card_name
	mana_cost_label.text = card.mana_cost
	type_label.text = card.card_type
	
	if card.card_data.has("power") and card.card_data.has("toughness"):
		pt_label.text = str(card.card_data.power) + "/" + str(card.card_data.toughness)
	else:
		pt_label.text = ""
