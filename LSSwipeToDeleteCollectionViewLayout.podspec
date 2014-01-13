#
# Be sure to run `pod spec lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about the attributes see http://docs.cocoapods.org/specification.html
#
Pod::Spec.new do |s|
  s.name         = "LSSwipeToDeleteCollectionViewLayout"
  s.version      = "0.1.0"
  s.summary      = "The UICollectionViewLayout subclass adds swipe to delete functionality to a collectionview"
  s.description  = <<-DESC
                    An optional longer description of LSSwipeToDeleteCollectionViewLayout

                    * Markdown format.
                    * Don't worry about the indent, we strip it!
                   DESC
  s.homepage     = "http://EXAMPLE/NAME"
  s.screenshots  = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license      = 'MIT'
  s.author       = { "Lukman Sanusi" => "lanresanusi@me.com" }
  s.source       = { :git => "http://EXAMPLE/NAME.git", :tag => s.version.to_s }

  # s.platform     = :ios, '5.0'
  s.requires_arc = true

  s.source_files = 'Classes'

  # s.public_header_files = 'Classes/**/*.h'
end
