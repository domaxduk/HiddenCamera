# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'HiddenCamera' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HiddenCamera
  pod 'lottie-ios'
  pod 'RxSwift'
  pod 'RxCocoa'

  pod 'WebBrowser'
  pod 'RealmSwift'
  pod 'onnxruntime-objc', '~> 1.16.0'

  pod 'FirebaseAnalytics'
  pod 'FirebaseMessaging'
  pod 'Firebase/Crashlytics'
  pod 'SwiftyStoreKit'
  pod 'Google-Mobile-Ads-SDK'
  pod 'MarqueeLabel/Swift'
  pod 'FBSDKCoreKit'
end

post_install do |installer| 
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "14.0"
        if config.base_configuration_reference.is_a? Xcodeproj::Project::Object::PBXFileReference
          xcconfig_path = config.base_configuration_reference.real_path
          IO.write(xcconfig_path, IO.read(xcconfig_path).gsub("DT_TOOLCHAIN_DIR", "TOOLCHAIN_DIR"))
        end
      end
    end
  end