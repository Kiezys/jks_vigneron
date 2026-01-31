-- Créer les zones d'interaction pour chaque point de vêtements
for _, outfit in ipairs(Config.Outfits) do
    exports.ox_target:addSphereZone({
        coords = outfit.coords,
        radius = outfit.radius,
        options = {
            {
                name = 'outfit_' .. outfit.id,
                icon = outfit.icon,
                iconColor = outfit.iconColor,
                label = outfit.label,
                groups = Config.General.requiredGroups,
                onSelect = function()
                    openOutfitMenu(outfit)
                end,
            },
        }
    })
end

-- Fonction pour ouvrir le menu des tenues
function openOutfitMenu(outfitConfig)
    TriggerEvent(outfitConfig.event, function()
        OpenMenu(nil, "outfit")
    end)
end