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
  -- Add a blueprint for easier research setup (12-beaconed lab fed by infinity chests).
  local research_setup_blueprint =
    "0eNrtmt2uojAQx9+l13DCVwv6KhtjEEe3WSiGFrOu4d13AOXoHs7a1nBXr5TCb6bjf4ah5Up2ZQunhgtF1lfCi1pIsv5xJZIfRV72x9TlBGRNuIKKeETkVf+rzHek8wgXe/hN1mG38QgIxRWH8fLhx2Ur2moHDZ4wXbiDHG0g6FRLPB2/ooke8UE9ciHrKPigPRityX5IngD2flXv2xL8GMe7zvuCj17ik3fw8Ut89g4+eR2ct6JD9YMfW+DZhJcqL375XEhoFI58MUMfzcyQ0onExYELHPKLnyDVf0jR6PDt9K0Epbg4Ds43UNVn2LY4VqI7sN/e5nXISwkeGQ+Pcr2ZzVtVV3lvx5cFB1GAf8Ipof2ibvsMCYPAIxiP4WTll5AP3k1p4E2osj5yqXhhBYoeQBUvucqbixUofgBhKCte5KUVKHkAnRoURGEdJfqAalU/O7u5sQeOxAvBipJ2mzkpZtqiTl+IeqVNYi9IYaCdH6nLD5cfS+ZHGGprkTktOi0uqsXIoIGy6XDCWFvs8d1O4sTuxL6E2BNzLVKnRafFJbRItXvb5Lku7nkDxTjM5sDsaaHh+5aCPlfze9DPfbheFfXU3Hmq5XymnaErl6EuQxfN0JW5Fl3n4rS4hBajQLvgZt/eLaI5cGgOplrgSH/lNLVZtrZ4rmAuO112LpGdn88Vst1hHg3i+9oKjSrMZhHUfCcg/TcPkzkwM2/VmE6rFqXmy7x6Hmfmq7564JV5rWM6tS4OzDsFV4tcLVqiFsWfN3QoUbQN/pMgoDleUO4omwPam5HlvTQ9p71Hdu3hAM1W8j8wOHT/zFk2WUq0ueXHsXZLEVttVSfaW+F2fGq+R5u5MuHKxBJlgpnvQTktOi0uosXUfG/eadFpcREtZtrvq9n1ACv9JknDwGYc7mnTq4geOaO8x4eVLEzSZJWyNAwYZV33F2+6Zlg="
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
