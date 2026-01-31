DebugPrint("Initialisation du système de stashes")

-- Configuration des stashes depuis le config
local function createStashes()
    DebugPrint("Création des stashes", {count = #Config.Stashes})
    for _, stash in ipairs(Config.Stashes) do
        DebugPrint("Création stash", {id = stash.id, name = stash.name, slots = stash.slots, weight = stash.weight})
        exports.ox_inventory:RegisterStash(
            stash.id,
            stash.name,
            stash.slots or 25, -- slots depuis config ou 25 par défaut
            stash.weight or 500000, -- weight depuis config ou 500kg par défaut
            false, -- owner (false = accessible à tout le job)
            { vigneron = 0 } -- jobs requis
        )
    end
end

AddEventHandler('onServerResourceStart', function(resourceName)
    DebugPrint("Démarrage ressource", {resourceName = resourceName})
    if resourceName == 'ox_inventory' or resourceName == GetCurrentResourceName() then
        DebugPrint("Création des stashes au démarrage")
        createStashes()
    end
end)
