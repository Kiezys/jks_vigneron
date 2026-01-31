

DebugPrint("Initialisation du système de tonneaux serveur")

-- Fonction utilitaire pour obtenir le poids maximum de la stash tonneaux
local function getBarrelStashMaxWeight()
    DebugPrint("Récupération poids max stash tonneaux")
    for _, stash in pairs(Config.Stashes) do
        if stash.id == 'vigneron_barrel_stash' then
            return stash.weight or 500000
        end
    end
    return 500000 -- Valeur par défaut
end

-- Fonction utilitaire pour obtenir l'ID de la stash tonneaux
local function getBarrelStashId()
    for _, stash in pairs(Config.Stashes) do
        if stash.id == 'vigneron_barrel_stash' then
            return stash.id
        end
    end
    return 'vigneron_barrel_stash' -- Valeur par défaut
end

ESX.RegisterServerCallback('esx:getPlayerInventory', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getInventory())
end)

ESX.RegisterServerCallback('jks_vigneron:getStashCapacity', function(source, cb)
    -- Compter les tonneaux actuels dans le stash
    local currentBarrels = exports.ox_inventory:GetItem('vigneron_barrel_stash', 'tonneaux_vide', nil, true) or 0
    
    -- Utiliser CanCarryAmount pour obtenir la quantité maximale possible
    local maxBarrelsPossible = exports.ox_inventory:CanCarryAmount('vigneron_barrel_stash', 'tonneaux_vide')
    
    cb({
        currentBarrels = currentBarrels,
        maxBarrels = maxBarrelsPossible,
        currentWeight = currentBarrels * Config.BarrelOrders.barrelWeight,
        maxWeight = getBarrelStashMaxWeight()
    })
end)

RegisterNetEvent('jks_vigneron:recupererTonneauVide')
AddEventHandler('jks_vigneron:recupererTonneauVide', function()
    local _source = source
    DebugPrint("Récupération tonneau vide", {source = _source})
    
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérifier que le stash contient des tonneaux vides
    local stashCount = exports.ox_inventory:GetItem('vigneron_barrel_stash', 'tonneaux_vide', nil, true)
    
    if not stashCount or stashCount < 1 then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Aucun tonneau vide disponible dans le stock.')
        return
    end

    -- Ajouter l'item "tonneaux_vide" à l'inventaire du joueur
    if xPlayer.canCarryItem('tonneaux_vide', 1) then
        local success = exports.ox_inventory:RemoveItem('vigneron_barrel_stash', 'tonneaux_vide', 1)
        
        if success then
            xPlayer.addInventoryItem('tonneaux_vide', 1)

            -- Envoyer l'événement au client pour attacher le tonneau vide
            TriggerClientEvent('jks_attach_barrel_to_player', _source)

            -- Notifier le joueur
            TriggerClientEvent('ESX:Notify', _source, "success", 5000, 'Vous avez récupéré un tonneau vide.')
        else
            TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Erreur lors de la récupération du tonneau.')
        end
    else
        -- Si le joueur ne peut pas porter plus de tonneaux
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous ne pouvez pas porter plus de tonneaux vides.')
    end
end)

RegisterNetEvent('jks_vigneron:deposeTonneauVide')
AddEventHandler('jks_vigneron:deposeTonneauVide', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérifier que le joueur possède un tonneau vide
    local playerItem = xPlayer.getInventoryItem('tonneaux_vide')
    
    if not playerItem or playerItem.count < 1 then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous ne possédez pas de tonneau vide.')
        return
    end

    -- Retirer l'item de l'inventaire du joueur
    xPlayer.removeInventoryItem('tonneaux_vide', 1)
    TriggerClientEvent('jks_vigneron:removeBarrelProps', _source)
    
    -- Ajouter l'item au stash
    local success = exports.ox_inventory:AddItem('vigneron_barrel_stash', 'tonneaux_vide', 1)
    
    if success then
        TriggerClientEvent('ESX:Notify', _source, "success", 5000, 'Vous avez déposé un tonneau vide.')
    else
        -- Si l'ajout au stash échoue, remettre l'item au joueur
        xPlayer.addInventoryItem('tonneaux_vide', 1)
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Erreur lors du dépôt du tonneau.')
    end
end)

-- Table pour tracker les missions actives par joueur
local activeMissions = {}

RegisterNetEvent('jks_vigneron:commanderTonneaux')
AddEventHandler('jks_vigneron:commanderTonneaux', function(quantity)
    local _source = source
    DebugPrint("Commande de tonneaux", {source = _source, quantity = quantity})
    
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérifier qu'aucune mission n'est déjà active pour ce joueur
    if activeMissions[_source] then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous avez déjà une commande en cours! Terminez-la avant d\'en passer une nouvelle.')
        return
    end

    -- Vérifier que la quantité est valide
    if not quantity or quantity < 1 then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Quantité invalide. Minimum: 1.')
        return
    end

    -- Vérifier que le joueur a le bon job et grade
    if xPlayer.job.name ~= Config.General.requiredJob then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous devez être vigneron pour commander des tonneaux.')
        return
    end

    if xPlayer.job.grade < Config.BarrelOrders.minGrade then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous devez avoir le grade ' .. Config.BarrelOrders.minGrade .. ' ou plus pour commander des tonneaux.')
        return
    end

    -- Vérifier que le joueur a assez d'argent
    local pricePerBarrel = Config.BarrelOrders.pricePerBarrel
    local totalPrice = pricePerBarrel * quantity
    
    if xPlayer.getMoney() < totalPrice then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous n\'avez pas assez d\'argent. Coût total: ' .. totalPrice .. '$')
        return
    end

    -- Vérifier la capacité du stash avant la commande
    local maxBarrelsPossible = exports.ox_inventory:CanCarryAmount('vigneron_barrel_stash', 'tonneaux_vide')
    
    if quantity > maxBarrelsPossible then
        if maxBarrelsPossible <= 0 then
            TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Le stockage est plein! Impossible de commander des tonneaux.')
        else
            TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Stockage insuffisant! Vous ne pouvez commander que ' .. maxBarrelsPossible .. ' tonneaux maximum.')
        end
        return
    end

    -- Retirer l'argent
    xPlayer.removeMoney(totalPrice)

    -- Marquer la mission comme active pour ce joueur
    activeMissions[_source] = {
        quantity = quantity,
        price = totalPrice,
        startTime = os.time()
    }

    -- Créer la mission de récupération
    TriggerClientEvent('jks_vigneron:startDeliveryMission', _source, quantity, totalPrice)
    
    TriggerClientEvent('ESX:Notify', _source, "success", 5000, 'Commande passée! Allez récupérer vos ' .. quantity .. ' tonneaux. Coût: ' .. totalPrice .. '$')
end)

RegisterNetEvent('jks_vigneron:recupererCommande')
AddEventHandler('jks_vigneron:recupererCommande', function(quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérifier qu'une mission est active pour ce joueur
    if not activeMissions[_source] then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Aucune commande active trouvée.')
        return
    end

    -- Vérifier que le joueur a le bon job
    if xPlayer.job.name ~= Config.General.requiredJob then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous devez être vigneron pour récupérer cette commande.')
        return
    end

    -- Marquer que le joueur a récupéré la commande (sans donner les items)
    TriggerClientEvent('jks_vigneron:commandeRecuperee', _source, quantity)
    TriggerClientEvent('ESX:Notify', _source, "success", 5000, 'Commande récupérée! Retournez à l\'entreprise pour déposer les tonneaux.')
end)

RegisterNetEvent('jks_vigneron:deposerCommande')
AddEventHandler('jks_vigneron:deposerCommande', function(quantity)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    -- Vérifier qu'une mission est active pour ce joueur
    if not activeMissions[_source] then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Aucune commande active trouvée.')
        return
    end

    -- Vérifier que le joueur a le bon job
    if xPlayer.job.name ~= Config.General.requiredJob then
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Vous devez être vigneron pour déposer cette commande.')
        return
    end

    -- Ajouter les tonneaux au stash
    local success, response = exports.ox_inventory:AddItem('vigneron_barrel_stash', 'tonneaux_vide', quantity)
    
    if success then
        TriggerClientEvent('ESX:Notify', _source, "success", 5000, 'Commande déposée! ' .. quantity .. ' tonneaux ajoutés au stock.')
        
        -- Nettoyer la mission active
        activeMissions[_source] = nil
        
        TriggerClientEvent('jks_vigneron:completeDeliveryMission', _source)
    else
        print("Erreur AddItem:", response) -- Debug
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Erreur lors du dépôt de la commande: ' .. (response or 'Raison inconnue'))
    end
end)

-- Nettoyer les missions des joueurs déconnectés
AddEventHandler('playerDropped', function(reason)
    local _source = source
    if activeMissions[_source] then
        activeMissions[_source] = nil
        print("Mission nettoyée pour le joueur " .. _source .. " (déconnecté)")
    end
end)

-- Fonction pour nettoyer les missions expirées (optionnel)
local function cleanupExpiredMissions()
    local currentTime = os.time()
    local maxMissionTime = 3600 -- 1 heure en secondes
    
    for playerId, mission in pairs(activeMissions) do
        if currentTime - mission.startTime > maxMissionTime then
            activeMissions[playerId] = nil
            print("Mission expirée nettoyée pour le joueur " .. playerId)
        end
    end
end

-- Nettoyer les missions expirées toutes les 10 minutes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000) -- 10 minutes
        cleanupExpiredMissions()
    end
end)