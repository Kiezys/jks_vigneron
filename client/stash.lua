-- Créer les zones d'interaction pour chaque stash
for _, stash in ipairs(Config.Stashes) do
    -- Vérifier que la stash a des coordonnées (exclure vigneron_barrel_stash)
    if stash.coords then
        exports.ox_target:addSphereZone({
            coords = stash.coords,
            radius = stash.radius,
            options = {
                {
                    name = 'stash_' .. stash.id,
                    label = stash.label,
                    icon = stash.icon,
                    iconColor = stash.iconColor,
                    groups = Config.General.requiredGroups,
                    onSelect = function()
                        openStash(stash.id, stash.name)
                    end,
                },
            }
        })
    end
end

-- Fonction pour ouvrir une stash
function openStash(stashId, stashName)
    exports.ox_inventory:openInventory('stash', {id = stashId})
    ESX.ShowNotification('Vous avez ouvert ' .. stashName .. '.', 'success', 5000)
end
