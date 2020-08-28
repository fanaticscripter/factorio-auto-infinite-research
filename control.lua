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
    warn("queued up next level(s) of mining productivity research", force)
  end
end

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

commands.add_command(
  "air",
  "Try to queue up next level(s) of infinite mining productivity research.",
  function(event)
    try_to_queue_up_infinite_tech(game.player.force)
  end
)

-- Enable debugging with Factorio Mod Debug.
-- https://marketplace.visualstudio.com/items?itemName=justarandomgeek.factoriomod-debug
if __DebugAdapter then
  require "debug"
end
