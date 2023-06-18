rule = {
  matches = {
    {
      { "node.name", "equals", "alsa_output.pci-0000_01_00.1.hdmi-stereo-extra2" },
    },
  },
  apply_properties = {
    ["node.description"] = "Speaker",
    ["node.name"] = "Speaker",
  },
}

table.insert(alsa_monitor.rules,rule)
