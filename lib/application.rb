require 'hotcocoa'

class Application

  include HotCocoa
  
  class MyView < NSView
    attr_reader :slides
    def initialize()
      
    end    
    def acceptsFirstResponder
      true
    end

    def acceptsFirstMouse(event)
      true
    end    

    def mouseDown(event)
      #@on_next_slide.call
    end

    def mouseUp(event)
    end
    
    def keyDown(event)
      characters = event.characters      
      if characters.length == 1# && !event.isARepeat
        character = characters.characterAtIndex(0)
        if character == NSLeftArrowFunctionKey
          @on_previous_slide.call
        else
          @on_next_slide.call
        end
      end
    end

    def keyUp(event)
    end
    
    def on_next_slide(&block)
      @on_next_slide = block
    end
    
    def on_previous_slide(&block)
      @on_previous_slide = block
    end
    
  end

  attr_reader :words, :win
  def initialize(*words)
    @words = words
  end

  
  def start
    application :name => "Sheeooot" do |app|
      app.delegate = self
      window frame: NSScreen.mainScreen.frame, title: "Prez", styleMask:NSBorderlessWindowMask, defer:false, view: :nolayout do |win|
        @win = win
        def win.canBecomeMainWindow
          true
        end
        def win.canBecomeKeyWindow
          true
        end
        win.view = MyView.new
        win.view.wantsLayer = true
        
        win.setInitialFirstResponder(win.view)
        
        slides = words.map do |word|
          text_layer_with(word)
        end
        
        slides.first.opacity = 1.0
        slides.first.setHidden false
        current_slide = 0
        win.view.layer.backgroundColor = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)

        win.view.on_next_slide do 
          NSAnimationContext.currentContext.setDuration 3.0
          slide = slides[current_slide]
          # slide.opacity = 0.0
          current_slide += 1
          factor = rand(2) > 0 ? -5.0 : 10.0
          transform = CATransform3DMakeScale(factor, factor, factor)
          slide.setTransform transform
          slide.opacity = 0.0
          
          exit if slides[current_slide].nil?
          slides[current_slide].opacity = 1.0
        end
        
        win.view.on_previous_slide do
          next if current_slide == 0
          
          slide = slides[current_slide]
          slide.opacity = 0.0
          current_slide -= 1
          slides[current_slide].opacity = 1.0
        end
        
        win.will_close { exit }
        win.level = CGShieldingWindowLevel()
        win.makeKeyAndOrderFront(nil)
      end
    end
  end

  def random_color_code
    rand(100.0) * 0.01
  end
  
  def text_layer_with(word)
    screen_size = NSScreen.mainScreen.frame.size
    headerTextLayer = CATextLayer.layer
    headerTextLayer.name = "header"
    headerTextLayer.setString  word
    random_color_code
    headerTextLayer.foregroundColor = CGColorCreateGenericRGB(random_color_code, random_color_code, random_color_code, 1.0)
    headerTextLayer.style = {"font" => "BankGothic-Light","alignmentMode" => "center"}
    headerTextLayer.fontSize = 104
    headerTextLayer.wrapped = true
    headerTextLayer.opacity = 0.0
    headerTextLayer.frame = win.view.frame#????
    headerTextLayer.contentsGravity = "center"
    screen_size = NSScreen.mainScreen.frame.size
    headerTextLayer.position = [(screen_size.width)/2, 100]
    win.view.layer.addSublayer headerTextLayer
    headerTextLayer
  end
  
end

def Takahashi!(*words)
  Application.new(*words).start  
end

Takahashi!("The Takahashi Method", 
          "One word or phrase per slide", 
          "Implemented in MacRuby", 
          "And Hot Cocoa", 
          "It's SO last year!!!"
          )