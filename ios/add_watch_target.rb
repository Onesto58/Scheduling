require 'xcodeproj'

# Percorso del progetto
project_path = 'ios/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 1. Configurazione Bundle IDs
ios_target_name = 'Runner'
ios_target = project.targets.find { |t| t.name == ios_target_name }
# Includiamo il Team ID visto nello screenshot per garantire la compatibilità
base_bundle_id = 'it.onesto58.scheduling.3B8967ULB4'
watch_bundle_id = "#{base_bundle_id}.watchkitapp"

# 2. Verifica se il target esiste già per evitare duplicati
if project.targets.find { |t| t.name == 'WatchApp' }
  puts "✅ WatchApp target già presente."
  exit 0
end

puts "🚀 Aggiunta target Apple Watch al progetto..."

# 3. Creazione del gruppo di file per la Watch App
watch_group = project.main_group.find_subpath('WatchApp', true)
watch_group.set_path('WatchApp')
watch_group.set_source_tree('<group>')

# Aggiunta dei file al gruppo (Info.plist deve esserci per essere trovato)
files_to_add = [
  'WatchApp.swift',
  'ContentView.swift',
  'WatchViewModel.swift'
].map do |name|
  watch_group.new_reference(name)
end

# Aggiungiamo il riferimento a Info.plist solo al gruppo, non alle fasi di build
watch_group.new_reference('Info.plist')

# 4. Creazione del target Watch App (SwiftUI)
watch_target = project.new_target(:application, 'WatchApp', :watchos, '9.0', nil, :swift)
watch_target.product_type = 'com.apple.product-type.application.watchapp2'

# Aggiunta dipendenza per garantire l'ordine di build
ios_target.add_dependency(watch_target)

# 5. Configurazione Build Settings per l'orologio
watch_target.build_configurations.each do |config|
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = watch_bundle_id
  config.build_settings['PRODUCT_NAME'] = 'WatchApp'
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['SKIP_INSTALL'] = 'YES'
  config.build_settings['WATCHOS_DEPLOYMENT_TARGET'] = '9.0'
  config.build_settings['SDKROOT'] = 'watchos'
  config.build_settings['TARGETED_DEVICE_FAMILY'] = '4' # 4 = Watch
  config.build_settings['INFOPLIST_FILE'] = 'WatchApp/Info.plist'
  config.build_settings['WATCH_PARENT_BUNDLE_ID'] = base_bundle_id
end

# 6. Aggiunta dei file alle fasi di build (solo sorgenti, no Info.plist)
watch_target.add_file_references(files_to_add)

# 7. Assicurarsi che l'app iOS includa la Watch App (Forzatura tramite Shell Script)
# Questo evita cicli di dipendenze e bug di embedding senza firma
ios_target.build_phases.delete_if { |p| p.display_name == 'Embed Watch Content' || p.display_name == 'Forza Embed Watch App' }

shell_script = <<-SHELL
DEST_DIR="${TARGET_BUILD_DIR}/${CONTENTS_FOLDER_PATH}/Watch"
mkdir -p "${DEST_DIR}"
cp -R "${BUILT_PRODUCTS_DIR}/WatchApp.app" "${DEST_DIR}/"
echo "✅ WatchApp.app copiata manualmente in ${DEST_DIR}"
SHELL

embed_phase = ios_target.new_shell_script_build_phase('Forza Embed Watch App')
embed_phase.shell_script = shell_script
embed_phase.show_env_vars_in_log = '1'

# 8. Salvataggio del progetto
project.save
puts "✨ Progetto Xcode aggiornato! Forzatura embedding Watch App configurata tramite Shell Script."
