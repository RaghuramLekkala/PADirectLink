Pod::Spec.new do |spec|

  spec.name         = "PADirectLink"
  spec.platform     = :ios
  spec.ios.deployment_target = '13.0'
  spec.version      = "0.1.0"
  spec.summary      = "PADirectLink lets a user to integrate cosmopoliton chatbot feature."
  spec.requires_arc = true
 
  spec.license      = { :type => "MIT", :file => "MIT_LICENSE" }

  spec.author       = { "RaghuramLekkala" => "raghuram.lekkala@popcornapps.com" }

  spec.homepage     = "https://github.com/RaghuramLekkala/PADirectLink"
  
  spec.source       = { :git => "https://github.com/RaghuramLekkala/PADirectLink.git", :tag => spec.version.to_s }


  spec.framework  = "UIKit"
  spec.dependency  'MessageKit', '~> 3.8.0'
  spec.dependency 'IQKeyboardManagerSwift', '~> 6.5.10'

  spec.source_files = "PADirectLink/**/*.{swift}"
  spec.resources  = "PADirectLink/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  spec.swift_version  = "5.3"

end
