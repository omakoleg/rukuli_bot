require 'rubygems'
require 'java'
require 'rukuli'

java_import 'org.sikuli.script.KeyModifier'
java_import 'org.sikuli.script.Key'

#export SIKULIX_HOME="/Users/maki/apps/sikuli/sikulix.jar"

IMAGES_PATH = "#{Dir.pwd}/images/"

Rukuli::Config.run do |config|
  config.image_path = IMAGES_PATH
  config.logging = false
end

module Rukuli
  module Clickable
    def click_image_drag_and_drop(filename, filename_drop_to)
      begin
        pattern = org.sikuli.script::Pattern.new(filename).similar(0.9)
        @java_obj.hover(pattern)
        @java_obj.mouseDown(java.awt.event.InputEvent::BUTTON1_MASK)
        pattern_to = org.sikuli.script::Pattern.new(filename_drop_to).similar(0.9)
        @java_obj.hover(pattern_to)
        sleep(0.1)
        @java_obj.mouseUp(0)
      rescue NativeException => e
        raise_exception e, filename
      end
    end
  end
end

module Rukuli
  KEY_F1   = Key::F1
  KEY_F2   = Key::F2
end

module Rukuli
  module Typeable
    def press_key(keycode)
      @java_obj.type(keycode)
    end
  end
end

class Eve
  def initialize
    @screen = Rukuli::Screen.new 
    @image_path = IMAGES_PATH
    @ores = [
      'concentrated_veldspar', 
      'condensed_scordite', 
      'dense_veldspar', 
      'scordite', 
      'veldspar',
      'massive_scordite'
    ]
  end
  
  def get_rnd_coord(ranges_array)
    [Random.new.rand(ranges_array[0]), Random.new.rand(ranges_array[1])]
  end
  
  def rnd(range)
    Random.new.rand(range)
  end
  
  def img(name)
    "#{@image_path}/#{name}.png"
  end
    
  def click_coord(range)
    x = rnd(range[0])
    y = rnd(range[1])
    @screen.click(x, y)
  end
  
  def i_am_human(time=nil)
    sleep(Random.new.rand(time || 1))
  end
  
  # Ensure notes window opened / closed 
  def check_notes_window
    return if @screen.find!(img('notepad/notes_window'))
    i_am_human(0.1)
    @screen.click(img('notepad/icon_notes'))
  end
  
  def message(message)
    check_notes_window
    @screen.click(img('notepad/notes_window'))
    @screen.enter("-> #{message}")
  end
  
  def set_application
    @screen.wait(img('eve_window'), 3)
    i_am_human
    @screen.click(img('eve_window'))
  end
  
  def exit_station
    message "Exit station"
    i_am_human
    @screen.click(img('station_exit'))
    @screen.wait(img('powergrid'), 10)
  end
  
  def warp_to_asteroids
    message "Warp to asteroids"
    open_address_panel
    @screen.right_click(img('address/bookmark_asteroid'))
    i_am_human
    @screen.click(img('address/warp_zero'))
    close_address_panel
  end
  
  def open_address_panel
    message "Open address Panel" 
    while !@screen.find!(img('address/is_opened'))
      @screen.click(img('address/icon'))
    end
  end
  
  def close_address_panel
    message "Close address Panel"
    # this is a ingame magic
    @screen.click(img('address/icon'))
    @screen.click(img('address/icon'))
    i_am_human
  end
  
  RUNS = 2
  ASTEROIDS = 1
  
  def run
    set_application
    RUNS.times do
      message "Run started"
      exit_station
      warp_to_asteroids
      wait_asteroids
      # loop here
      ASTEROIDS.times do
        approach_asteroid_and_lock
        i_am_human(10..20) # approach asteroid, speed depending
        activate_miners
        i_am_human(60..70) # could be bigger
        unlock_target
      end
      return_to_station
      wait_station
      show_ship_ore_bay
      move_ore_to_hangar
    end
    message "End"
  end
  
  def wait_asteroids
    message "Wait asteroids"
    @screen.wait(img('asteroids/is_reached'), 30)
  end
  
  LOCK_UNLOCK_COORD = [1043..1067, 110..130]
  COORD_ORBIT = [975..1000, 110..130]
  COORD_FIRST_LOCKED_TARGET = [744..798, 110..130]
  
  def approach_asteroid_and_lock
    message "Approach asteroid and lock"
    @screen.click(img('asteroids/is_reached'))
    while !@screen.find!(img('asteroids/is_target_locked'))
      i_am_human
      click_coord(COORD_ORBIT)
      click_coord(LOCK_UNLOCK_COORD)
      i_am_human(4)
    end
  end
  
  def activate_miners
    message "Try miners on"
    @screen.press_key(Rukuli::KEY_F1)
    # @screen.press_key(Rukuli::KEY_F2)
  end
  
  def unlock_target
    message "Unlock target"
    @screen.click(*get_rnd_coord(COORD_FIRST_LOCKED_TARGET))
    click_coord(LOCK_UNLOCK_COORD)
    i_am_human(2)
  end
  
  def return_to_station
    message "Return to station"
    open_address_panel
    @screen.right_click(img('address/bookmark_station'))
    i_am_human
    @screen.click(img('address/dock'))
    close_address_panel
  end
  
  def wait_station
    message "Wait station"
    @screen.wait(img('station_exit'), 200)
    i_am_human(3..5) # wait interface
  end
  
  def show_ship_ore_bay
    message "Show ship ore bay"
    @screen.click(img('hangar/icon_ship'))
  end
  
  def move_ore_to_hangar
    @ores.each do |ore|
      message "Try to move #{ore}"
      if @screen.find!(img("ore/#{ore}"))
        @screen.click_image_drag_and_drop(img("ore/#{ore}"), img('hangar/icon_station'))
      end
    end
  end
  
end

eve  = Eve.new
eve.run
