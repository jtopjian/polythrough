-- polythrough
--
-- library for passing midi
-- between connected ports
-- + scale quantizing
-- + user event callbacks
--
-- With support for sending
-- across multiple channels.
--
-- for how to use see example script

local Polythrough = {}
local core = require("polythrough/lib/core")
local utils = require("polythrough/lib/utils")

local tab = require "tabutil"
local mod = require "core/mods"

local port_param_items = {
  "separator",
  "active",
  "target",
  "input_channel",
  "output_channel",
  "send_clock",
  "quantize_midi",
  "root_note",
  "current_scale",
  "cc_limit",
  "crow_notes",
  "crow_cc_outputs",
  "crow_cc_selection_a",
  "crow_cc_selection_b",
}

Polythrough.user_event = core.user_event
Polythrough.get_port_from_id = core.get_port_from_id

local function device_event(id, data)
  local port = core.get_port_from_id(id)

  if port ~= nil and params:get("active_"..port) == 2 then
    core.device_event(
      port,
      params:get("target_"..port),
      params:get("input_channel_"..port),
      params:get("output_channel_"..port),
      params:get("additional_channels_"..port),
      params:get("send_clock_"..port)==2,
      params:get("quantize_midi_"..port),
      params:get("current_scale_"..port),
      params:get("cc_limit_"..port),
      params:get("crow_notes_"..port),
      params:get("crow_cc_outputs_"..port),
      params:get("crow_cc_selection_a_"..port),
      params:get("crow_cc_selection_b_"..port),
      data)

    Polythrough.user_event(id, data)
  end
end


function Polythrough.init()
  if tab.contains(mod.loaded_mod_names(), "polythrough") then
    print("Polythrough already running as mod")
    return
  end

  core.setup_midi()
  core.origin_event = device_event -- assign to core event

  if core.has_devices == true then

      port_amount = tab.count(core.ports)
      params:add_group("POLYTHROUGH", #port_param_items*port_amount + 2)

      for k, v in pairs(core.ports) do
          params:add_separator(v.port .. ': ' .. v.name)

          params:add {
            type="option",
            id="active_" .. v.port,
            name = "Active",
            options = core.toggles
          }

          params:add {
            type="number",
            id="target_" .. v.port,
            name = "Target",
            min = 1,
            max = tab.count(core.targets[v.port]),
            default=1,
            action = function(value)
              core.port_connections[v.port] = core.set_target_connections(v.port, value)
            end,
            formatter = function(param)
              value = param:get()

              if value == 1 then return core.targets[v.port][value] end
              local target = core.targets[v.port][value]
              local found_port = utils.table_find_value(core.ports, function(_,v) return target == v.port end)
              if found_port then return found_port.name end

              return "Saved port unconnected"
            end,
          }

          params:add {
            type = "option",
            id = "input_channel_"..v.port,
            name = "Input channel",
            options = core.input_channels
          }
          params:add {
            type = "option",
            id = "output_channel_"..v.port,
            name = "Output channel",
            options = core.output_channels
          }
          params:add {
            type = "number",
            id = "additional_channels_"..v.port,
            name = "Additional channels",
            min = 0,
            max = 15,
            default = 0
          }
          params:add {
            type = "option",
            id = "send_clock_"..v.port,
            name = "Clock out",
            options = core.toggles,
            default=1,
            action = function(value)
                if value == 1 then
                    core.stop_clocks(v.port)
                end
            end
          }
          params:add {
            type = "option",
            id = "quantize_midi_"..v.port,
            name = "Quantize midi",
            options = core.toggles
          }
          params:add {
            type = "number",
            id = "root_note_"..v.port,
            name = "Root",
            min = 0,
            max = 11,
            formatter = function(param)
              return core.root_note_formatter(param:get())
            end,
            action = function()
                core.build_scale(params:get("root_note_"..v.port), params:get("current_scale_"..v.port), v.port)
            end
          }
          params:add {
              type = "option",
              id = "current_scale_"..v.port,
              name = "Scale",
              options = core.scale_names,
              action = function()
                core.build_scale(params:get("root_note_"..v.port), params:get("current_scale_"..v.port), v.port)
              end
            }
          params:add {
            type = "option",
            id = "cc_limit_"..v.port,
            name = "CC limit",
            options = core.cc_limits
          }
          params:add {
            type = "option",
            id = "crow_notes_"..v.port,
            name = "Crow note output",
            options = core.crow_notes
          }
          params:add {
            type = "option",
            id = "crow_cc_outputs_"..v.port,
            name = "Crow cc output",
            options = core.crow_cc_outputs
          }
          params:add {
            type = "number",
            id = "crow_cc_selection_a_"..v.port,
            name = "Crow cc out a",
            min = 1,
            max = 128,
            default = 1
          }
          params:add {
            type = "number",
            id = "crow_cc_selection_b_"..v.port,
            name = "Crow cc out b",
            min = 1,
            max = 128,
            default = 1
          }
      end
      params:add_separator("All devices")
      params:add {
        type = "trigger",
        id = "midi_panic",
        name = "Midi panic",
        action = function()
          core.stop_all_notes()
        end
      }

  end
  params:bang()
end

return Polythrough
