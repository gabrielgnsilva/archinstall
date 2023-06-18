rule = {
    matches = {
      {
        { "node.name", "equals", "alsa_input.pci-0000_00_1f.3.analog-stereo" },
      },
    },
    apply_properties = {
      ["node.description"] = "Headset Microphone",
      ["node.name"] = "Headset Microphone"
    },
  }

  table.insert(alsa_monitor.rules,rule)
