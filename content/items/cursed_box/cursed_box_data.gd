extends ItemData

func _get_tracking_text(player_index: int) -> String:
    var text : String = ""
    if player_index == RunData.DUMMY_PLAYER_INDEX or \
    !RunData.tracked_item_effects[player_index].has(my_id) or \
    tracking_text == "[EMPTY]": return text
    
    if not RunData.tracked_item_effects[player_index][my_id] is Array: return text
    
    for i in RunData.tracked_item_effects[player_index][my_id].size():
        var tracked_count = RunData.tracked_item_effects[player_index][my_id][i]

        var tracking_text_to_use = tracking_text

        if i == 1:
            tracking_text_to_use = "stats_lost"

        text += "\n[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(tracking_text_to_use.to_upper(), [Text.get_formatted_number(tracked_count)]) + "[/color]"
    
    return text
