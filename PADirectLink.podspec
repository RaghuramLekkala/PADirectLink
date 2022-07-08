#
#  Be sure to run `pod spec lint PADirectLink.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name         = "PADirectLink"
  spec.version      = "0.1.0"
  spec.summary      = "PADirectLink lets a user to integrate cosmopoliton chatbot feature."
  spec.requires_arc = true

  spec.homepage     = "https://github.com/RaghuramLekkala/PADirectLink"
 
  spec.license      = { :type => "MIT", :file => "MIT_LICENSE" }

  spec.author             = { "RaghuramLekkala" => "raghuram.lekkala@popcornapps.com" }

  spec.platform     = :ios, "12.0"

  spec.source       = { :git => "https://github.com/RaghuramLekkala/PADirectLink.git", :tag => "#{spec.version}" }


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  spec.framework  = "UIKit"
  spec.dependency  = "MessageKit"
  spec.dependency  = "IQKeyboardManagerSwift"

  spec.resources  = "PADirectLink/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

  spec.swift_version  = "5.3"

end
