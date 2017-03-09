#
# Be sure to run `pod lib lint GTFSStationsParis.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GTFSStationsParis'
  s.version          = '0.0.3'
  s.summary          = 'This pod parses a sqlite db of gtfs data into station objects and peripheral models.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This pod parses a sqlite db of gtfs data into station objects and peripheral models.
                       DESC

  s.homepage         = 'https://github.com/schrockblock/gtfs-stations-paris'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Elliot' => 'ephherd@gmail.com' }
  s.source           = { :git => 'https://github.com/schrockblock/gtfs-stations-paris.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/schrockblock'

  s.ios.deployment_target = '8.0'

  s.source_files = 'GTFSStationsParis/Classes/**/*'

  s.dependency 'SQLite.swift'
  s.dependency 'SubwayStations'
end
