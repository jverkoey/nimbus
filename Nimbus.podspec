Pod::Spec.new do |s|
  s.name         = "Nimbus"
  s.version      = "1.3.0"
  s.summary      = "The iOS framework that grows only as fast as its documentation"
  s.description  = <<-DESC
  Nimbus is an iOS framework whose feature set grows only as fast as its documentation. By focusing
  on documentation first and features second, Nimbus hopes to be a framework that accelerates the
  development process of any application by being easy to use and simple to understand.
                   DESC
  s.homepage     = "http://nimbuskit.info"
  s.license      = "Apache License, Version 2.0"
  s.authors            = {
    "Jeff Verkoeyen" => "jverkoey@gmail.com",
    "Bubnov Slavik" => "bubnovslavik@gmail.com",
    "Roger Chapman" => "rogchap@gmail.com",
    "Manu Cornet" => "manu.cornet@gmail.com",
    "Glenn Grant" => "glenn@ensquared.net",
    "Aviel Lazar" => "aviellazar@gmail.com",
    "Benedikt Meurer" => "benedikt.meurer@googlemail.com",
    "Anderson Miller" => "anderson@submarinerich.com",
    "Basil Shkara" => "basil@neat.io",
    "Peter Steinberger" => "me@petersteinberger.com",
    "Hwee-Boon Yar" => "hboon@motionobj.com",
    "Stephane Moore" => "stephane.moore@gmail.com"
  }
  s.social_media_url   = "http://twitter.com/NimbusKit"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/jverkoey/nimbus.git", :tag => s.version }
  s.requires_arc = true

  s.subspec 'AttributedLabel' do |ss|
    ss.source_files = 'src/attributedlabel/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'Core' do |ss|
    ss.source_files = 'src/core/src'
  end

  s.subspec 'Badge' do |ss|
    ss.source_files = 'src/badge/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'Collections' do |ss|
    ss.source_files = 'src/collections/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'CSS' do |ss|
    ss.source_files = 'src/css/src'
    ss.dependency 'Nimbus/Core'
    ss.dependency 'Nimbus/Textfield'
    ss.dependency 'AFNetworking', '~> 2.6'
  end

  s.subspec 'Interapp' do |ss|
    ss.source_files = 'src/interapp/src'
    ss.dependency 'Nimbus/Core'
    ss.framework = 'CoreLocation'
  end

  s.subspec 'Launcher' do |ss|
    ss.source_files = 'src/launcher/src'
    ss.dependency 'Nimbus/Core'
    ss.dependency 'Nimbus/PagingScrollView'
  end

  s.subspec 'Models' do |ss|
    ss.source_files = 'src/models/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'NetworkControllers' do |ss|
    ss.source_files = 'src/networkcontrollers/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'NetworkImage' do |ss|
    ss.source_files = 'src/networkimage/src'
    ss.dependency 'Nimbus/Core'
    ss.dependency 'AFNetworking', '~> 2.6'
  end

  s.subspec 'Overview' do |ss|
    ss.source_files = 'src/overview/src'
    ss.dependency 'Nimbus/Core'
    ss.dependency 'Nimbus/Models'
    s.resource_bundles = {
      'Overview' => ['src/overview/resources/NimbusOverviewer.bundle/*']
    }
  end

  s.subspec 'PagingScrollView' do |ss|
    ss.source_files = 'src/pagingscrollview/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'Photos' do |ss|
    ss.source_files = 'src/photos/src'
    ss.dependency 'Nimbus/Core'
    ss.dependency 'Nimbus/PagingScrollView'
  end

  s.subspec 'Textfield' do |ss|
    ss.source_files = 'src/textfield/src'
    ss.dependency 'Nimbus/Core'
  end

  s.subspec 'WebController' do |ss|
    ss.source_files = 'src/webcontroller/src'
    ss.dependency 'Nimbus/Core'
    s.resource_bundles = {
      'WebController' => ['src/webcontroller/resources/NimbusWebController.bundle/*']
    }
  end
end
