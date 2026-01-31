-- Configuration de l'affichage des métadonnées pour ox_inventory
DebugPrint("Configuration des métadonnées ox_inventory")
exports.ox_inventory:displayMetadata({
    wineQuantity = 'Quantité de vin',
    grapeType = 'Type de raisin', 
    vintage = 'Millésime',
    grapesUsed = 'Grappes utilisées',
    maxCapacity = 'Capacité max',
    createdAt = 'Date de création',
    -- Métadonnées pour les bouteilles
    bottledDate = 'Date de mise en bouteille',
    bottledBy = 'Mis en bouteille par',
    wineAmount = 'Quantité de vin',
    quality = 'Qualité',
    qualityLabel = 'Qualité du vin',
    qualityDescription = 'Description'
})

-- Créer les zones d'interaction pour chaque cuve individuelle
DebugPrint("Création des zones d'interaction pour les cuves individuelles", {count = #Config.FermentationSettings.individualTanks})
for _, tank in ipairs(Config.FermentationSettings.individualTanks) do
    exports.ox_target:addSphereZone({
        coords = tank.coords,
        radius = tank.radius,
        groups = Config.General.requiredGroups,
        options = {
            {
                name = 'fermentation_cuve_white_' .. tank.id,
                icon = 'fa-solid fa-wine-bottle',
                label = 'Déposer des grappes blanches (' .. tank.name .. ')',
                groups = Config.General.requiredGroups,
                onSelect = function()
                    depositGrapes(tank.id, 'white')
                end,
            },
            {
                name = 'fermentation_cuve_red_' .. tank.id,
                icon = 'fa-solid fa-wine-bottle',
                label = 'Déposer des grappes rouges (' .. tank.name .. ')',
                groups = Config.General.requiredGroups,
                onSelect = function()
                    depositGrapes(tank.id, 'red')
                end,
            },
            {
                name = 'retrieve_wine_' .. tank.id,
                icon = 'fa-solid fa-wine-bottle',
                label = 'Récupérer le vin (' .. tank.name .. ')',
                groups = Config.General.requiredGroups,
                onSelect = function()
                    retrieveWine(tank.id)
                end,
            },
            {
                name = 'check_cuve_' .. tank.id,
                icon = 'fa-solid fa-check-circle',
                label = 'Vérifier l\'état de la cuve (' .. tank.name .. ')',
                groups = Config.General.requiredGroups,
                onSelect = function()
                    TriggerServerEvent('jks_vigneron:checkCuve', tank.id)
                end,
            }
        }
    })
end

-- Fonction pour déposer les grappes
function depositGrapes(cuveId, grapeType)
    DebugPrint("Démarrage dépôt de grappes", {cuveId = cuveId, grapeType = grapeType})
    
    local config = grapeType == 'white' and Config.FermentationSettings.whiteWine or Config.FermentationSettings.redWine
    local grapeLabel = grapeType == 'white' and 'blanches' or 'rouges'
    
    -- Utiliser les limites définies dans la configuration
    local minGrapes = config.minGrapes
    local maxGrapes = config.maxGrapes
    
    -- Demander la quantité à déposer
    local input = lib.inputDialog('Dépôt de raisins ' .. grapeLabel, {
        {
            type = 'number',
            label = 'Quantité de grappes à déposer',
            description = 'Minimum: ' .. minGrapes .. ' | Maximum: ' .. maxGrapes .. ' grappes',
            min = minGrapes,
            max = maxGrapes,
            default = config.defaultGrapes,
            required = true
        }
    })
    
    if not input or not input[1] then
        return
    end
    
    local quantity = tonumber(input[1])
    if not quantity or quantity < minGrapes or quantity > maxGrapes then
        ESX.ShowNotification('~r~Quantité invalide! Minimum: ' .. minGrapes .. ', Maximum: ' .. maxGrapes, 'error')
        return
    end
    
    if lib.progressBar({
        duration = Config.FermentationSettings.depositTime,
        label = "Dépôt de " .. quantity .. " grappes " .. grapeLabel,
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = false,
            combat = true,
        },
        anim = {
            dict = Config.FermentationSettings.animation.dict,
            clip = Config.FermentationSettings.animation.lib,
        },
    }) then
        TriggerServerEvent('jks_vigneron:depositGrapes', quantity, cuveId, grapeType)
    end
end

-- Fonction pour récupérer le vin
function retrieveWine(cuveId)
    DebugPrint("Démarrage récupération de vin", {cuveId = cuveId})
    
    -- Vérifier si le joueur a des tonneaux vides dans son inventaire
    ESX.TriggerServerCallback('jks_vigneron:hasContainer', function(hasContainer)
        if hasContainer then
            if lib.progressBar({
                duration = Config.FermentationSettings.retrieveTime,
                label = "Récupération du vin",
                useWhileDead = false,
                canCancel = true,
                disable = {
                    car = true,
                    move = false,
                    combat = true,
                },
                anim = {
                    dict = Config.FermentationSettings.animation.dict,
                    clip = Config.FermentationSettings.animation.lib,
                },
            }) then
                TriggerServerEvent('jks_vigneron:retrieveWine', cuveId)
            end
        else
            ESX.ShowNotification('Vous avez besoin d\'un tonneau vide pour récupérer le vin.', 'error', 5000)
        end
    end)
end

-- Points d'interaction pour déposer les tonneaux dans les cuves principales séparées

-- Cuve principale pour le vin blanc
exports.ox_target:addSphereZone({
    coords = Config.FermentationSettings.mainTanks.white.coords,
    radius = Config.FermentationSettings.mainTanks.white.radius,
    groups = Config.General.requiredGroups,
    options = {
        {
            name = 'deposer_tonneau_blanc',
            icon = 'fa-solid fa-box',
            label = 'Déposer le tonneau blanc',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:deposerTonneau', 'white')
            end,
        },
        {
            name = 'check_cuve_principale_blanc',
            icon = 'fa-solid fa-check-circle',
            label = 'Vérifier l\'état de la cuve principale (blanc)',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:checkCuvePrincipale', 'white')
            end,
        },
        {
            name = 'mettre_en_bouteille_blanc',
            icon = 'fa-solid fa-wine-glass',
            label = 'Mettre en bouteille (Vin blanc)',
            groups = Config.General.requiredGroups,
            onSelect = function()
                startBottlingFromTank('white')
            end,
        }
    }
})

-- Cuve principale pour le vin rouge
exports.ox_target:addSphereZone({
    coords = Config.FermentationSettings.mainTanks.red.coords,
    radius = Config.FermentationSettings.mainTanks.red.radius,
    groups = Config.General.requiredGroups,
    options = {
        {
            name = 'deposer_tonneau_rouge',
            icon = 'fa-solid fa-box',
            label = 'Déposer le tonneau rouge',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:deposerTonneau', 'red')
            end,
        },
        {
            name = 'check_cuve_principale_rouge',
            icon = 'fa-solid fa-check-circle',
            label = 'Vérifier l\'état de la cuve principale (rouge)',
            groups = Config.General.requiredGroups,
            onSelect = function()
                TriggerServerEvent('jks_vigneron:checkCuvePrincipale', 'red')
            end,
        },
        {
            name = 'mettre_en_bouteille_rouge',
            icon = 'fa-solid fa-wine-glass',
            label = 'Mettre en bouteille (Vin rouge)',
            groups = Config.General.requiredGroups,
            onSelect = function()
                startBottlingFromTank('red')
            end,
        }
    }
})

-- Fonction pour démarrer la mise en bouteille depuis la cuve
function startBottlingFromTank(wineType)
    DebugPrint("Démarrage mise en bouteille", {wineType = wineType})
    
    if not Config.Bottling then 
        LogError("Configuration de mise en bouteille non chargée")
        ESX.ShowNotification('Configuration de mise en bouteille non chargée.', 'error', 5000)
        return 
    end
    
    local config = wineType == 'white' and Config.Bottling.whiteWine or Config.Bottling.redWine
    if not config then 
        LogError("Configuration pour le vin non trouvée", {wineType = wineType})
        ESX.ShowNotification('Configuration pour le vin ' .. wineType .. ' non trouvée.', 'error', 5000)
        return 
    end
    
    -- Vérifier si le joueur a des bouteilles vides
    ESX.TriggerServerCallback('jks_vigneron:hasEmptyBottles', function(hasBottles)
        if hasBottles then
            -- Vérifier la quantité de vin disponible dans la cuve
            ESX.TriggerServerCallback('jks_vigneron:getTankWineAmount', function(wineAmount)
                if wineAmount >= config.winePerBottle then
                    local maxPossible = math.floor(wineAmount / config.winePerBottle)
                    
                    -- Demander combien de bouteilles remplir
                    local input = exports.ox_lib:inputDialog('Mise en bouteille', {
                        {
                            type = 'number',
                            label = 'Nombre de bouteilles à remplir',
                            description = 'Vin disponible: ' .. wineAmount .. 'L (max ' .. maxPossible .. ' bouteilles)',
                            default = 1,
                            min = 1,
                            max = maxPossible
                        }
                    })
                    
                    if input and input[1] and input[1] > 0 then
                        local bottleCount = math.floor(input[1])
                        
                        -- Vérifier que le nombre demandé ne dépasse pas le maximum possible
                        if bottleCount <= maxPossible then
                            -- Charger le prop approprié
                            local propModel = wineType == 'white' and Config.Bottling.props.whiteWine.model or Config.Bottling.props.redWine.model
                            local propData = wineType == 'white' and Config.Bottling.props.whiteWine or Config.Bottling.props.redWine
                            
                            -- Charger le modèle du prop
                            RequestModel(propModel)
                            while not HasModelLoaded(propModel) do
                                Citizen.Wait(1)
                            end
                            
                            -- Créer le prop
                            local playerPed = PlayerPedId()
                            local prop = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
                            AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, propData.bone), 
                                propData.offset.x, propData.offset.y, propData.offset.z, 
                                propData.rotation.x, propData.rotation.y, propData.rotation.z, 
                                false, false, false, false, 2, true)
                            
                            -- Démarrer l'animation de mise en bouteille
                            if lib.progressBar({
                                duration = config.bottlingTime * bottleCount,
                                label = "Mise en bouteille " .. bottleCount .. " " .. config.outputLabel,
                                useWhileDead = false,
                                canCancel = true,
                                disable = {
                                    car = true,
                                    move = false,
                                    combat = true,
                                },
                                anim = {
                                    dict = Config.Bottling.animation.dict,
                                    clip = Config.Bottling.animation.lib,
                                },
                            }) then
                                -- Supprimer le prop
                                if DoesEntityExist(prop) then
                                    DeleteObject(prop)
                                end
                                TriggerServerEvent('jks_vigneron:bottleWineFromTank', wineType, bottleCount)
                            else
                                -- Supprimer le prop si annulé
                                if DoesEntityExist(prop) then
                                    DeleteObject(prop)
                                end
                            end
                        else
                            ESX.ShowNotification('Le nombre de bouteilles demandé dépasse la quantité disponible.', 'error', 5000)
                        end
                    end
                else
                    ESX.ShowNotification('Il n\'y a pas assez de vin dans la cuve pour mettre en bouteille.', 'error', 5000)
                end
            end, wineType)
        else
            ESX.ShowNotification('Vous avez besoin de ' .. config.containerLabel .. ' pour mettre en bouteille.', 'error', 5000)
        end
    end)
end
