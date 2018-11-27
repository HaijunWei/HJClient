Pod::Spec.new do |s|
  s.name         = "HJClient"
  s.version      = "0.0.1"
  s.summary      = "A short description of HJClient."
  s.homepage     = "https://github.com/HaijunWei/HJClient.git"
  s.license      = "MIT"
  s.author       = { "Haijun" => "whj929159021@hotmail.com" }
  s.source       = { :git => "https://github.com/HaijunWei/HJClient.git" }
  s.ios.deployment_target = "8.0"
  s.requires_arc = true
  s.default_subspec = 'Core'

  s.subspec 'Core' do |ss|
    ss.source_files = "Classes/*.{h,m}", "Classes/Request/*.{h,m}", "Classes/Response/*.{h,m}"
    ss.dependency "MJExtension"
    ss.dependency "AFNetworking"
  end

  s.subspec 'Plugins' do |ss|
    ss.source_files = "Classes/Plugins/**/*.{h,m}"
    ss.dependency "MBProgressHUD"
  end
end
