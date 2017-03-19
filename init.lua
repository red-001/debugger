-- debugger/init.lua
local modstorage = core.get_mod_storage()
debugger = {}

-- Logger
function debugger.log(content, log_type)
  assert(content, "debugger.log: content nil")
  if log_type == nil then log_type = "action" end
  minetest.log(log_type, "[debugger] "..content)
end

debugger.CREATIVE = 1

local forms = {}

-- Load forms
local function load_formdata()
	local res = minetest.deserialize(modstorage:get_string("forms"))
	if type(res) == "table" then
		forms = res
	end
end

-- Load all forms
load_formdata()

-- Save forms
function save_formdata()
  modstorage:set_string("forms", minetest.serialize(forms))
end

-- Register on shutdown
minetest.register_on_shutdown(save_formdata)

-- Editor formspec
local function get_editor_formspec(name)
  local form_string = forms[name] or ""

  local output = form_string:split("\n")

  for i, line in ipairs(output) do
    output[i] = line
  end

  return [[
    size[20,12]
    box[-0.27,-0.3;13,12.68;#FFFFFF00]
    ]]..table.concat(output)..[[
    textarea[13.03,-0.35;7.58,13.9;input;;]]..minetest.formspec_escape(form_string)..[[]
    button[12.75,11.64;2.5,1;refresh;Refresh and Save]
    label[15.3,11.8;Elements are separated by a newline.]
  ]]
end

-- Register chatcommand
minetest.register_chatcommand("form_editor", {
  param = "<edit/preview>",
  description = "Formspec Creator",
  privs = {debug=true},
  func = function(param)
	local name = "fake_player"
    local form_string = forms[name] or ""
	print(param)
    if param == "preview" then
      -- Show formspec
      minetest.show_formspec("debugger:form_preview", form_string)
    else
      -- Show formspec editor
      minetest.show_formspec("debugger:form_editor", get_editor_formspec(name))
    end
  end,
})



-- [event] On Receive Fields
minetest.register_on_formspec_input(function(formname, fields)
print(formname)
print(dump(fields))
  if formname == "debugger:form_editor" then
    local name = "fake_player"

    if fields.refresh then
      forms[name] = fields.input

      -- Update formspec editor
      minetest.show_formspec("debugger:form_editor", get_editor_formspec(name))
    end
  end
end)
