rule = {
    matches = {
      {
        { "node.name", "equals", "alsa_output.pci-0000_00_1f.3.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Headset",
      ["node.name"] = "Headset",
    },
  }

  table.insert(alsa_monitor.rules,rule)
