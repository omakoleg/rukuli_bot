require 'rubygems'
require 'java'
require 'rukuli'

java_import 'org.sikuli.script.KeyModifier'
java_import 'org.sikuli.script.Key'

#export SIKULIX_HOME="/Users/maki/apps/sikuli/sikulix.jar"

IMAGES_PATH = "#{Dir.pwd}/web/"

Rukuli::Config.run do |config|
  config.image_path = IMAGES_PATH
  config.logging = false
end

class WebTest
  def run
    @screen = Rukuli::Screen.new 
    i_am_human(3)
    @screen.click(200, 74)
    @screen.enter('http://meetup.com')
    i_am_human(6)
    @screen.click(293, 45)
    i_am_human(4)
    @screen.click(560, 510)
    i_am_human(5)
    while !@screen.find!(img("spok"))
      @screen.wheel_down(5)
      sleep(0.1)
    end
    @screen.click(200, 74)
    @screen.enter("I ve found spok !!!! ")
  end
  
  def img(name)
    "#{IMAGES_PATH}/#{name}.png"
  end
  
  def i_am_human(time=nil)
    sleep(time || 1)
  end
  
end
WebTest.new.run