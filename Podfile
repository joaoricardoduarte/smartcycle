# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'
inhibit_all_warnings!

target 'smartcycle' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for SmartCycle
    pod 'SideMenu', '~> 3.0'
    pod 'DGActivityIndicatorView', '~> 2.1'
    pod 'SwiftyJSON', '~> 3.1'
    pod 'Cloudinary', '~> 2.0'
    pod 'GoogleAnalytics', '~> 3.17'
    pod 'ReachabilitySwift', '~> 3'
    pod 'UrbanAirship-iOS-SDK', '~> 8.6'

  target 'SmartCycleTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'SmartCycleUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

# Disable Code Coverage for Pods projects
post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
        end
    end
end

