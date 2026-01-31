fx_version 'adamant'
game 'gta5'

author 'Kiezys'
description '🍷 Système Vigneron ESX - Récolte, Fermentation, Mise en Bouteille & Système de Qualité'
version '2.6.0'
lua54 'yes'

-- Dépendances requises
dependencies {
    'es_extended',
    'ox_lib',
    'ox_inventory',
    'ox_target',
    'oxmysql',
    -- 'illenium-appearance'
}

shared_script {
    'shared/config.lua',
    'shared/utils.lua',
    '@ox_lib/init.lua',
    '@oxmysql/lib/MySQL.lua',
    '@es_extended/locale.lua',
}

client_scripts {
    'bridge/client/client.lua',
    'client/*.lua',
}

server_scripts {
    'bridge/server/server.lua',
    'server/*.lua',
}

--[[
╔══════════════════════════════════════════════════════════════════════════
║                              🍷 VIGNERON SYSTEM 🍷                      
║                                                                          
║  🌾 Récolte automatique/manuelle de raisins (rouges & blancs)           
║  🍇 Fermentation dans des cuves individuelles avec métadonnées          
║  🍾 Système de mise en bouteille avec qualité réaliste                  
║  📦 Stashes configurables avec ox_inventory                             
║  🛒 Système de commandes de tonneaux avec missions                      
║  🐛 Système de debug avancé avec niveaux                                 
║  ⚙️ Configuration complète et flexible                                    
║                                                                           
║                              Créé par Kiezys                              
║                           Version 2.6.0 - ESX                             
╚═══════════════════════════════════════════════════════════════════════════
]]