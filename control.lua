local TOGGLE_NAME = "auto-infinite-research-toggle"

function warn(message, force)
  message = "[AIR] " .. message
  if force then
    force.print(message, {r = 1, g = 0.6})
  else
    game.print(message, {r = 1, g = 0.6})
  end
end

function get_infinite_mining_productivity_tech(force)
  for _, tech in pairs(force.technologies) do
    if tech.research_unit_count_formula ~= nil then
      local _, _, level = string.find(tech.name, "^mining%-productivity%-(%d+)")
      if level ~= nil then
        return tech, tonumber(level)
      end
    end
  end
  return nil, nil
end

function try_to_queue_up_infinite_tech(force)
  -- Do nothing if AIR has been toggled off.
  for _, player in ipairs(force.players) do
    if not player.is_shortcut_toggled(TOGGLE_NAME) then
      return
    end
    break
  end
  -- Do nothing if player hasn't launched any rockets yet.
  if force.rockets_launched == 0 then
    return
  end
  local infinite_tech, level = get_infinite_mining_productivity_tech(force)
  if infinite_tech == nil then
    warn("cannot find infinite mining productivity tech", force)
    return
  end
  local finite_tech = force.technologies["mining-productivity-" .. (level - 1)]
  -- Do nothing if corresponding highest level finite tech hasn't been researched yet.
  if finite_tech ~= nil and not finite_tech.researched then
    return
  end
  force.research_queue_enabled = true
  -- Add infinite tech until the queue is full.
  local techs_queued = 0
  while force.add_research(infinite_tech) do
    techs_queued = techs_queued + 1
  end
  if techs_queued > 0 then
    warn(
      "queued up next level(s) of mining productivity research " ..
        "(you can turn off AIR from the shortcut bar, or with console command /air.off)",
      force
    )
  end
end

function toggle_on_off(force, on)
  -- State has to be toggled for all players in the force.
  for _, player in ipairs(force.players) do
    player.set_shortcut_toggled(TOGGLE_NAME, on)
  end
end

script.on_event(
  defines.events.on_player_created,
  function(event)
    -- Turn on AIR if player is first in their force, otherwise set AIR state
    -- to that of existing players in the force.
    local player = game.get_player(event.player_index)
    local on = true
    for _, force_player in ipairs(player.force.players) do
      if force_player.index ~= player.index then
        on = force_player.is_shortcut_toggled(TOGGLE_NAME)
        break
      end
    end
    player.set_shortcut_toggled(TOGGLE_NAME, on)
  end
)
script.on_event(
  defines.events.on_research_started,
  function(event)
    try_to_queue_up_infinite_tech(event.research.force)
  end
)
script.on_event(
  defines.events.on_research_finished,
  function(event)
    try_to_queue_up_infinite_tech(event.research.force)
  end
)
script.on_event(
  defines.events.on_lua_shortcut,
  function(event)
    if event.prototype_name ~= TOGGLE_NAME then
      return
    end
    local player = game.get_player(event.player_index)
    local on = player.is_shortcut_toggled(TOGGLE_NAME)
    toggle_on_off(player.force, not on)
    if not on then
      -- Just toggled on.
      try_to_queue_up_infinite_tech(player.force)
    end
  end
)

commands.add_command(
  "air",
  "Turn on AIR and try to queue up next level(s) of infinite mining productivity research.",
  function(event)
    toggle_on_off(game.player.force, true)
    try_to_queue_up_infinite_tech(game.player.force)
  end
)
commands.add_command(
  "air.off",
  "Turn off AIR.",
  function(event)
    toggle_on_off(game.player.force, false)
  end
)

-- Enable debugging with Factorio Mod Debug.
-- https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug
if __DebugAdapter then
  require "debug"
end
