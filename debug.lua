function turn_on_debug_mode(player)
  player.cheat_mode = true
  player.force.research_all_technologies()
  player.force.laboratory_speed_modifier = 60000
  if player.force.rockets_launched == 0 then
    player.force.rockets_launched = 1
  end
  local inventory = player.get_inventory(defines.inventory.character_main)
  -- Add some useful cheat items and try to enable their recipes.
  for _, item in ipairs({"infinity-chest", "electric-energy-interface"}) do
    if player.force.recipes[item] ~= nil then
      player.force.recipes[item].enabled = true
    end
    if inventory.get_item_count(item) == 0 then
      player.insert(item)
    end
  end
  -- Add a blueprint for easier research setup.
  local research_setup_blueprint =
    "0eNrtmt+OojAUxt+l1zCh5Z/6KhtjEI9us1AILZN1De++B1AWM8zadoa7eiW2/A5tvu942nIjx6KFuuFCkd2N8LwSkux+3IjkF5EV/W/qWgPZEa6gJB4RWdlfFdmRdB7h4gS/yY52e4+AUFxxGG8fLq4H0ZZHaLDDdOMRMoyBoLqS2B2/YghE+OFb7JErdk3e4p6M4WTfJmuAk19Wp7YAPyQ71nXeBz57zQ++wg9f8r/0+NFLfPIVfGww+1sLfjLxpcryXz4XEhqFLR/i0HmYBVKqTQpekDYTiYszF9jk5z9Bqv8802Yc+r37QYJSXFyGaWigrN7h0GJbgY8Dp8N9hs5ZIcEj48+j9O9hs1ZVZdbH8WXOQeTg1zgkjJ9Xbe82GgQewZkdOiu/gGx4uslS3oQqqguXiudWIDYDlbzgKmuuVqBwBsKpLHmeFVagaAaqG5RWbj1L8QzVqn50dmNLZhyJN4IVJe32S1LcaksxcFJ0UlxTijTQTrDsRYKlVFvWzMnayXpVWTP9AsqmwKGhtm2mOpMFQ6ATbyAf25MlcmRBplrkWNufPn0mO4M6g36zQRMLMQZOjE6Ma4gxfdrG+HRB+MiGZn8VG+2EHn6az9kSeGsODnTALND2ZuSs6ay5pjUZNdeiq1mcFlfRItPfNmWhzab1bFXRHjGpD+SFgmgMES0ybNYPTGf9wGzWD8x50XlxDS8mxgcDd0vOVB4tgVPjswtN8L86EArs2KD2QEBzuWII5J9xhhb+1B5Wf7anR47t+QzNQfI/MEzh47MUeWu8x6c3pDAwr0CZTgUaUu3tG6tEGzLzqsJlMpfJ1shkYWhQVVgdVUf6Z+F2AWLjo1UWOTc5N63hpsT4bNVp0WlxHS2m2i8J2eXdjfGBq9O60/o6Wt/qV+yvtb4fm3vY9DKiR95RfeOSYUOjNNqmSUqDJE667i8KOWQ9"
  local research_setup_blueprint_present = false
  for i = 1, #inventory do
    local stack = inventory[i]
    if stack.valid_for_read and stack.is_blueprint and stack.export_stack() == research_setup_blueprint then
      research_setup_blueprint_present = true
      break
    end
  end
  if not research_setup_blueprint_present then
    local empty_stack = inventory.find_empty_stack()
    if empty_stack ~= nil then
      empty_stack.import_stack(research_setup_blueprint)
    end
  end
end

function reset_mining_productivity_techs_and_rockets(force)
  for _, tech in pairs(game.player.force.technologies) do
    if string.find(tech.name, "^mining%-productivity%-(%d+)") ~= nil then
      tech.researched = false
      force.set_saved_technology_progress(tech, 0)
    end
  end
  force.rockets_launched = 0
end

function reset_all_techs_and_rockets(force)
  -- Keep lab speed modifier.
  local laboratory_speed_modifier = force.laboratory_speed_modifier
  force.reset()
  force.laboratory_speed_modifier = laboratory_speed_modifier
end

function launch_rocket(force)
  force.rockets_launched = force.rockets_launched + 1
end

commands.add_command(
  "air.debug.on",
  "Turn on AIR debug mode (turn on cheat mode, unlock all finite techs, set lab speed modifier, and receive bonus items if not already present).",
  function()
    turn_on_debug_mode(game.player)
  end
)
commands.add_command(
  "air.debug.reset",
  "Reset all minining productivity technologies while keeping everything else.",
  function()
    reset_mining_productivity_techs_and_rockets(game.player.force)
  end
)
commands.add_command(
  "air.debug.reset_all",
  "Reset all rockets, technologies and effects while keeping the lab speed modifier.",
  function()
    reset_all_techs_and_rockets(game.player.force)
  end
)
commands.add_command(
  "air.debug.launch",
  "Launch a rocket.",
  function()
    launch_rocket(game.player.force)
  end
)
