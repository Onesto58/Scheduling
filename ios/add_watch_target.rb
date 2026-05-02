require 'xcodeproj'

# Percorso del progetto
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Configurazione Bundle IDs
ios_target_name = 'Runner'
ios_target = project.targets.find { |t| t.name == ios_target_name }
base_bundle_id = 'it.onesto58.scheduling'
watch_bundle_id = "#{base_bundle_id}.watchkitapp"

# 2. Verifica se il target esiste già per evitare duplicati
if project.targets.find { |t| t.name == 'WatchApp' }
  puts "✅ WatchApp target già presente."
  exit 0
end

puts "🚀 Aggiunta target Apple Watch al progetto..."

# 3. Creazione del gruppo di file per la Watch App
watch_group = project.main_group.find_subpath('WatchApp', true)
watch_group.set_source_tree('<group>')

# Aggiunta dei file al gruppo
file_paths = [
  'ios/WatchApp/WatchApp.swift',
  'ios/WatchApp/ContentView.swift',
  'ios/WatchApp/WatchViewModel.swift'
]

files = file_paths.map do |path|
  watch_group.new_reference(File.basename(path))
end

# 4. Creazione del target Watch App (SwiftUI)
watch_target = project.new_target(:watch2_app, 'WatchApp', :watchos, '9.0', nil, :swift)
watch_target.product_type = 'com.apple.product-type.application'

# Aggiunta dipendenza
ios_target.add_dependency(watch_target)

# 5. Configurazione Build Settings per l'orologio
watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = watch_bundle_id
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
  config.build_settings['SDKROOT'] = 'watchos'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4' # 4 = Watch
  config.build_settings['INFOPLIST_KEY_CFBundleDisplayName'] = 'Scheduling'
  config.build_settings['INFOPLIST_KEY_WKCompanionAppBundleIdentifier'] = base_bundle_id
  config.build_settings['GENERATE_INFOPLIST_FILE'] = 'YES'
end

# 6. Aggiunta dei file al target
watch_target.add_file_references(files)

# 7. Assicurarsi che l'app iOS includa la Watch App
embed_watch_app_phase = ios_target.copy_files_build_phases.find { |p| p.name == 'Embed Watch Content' } || 
                        ios_target.new_copy_files_build_phase('Embed Watch Content')
embed_watch_app_phase.symbol_dst_subfolder_spec = :watch_apps
embed_watch_app_phase.add_file_reference(watch_target.product_reference)

# 8. Salvataggio del progetto
project.save
puts "✨ Progetto Xcode aggiornato con successo!"
