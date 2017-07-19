source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '10.0'
use_frameworks!
target "liferay-test" do
	pod 'SwiftSoup'
	pod 'libCommonCrypto'
	pod 'Toast-Swift', '~> 2.0.0'
end

post_install do |installer|
  installer.pods_project.build_configuration_list.build_configurations.each do |configuration|
    configuration.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
  end
end
