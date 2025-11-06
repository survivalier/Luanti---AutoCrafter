-- AutoCrafter Mod for Luanti / Minetest
-- Version avec sauvegarde persistante
-- Licence: MIT

local S = minetest.get_translator("autocrafter")

-- ===============================
-- Données persistantes
-- ===============================
local storage_path = minetest.get_worldpath() .. "/autocrafter_data.json"
local autocrafter_registry = {}

-- Fonction pour sauvegarder les données
local function save_autocrafter_data()
    local file = io.open(storage_path, "w")
    if file then
        file:write(minetest.write_json(autocrafter_registry))
        file:close()
    end
end

-- Fonction pour charger les données
local function load_autocrafter_data()
    local file = io.open(storage_path, "r")
    if file then
        local data = file:read("*all")
        file:close()
        local decoded = minetest.parse_json(data)
        if type(decoded) == "table" then
            autocrafter_registry = decoded
        end
    end
end

load_autocrafter_data()

-- Sauvegarde automatique à l’arrêt du serveur
minetest.register_on_shutdown(save_autocrafter_data)

-- ===============================
-- Crafter Chest
-- ===============================
minetest.register_node("autocrafter:crafter_chest", {
    description = S("Crafter Chest"),
    tiles = {
        "autocrafter_stonechest_top.png", "autocrafter_stonechest_bottom.png",
        "autocrafter_stonechest_side.png", "autocrafter_stonechest_side.png",
        "autocrafter_stonechest_side.png", "autocrafter_stonechest_side.png"
    },
    groups = {choppy = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_stone_defaults(),

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", S("Crafter Chest"))
        meta:get_inventory():set_size("main", 8 * 4)
    end,

    can_dig = function(pos, player)
        local inv = minetest.get_meta(pos):get_inventory()
        return inv:is_empty("main")
    end,

    on_rightclick = function(pos, node, player)
        minetest.show_formspec(player:get_player_name(), "autocrafter:crafter_chest",
            "size[8,9]" ..
            "list[current_name;main;0,0;8,4;]" ..
            "list[current_player;main;0,5;8,4;]" ..
            "listring[]")
    end,
})

-- ===============================
-- Auto Crafter
-- ===============================
minetest.register_node("autocrafter:autocrafter", {
    description = S("Auto Crafter"),
    tiles = {
        "autocrafter_top.png", "autocrafter_bottom.png",
        "autocrafter_side.png", "autocrafter_side.png",
        "autocrafter_side.png", "autocrafter_front.png"
    },
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_metal_defaults(),

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", S("AutoCrafter (Inactif)"))
        meta:set_string("owner", "")
        meta:set_string("disabled", "false")
        local inv = meta:get_inventory()
        inv:set_size("template", 1)
        inv:set_size("output", 1)
    end,

    after_place_node = function(pos, placer)
        local meta = minetest.get_meta(pos)
        local owner = placer:get_player_name()
        meta:set_string("owner", owner)
        local id = minetest.pos_to_string(pos)
        autocrafter_registry[id] = {
            pos = pos,
            owner = owner,
            state = "inactif",
            disabled = false,
        }
        save_autocrafter_data()
    end,

    on_destruct = function(pos)
        autocrafter_registry[minetest.pos_to_string(pos)] = nil
        save_autocrafter_data()
    end,

    on_rightclick = function(pos, node, player)
        local meta = minetest.get_meta(pos)
        if meta:get_string("disabled") == "true" then
            minetest.chat_send_player(player:get_player_name(), "× Cet AutoCrafter est désactivé par un administrateur.")
            return
        end

        local form = "size[8,6]" ..
            "label[0,0;AutoCrafter]" ..
            "list[current_name;template;0,1;1,1;]" ..
            "button[2,1;2,1;craft;Activer]" ..
            "list[current_name;output;6,1;1,1;]" ..
            "list[current_player;main;0,3;8,3;]" ..
            "listring[]"
        minetest.show_formspec(player:get_player_name(), "autocrafter:autocrafter", form)
    end,
})

-- ===============================
-- Commande admin /crafter
-- ===============================
minetest.register_chatcommand("crafter", {
    description = "Ouvre la liste des AutoCrafters actifs (admin uniquement)",
    privs = {server = true},
    func = function(name)
        local list = "size[10,8]" ..
            "label[0,0;📦 Liste des AutoCrafters :]" ..
            "tablecolumns[text;text;text;button]" ..
            "table[0,0.5;9.8,7;autocrafter_table;Pseudo,Position,État,Action"

        for id, data in pairs(autocrafter_registry) do
            local pos_str = minetest.pos_to_string(data.pos)
            local state = data.disabled and "§cDésactivé" or data.state
            list = list .. "," .. data.owner .. "," .. pos_str .. "," .. state .. ",Désactiver"
        end

        list = list .. "]"
        minetest.show_formspec(name, "autocrafter:admin_panel", list)
    end,
})

-- ===============================
-- Gestion du panneau admin
-- ===============================
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "autocrafter:admin_panel" then return end

    if fields.autocrafter_table then
        local event = minetest.explode_table_event(fields.autocrafter_table)
        if event.type == "CHG" then
            local selected = event.row
            local count = 0
            for id, data in pairs(autocrafter_registry) do
                count = count + 1
                if count == selected then
                    local meta = minetest.get_meta(data.pos)
                    data.disabled = not data.disabled
                    meta:set_string("disabled", tostring(data.disabled))
                    meta:set_string("infotext", data.disabled and "AutoCrafter (Désactivé)" or "AutoCrafter (Inactif)")
                    save_autocrafter_data()
                    minetest.chat_send_player(player:get_player_name(),
                        "✓ AutoCrafter de " .. data.owner .. " à " .. minetest.pos_to_string(data.pos)
                        .. (data.disabled and " désactivé." or " réactivé."))
                    break
                end
            end
        end
    end
end)

-- ===============================
-- Craft de l'AutoCrafter et du Coffre
-- ===============================
minetest.register_craft({
    output = "autocrafter:autocrafter 1",
    recipe = {
        {"", "default:steel_ingot", ""},
        {"default:steel_ingot", "default:chest", "default:steel_ingot"},
        {"default:wood", "default:steel_ingot", "default:wood"},
    },
})

minetest.register_craft({
    output = "autocrafter:crafter_chest 1",
    recipe = {
        {"", "", ""},
        {"", "default:chest", ""},
        {"", "", ""},
    },
}
-- ===============================
-- Gestion de l'activation/désactivation via le scanner
-- ===============================

local last_scanned_crafter = {}

-- On modifie le scanner pour stocker la dernière position scannée
minetest.override_item("autocrafter:scanner", {
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end

        local pos = pointed_thing.under
        local node = minetest.get_node(pos)
        if node.name ~= "autocrafter:autocrafter" then
            minetest.chat_send_player(user:get_player_name(), "❌ Ce bloc n'est pas un AutoCrafter.")
            return
        end

        local meta = minetest.get_meta(pos)
        local owner = meta:get_string("owner") or "Inconnu"
        local disabled = meta:get_string("disabled") == "true"
        local state = disabled and "🚫 Désactivé" or "✅ Actif"
        local pos_str = minetest.pos_to_string(pos)
        local pname = user:get_player_name()

        last_scanned_crafter[pname] = vector.new(pos)

        local msg = "📦 AutoCrafter Info :\n" ..
                    "👤 Propriétaire : " .. owner .. "\n" ..
                    "📍 Position : " .. pos_str .. "\n" ..
                    "⚙️ État : " .. state .. "\n\n" ..
                    "💡 Admins : utilisez /crafter_disable ou /crafter_enable"

        minetest.chat_send_player(pname, msg)
    end,
})

-- ===============================
-- Commande /crafter_disable
-- ===============================
minetest.register_chatcommand("crafter_disable", {
    description = "Désactive le dernier AutoCrafter scanné",
    privs = { server = true },
    func = function(name)
        local pos = last_scanned_crafter[name]
        if not pos then
            minetest.chat_send_player(name, "❌ Vous n'avez pas encore scanné d'AutoCrafter.")
            return
        end

        local meta = minetest.get_meta(pos)
        if meta:get_string("disabled") == "true" then
            minetest.chat_send_player(name, "⚠️ Cet AutoCrafter est déjà désactivé.")
            return
        end

        meta:set_string("disabled", "true")
        meta:set_string("infotext", "AutoCrafter (Désactivé)")
        minetest.chat_send_player(name, "🚫 AutoCrafter désactivé avec succès !")

        -- Feedback visuel
        minetest.add_particlespawner({
            amount = 10,
            time = 0.3,
            minpos = pos,
            maxpos = pos,
            minvel = {x=-1, y=1, z=-1},
            maxvel = {x=1, y=2, z=1},
            texture = "default_smoke.png",
        })
    end,
})

-- ===============================
-- Commande /crafter_enable
-- ===============================
minetest.register_chatcommand("crafter_enable", {
    description = "Réactive le dernier AutoCrafter scanné",
    privs = { server = true },
    func = function(name)
        local pos = last_scanned_crafter[name]
        if not pos then
            minetest.chat_send_player(name, "❌ Vous n'avez pas encore scanné d'AutoCrafter.")
            return
        end

        local meta = minetest.get_meta(pos)
        if meta:get_string("disabled") ~= "true" then
            minetest.chat_send_player(name, "⚠️ Cet AutoCrafter est déjà actif.")
            return
        end

        meta:set_string("disabled", "false")
        meta:set_string("infotext", "AutoCrafter (Réactivé)")
        minetest.chat_send_player(name, "✅ AutoCrafter réactivé avec succès !")

        -- Feedback visuel
        minetest.add_particlespawner({
            amount = 10,
            time = 0.3,
            minpos = pos,
            maxpos = pos,
            minvel = {x=-1, y=1, z=-1},
            maxvel = {x=1, y=2, z=1},
            texture = "default_item_smoke.png^[colorize:#00FF00:150",
        })
    end,
})