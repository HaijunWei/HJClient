Pod::Spec.new do |s|
  s.name         = "HJClient"
  s.version      = "0.0.1"
  s.summary      = "A short description of HJClient."
  s.homepage     = "https://github.com/HaijunWei/HJClient.git"
  s.license      = "MIT"
  s.author             = { "Haijun" => "whj929159021@hotmail.com" }
  s.source       = { :git => "https://github.com/HaijunWei/HJClient.git" }
  s.source_files  = "Classes/**/*.{h,m}"
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.dependency "MJExtension"
  s.dependency "AFNetworking"
end
