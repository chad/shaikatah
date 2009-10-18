require 'hotcocoa'

class Application

  include HotCocoa
  
  class MyView < NSView
    attr_reader :slides

    def acceptsFirstResponder; true; end
    def acceptsFirstMouse(*); true; end    
    
    def words=(words)
      self.slides = words.map do |word|
        text_layer_with(word)
      end
    end
    
    def slides=(slides)
      @slides = slides
      @current_slide = 0
      @slides.first.opacity = 1.0
      @slides.first.setHidden false
    end

    def keyDown(event)
      characters = event.characters      
      if characters.length == 1 && !event.isARepeat
        character = characters.characterAtIndex(0)
        character == NSLeftArrowFunctionKey ? on_previous_slide : on_next_slide
      end
    end

    private
    
      def on_next_slide
        NSAnimationContext.currentContext.setDuration 3.0
        slide = @slides[@current_slide]
        @current_slide += 1
        factor = rand(2) > 0 ? -5.0 : 10.0
        transform = CATransform3DMakeScale(factor, factor, factor)
        slide.setTransform transform
        slide.opacity = 0.0
        exit if @slides[@current_slide].nil?
        @slides[@current_slide].opacity = 1.0
      end
    
      def on_previous_slide
        return if on_first_slide?
        slide = @slides[@current_slide]
        slide.opacity = 0.0
        @current_slide -= 1
        @slides[@current_slide].position = text_starting_position
        @slides[@current_slide].opacity = 1.0
      end

      def random_color_code
        rand(100.0) * 0.01
      end

      def text_layer_with(word)
        screen_size = NSScreen.mainScreen.frame.size
        headerTextLayer = CATextLayer.layer
        headerTextLayer.name = "header"
        headerTextLayer.string = word
        headerTextLayer.foregroundColor = CGColorCreateGenericRGB(random_color_code, random_color_code, random_color_code, 1.0)
        headerTextLayer.style = {"font" => "BankGothic-Light","alignmentMode" => "center"}
        headerTextLayer.fontSize = 104
        headerTextLayer.wrapped = true
        headerTextLayer.opacity = 0.0
        headerTextLayer.frame = frame
        headerTextLayer.contentsGravity = "center"
        headerTextLayer.position = text_starting_position
        layer.addSublayer headerTextLayer
        headerTextLayer
      end
      
      def screen_size
        @screen_size ||= NSScreen.mainScreen.frame.size
      end
      
      def text_starting_position
        @text_starting_position ||= [(screen_size.width)/2, 100]
      end
      
      def on_first_slide?
        @current_slide == 0
      end
  end

  attr_reader :win
  
  def start
    application :name => "Shaikatah" do |app|
      app.delegate = self
      window frame: NSScreen.mainScreen.frame, title: "Shaikatah", styleMask:NSBorderlessWindowMask, defer:false, view: :nolayout do |win|
        @win = win
        win.view.setHidden true
        enable_main_and_key!
        win.will_close { exit }
      end
    end
  end
  
  
  def on_open(menu)
    dialog = NSOpenPanel.openPanel
    dialog.setCanChooseFiles true
    dialog.setCanChooseDirectories false
    if dialog.runModalForDirectory(nil, file: nil) == NSOKButton
      presentation_file = dialog.filenames.first
      words = IO.read(presentation_file).split(/\n/)
      setup_view_with! words
      go_full_screen!
    end
  end
  
  private
   
    def setup_view_with!(words)
      win.view = MyView.new
      win.view.wantsLayer = true
      win.setInitialFirstResponder(win.view)
      win.view.words = words
      win.view.layer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)
    end

    def enable_main_and_key!
      def win.canBecomeMainWindow
        true
      end
      def win.canBecomeKeyWindow
        true
      end
    end
    
    def go_full_screen!
      win.level = CGShieldingWindowLevel()
      win.makeKeyAndOrderFront(nil)
    end
end


Application.new.start