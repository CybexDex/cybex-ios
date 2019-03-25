# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

def parse_KV_file(file, separator='=')
  file_abs_path = File.expand_path(file)
  if !File.exists? file_abs_path
    return [];
  end
  pods_ary = []
  skip_line_start_symbols = ["#", "/"]
  File.foreach(file_abs_path) { |line|
    next if skip_line_start_symbols.any? { |symbol| line =~ /^\s*#{symbol}/ }
    plugin = line.split(pattern=separator)
    if plugin.length == 2
      podname = plugin[0].strip()
      path = plugin[1].strip()
      podpath = File.expand_path("#{path}", file_abs_path)
      pods_ary.push({:name => podname, :path => podpath});
      else
      puts "Invalid plugin specification: #{line}"
    end
  }
  return pods_ary
end

target 'ChatRoom' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ChatRoom

end

target 'cybexMobile' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for cybexMobile

    pod 'coswift'

    system('rm -rf .symlinks')
    system('mkdir -p .symlinks/plugins')

    # Flutter Pods
    generated_xcode_build_settings = parse_KV_file('./Flutter/Generated.xcconfig')
    if generated_xcode_build_settings.empty?
      puts "Generated.xcconfig must exist. If you're running pod install manually, make sure flutter packages get is executed first."
    end
    generated_xcode_build_settings.map { |p|
      if p[:name] == 'FLUTTER_FRAMEWORK_DIR'
        symlink = File.join('.symlinks', 'flutter')
        File.symlink(File.dirname(p[:path]), symlink)
        pod 'Flutter', :path => File.join(symlink, File.basename(p[:path]))
      end
    }

    #  pod 'flutter_boost', :path => '../../ios'
    #  pod 'xservice_kit', :path => '.symlinks/plugins/xservice_kit/ios'

    # Plugin Pods
    plugin_pods = parse_KV_file('../cybex_flutter/.flutter-plugins')
    plugin_pods.map { |p|
      symlink = File.join('.symlinks', 'plugins', p[:name])
      File.symlink(p[:path], symlink)
      pod p[:name], :path => File.join(p[:path], 'ios')
    }


  target 'cybexMobileTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
