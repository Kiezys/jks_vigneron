-- =============================================
-- Gestionnaire UI pour les informations de cuve avec ox_lib Context Menu
-- =============================================

DebugPrint("Initialisation du système UI des cuves")

local cuveContext = {
    isOpen = false,
    currentCuveId = nil,
    currentCuveData = nil
}

-- Fonction pour formater le temps
function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- Fonction pour créer les options du context menu selon l'état de la cuve
function createContextOptions(cuveData)
    DebugPrint("Création des options du context menu", {cuveId = cuveData.cuveId, isEmpty = cuveData.isEmpty})
    
    local options = {}
    
    -- Informations principales avec métadonnées
    if not cuveData.isEmpty and cuveData.grapesQuantity > 0 then
        -- Cuve en activité - utiliser les données formatées du serveur
        local depositDate = cuveData.formattedDepositDate or "Date inconnue"
        local wineVolume = math.round((cuveData.grapesQuantity * 0.7) * 10) / 10
        local currentTime = cuveData.serverTime or (GetGameTimer() / 1000)
        local elapsed = currentTime - cuveData.depositTime
        local remaining = math.max(0, cuveData.fermentationTime - elapsed)
        
        -- État de la fermentation
        local statusText = remaining <= 0 and '✅ Terminée' or '⏳ En cours'
        local statusColor = remaining <= 0 and 'green' or 'yellow'
        
        table.insert(options, {
            title = '**État de la Cuve**',
            description = 'Cuve ' .. cuveData.cuveId .. ' - ' .. statusText,
            icon = 'wine-bottle',
            iconColor = remaining <= 0 and '#28a745' or '#ffc107',
            metadata = {
                {label = 'Statut', value = statusText, colorScheme = statusColor},
                {label = 'Type', value = cuveData.grapeType == 'white' and 'Raisins blancs' or 'Raisins rouges'},
                {label = 'Grappes', value = cuveData.grapesQuantity .. ' grappes'},
                {label = 'Volume estimé', value = wineVolume .. ' hL'},
                {label = 'Déposé le', value = depositDate},
                {label = 'Millésime', value = cuveData.vintageYear or "2024"}
            }
        })
        
        -- Timer et progression
        if remaining > 0 then
            table.insert(options, {
                title = '**Fermentation**',
                description = 'Progression de la fermentation',
                icon = 'clock',
                iconColor = '#ffc107',
                metadata = {
                    {label = 'Fin prévue', value = cuveData.formattedEndDate or "Date inconnue"},
                    {label = 'Début', value = depositDate},
                    {label = 'Durée totale', value = formatTime(cuveData.fermentationTime)}
                }
            })
        else
            table.insert(options, {
                title = '**Fermentation Terminée**',
                description = 'Le vin est prêt à être récupéré',
                icon = 'check-circle',
                iconColor = '#28a745',
                metadata = {
                    {label = 'Statut', value = 'Prêt'},
                    {label = 'Durée totale', value = formatTime(cuveData.fermentationTime)},
                    {label = 'Terminé le', value = cuveData.formattedEndDate or "Date inconnue"}
                }
            })
        end
        
        -- Action pour récupérer le vin si terminé
        if remaining <= 0 then
            table.insert(options, {
                title = '**Récupérer le Vin**',
                description = 'Récupérer le vin fermenté avec un tonneau vide',
                icon = 'wine-bottle',
                iconColor = '#28a745',
                onSelect = function()
                    lib.hideContext()
                    retrieveWine(cuveData.cuveId)
                end,
                metadata = {
                    {label = 'Action', value = 'Récupération'},
                    {label = 'Nécessaire', value = 'Tonneau vide'},
                    {label = 'Produit', value = cuveData.grapeType == 'white' and 'Vin blanc' or 'Vin rouge'}
                }
            })
        end
        
    else
        -- Cuve vide
        table.insert(options, {
            title = '**Cuve Vide**',
            description = 'Aucune fermentation en cours',
            icon = 'circle',
            iconColor = '#6c757d',
            metadata = {
                {label = 'Statut', value = 'Arrêté'},
                {label = 'Température', value = '--'},
                {label = 'Volume', value = '0,0 hL'},
                {label = 'Millésime', value = '--'},
                {label = 'Grappes', value = '0'}
            }
        })
    end
    
    -- Option pour fermer le menu
    table.insert(options, {
        title = '**Fermer**',
        description = 'Fermer le menu des informations',
        icon = 'times',
        iconColor = '#dc3545',
        onSelect = function()
            lib.hideContext()
        end
    })
    
    return options
end

-- Fonction pour ouvrir le context menu avec les données de la cuve
function openCuveInfo(cuveData)
    DebugPrint("Ouverture du context menu cuve", {cuveId = cuveData.cuveId})
    
    cuveContext.currentCuveData = cuveData
    cuveContext.currentCuveId = cuveData.cuveId
    
    local contextOptions = createContextOptions(cuveData)
    
    -- Enregistrer le context menu
    lib.registerContext({
        id = 'cuve_info_context',
        title = '**Cuve de Fermentation - ' .. cuveData.cuveId .. '**',
        onExit = function()
            cuveContext.isOpen = false
            cuveContext.currentCuveId = nil
            cuveContext.currentCuveData = nil
        end,
        options = contextOptions
    })
    
    -- Afficher le context menu
    lib.showContext('cuve_info_context')
    cuveContext.isOpen = true
end

-- Fonction pour fermer le context menu
function closeCuveInfo()
    DebugPrint("Fermeture du context menu cuve")
    
    if cuveContext.isOpen then
        lib.hideContext()
        cuveContext.isOpen = false
        cuveContext.currentCuveId = nil
        cuveContext.currentCuveData = nil
    end
end

-- Fonction pour mettre à jour les données du context menu
function updateCuveInfo(cuveData)
    if cuveContext.isOpen and cuveContext.currentCuveId == cuveData.cuveId then
        cuveContext.currentCuveData = cuveData
        
        -- Recréer le context menu avec les nouvelles données
        local contextOptions = createContextOptions(cuveData)
        
        -- Réenregistrer le context menu avec les nouvelles options
        lib.registerContext({
            id = 'cuve_info_context',
            title = '**Cuve de Fermentation - ' .. cuveData.cuveId .. '**',
            onExit = function()
                cuveContext.isOpen = false
                cuveContext.currentCuveId = nil
                cuveContext.currentCuveData = nil
            end,
            options = contextOptions
        })
    end
end

-- Event handler pour recevoir les données du serveur
RegisterNetEvent('jks_vigneron:showCuveInfo')
AddEventHandler('jks_vigneron:showCuveInfo', function(cuveData)
    DebugPrint("Réception données cuve", {cuveId = cuveData.cuveId, isEmpty = cuveData.isEmpty})
    openCuveInfo(cuveData)
end)

-- Export des fonctions pour utilisation dans d'autres scripts
exports('openCuveInfo', openCuveInfo)
exports('closeCuveInfo', closeCuveInfo)
exports('updateCuveInfo', updateCuveInfo)