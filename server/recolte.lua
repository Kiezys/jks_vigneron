-- =====================================================
-- SERVEUR RÉCOLTE AVEC LIMITATION - TON VIGNERON
-- =====================================================

DebugPrint("Initialisation du système de récolte serveur")

-- Table pour stocker les quantités récoltées par joueur et par zone
local playerHarvestCount = {}

-- Événement unique pour toutes les récoltes
RegisterNetEvent('jks_vigneron:harvestItem')
AddEventHandler('jks_vigneron:harvestItem', function(zoneId)
    local _source = source
    DebugPrint("Récolte d'item", {source = _source, zoneId = zoneId})
    
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then
        LogError("Joueur non trouvé pour récolte", {source = _source})
        return
    end
    
    local playerId = xPlayer.identifier
    
    -- Trouver la zone de récolte dans la configuration
    local harvestZone = nil
    for _, zone in ipairs(Config.HarvestZones) do
        if zone.id == zoneId then
            harvestZone = zone
            break
        end
    end
    
    if not harvestZone then
        print("Erreur: Zone de récolte non trouvée pour l'ID: " .. tostring(zoneId))
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 'Zone de récolte non trouvée.')
        return
    end
    
    -- Vérifier les limites seulement si le système est activé
    if Config.HarvestSettings.enableMaxItemsLimit then
        -- Initialiser le compteur du joueur s'il n'existe pas
        if not playerHarvestCount[playerId] then
            playerHarvestCount[playerId] = {}
        end
        
        if not playerHarvestCount[playerId][zoneId] then
            playerHarvestCount[playerId][zoneId] = 0
        end
        
        -- Vérifier si le joueur a atteint la limite pour cette zone
        if playerHarvestCount[playerId][zoneId] >= harvestZone.maxItemsPerReboot then
            TriggerClientEvent('ESX:Notify', _source, "error", 5000, 
                'Vous avez atteint la limite de récolte pour cette zone (' .. harvestZone.maxItemsPerReboot .. ' items maximum).')
            -- Arrêter la récolte automatique côté client
            TriggerClientEvent('jks_vigneron:stopHarvest', _source, zoneId, 'limit_reached')
            return
        end
    end
    
    -- Générer la quantité aléatoire
    local randomAmount = math.random(harvestZone.minAmount, harvestZone.maxAmount)
    
    -- Vérifier si le joueur peut porter l'item
    if xPlayer.canCarryItem(harvestZone.item, randomAmount) then
        xPlayer.addInventoryItem(harvestZone.item, randomAmount)
        
        -- Mettre à jour le compteur seulement si le système est activé
        if Config.HarvestSettings.enableMaxItemsLimit then
            playerHarvestCount[playerId][zoneId] = playerHarvestCount[playerId][zoneId] + randomAmount
            
            -- Calculer les items restants
            local remainingItems = harvestZone.maxItemsPerReboot - playerHarvestCount[playerId][zoneId]
            
            TriggerClientEvent('ESX:Notify', _source, "success", 5000, 
                'Vous avez récolté ' .. randomAmount .. ' ' .. harvestZone.label .. '. ' .. 
                'Items restants: ' .. remainingItems .. '/' .. harvestZone.maxItemsPerReboot)
        else
            TriggerClientEvent('ESX:Notify', _source, "success", 5000, 
                'Vous avez récolté ' .. randomAmount .. ' ' .. harvestZone.label .. '.')
        end
    else
        TriggerClientEvent('ESX:Notify', _source, "error", 5000, 
            'Vous ne pouvez pas porter plus de ' .. harvestZone.label .. '.')
        -- Arrêter la récolte automatique côté client
        TriggerClientEvent('jks_vigneron:stopHarvest', _source, zoneId, 'inventory_full')
    end
end)

-- Événement pour vérifier les limites d'un joueur
RegisterNetEvent('jks_vigneron:checkHarvestLimits')
AddEventHandler('jks_vigneron:checkHarvestLimits', function(zoneId)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then
        return
    end
    
    -- Trouver la zone de récolte
    local harvestZone = nil
    for _, zone in ipairs(Config.HarvestZones) do
        if zone.id == zoneId then
            harvestZone = zone
            break
        end
    end
    
    if harvestZone then
        if Config.HarvestSettings.enableMaxItemsLimit then
            local playerId = xPlayer.identifier
            local currentCount = playerHarvestCount[playerId] and playerHarvestCount[playerId][zoneId] or 0
            local remainingItems = harvestZone.maxItemsPerReboot - currentCount
            
            TriggerClientEvent('ESX:Notify', _source, "info", 5000, 
                'Limite de récolte: ' .. currentCount .. '/' .. harvestZone.maxItemsPerReboot .. 
                ' (' .. remainingItems .. ' restants)')
        else
            TriggerClientEvent('ESX:Notify', _source, "info", 5000, 
                'Système de limitation désactivé. Vous pouvez récolter sans limite.')
        end
    end
end)