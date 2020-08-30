local icon = {
  filename = "__auto-infinite-research__/data/shortcut_icon.png",
  priority = "extra-high-no-scale",
  size = 64,
  flags = {"icon"}
}

data:extend(
  {
    {
      type = "shortcut",
      name = "auto-infinite-research-toggle",
      localised_name = "Toggle Auto Infinite Research",
      order = "z[auto-infinite-research]",
      action = "lua",
      icon = icon,
      toggleable = true
    }
  }
)
