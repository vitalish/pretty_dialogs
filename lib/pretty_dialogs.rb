# PrettyDialogs
module PrettyDialogHelper
  
  def pretty_dialog(options, &block)
    if options[:corporate_data]
      content2 = options[:corporate_data].content
      options[:title] = options[:corporate_data].title
    end
    builder = ('PrettyDialogHelper::' + (options[:builder] || 'PrettyDialogBuilder')).constantize.new(options)
    
    builder_binding = block.binding
    
    # builder_binding = OpenStruct.new(:builder => builder).instance_eval { binding }
    # lambda { |a_builder| dialog_builder = a_builder}.call(builder, builder_binding)
    
    eval("dialog_builder = ObjectSpace._id2ref " + builder.object_id.to_s, builder_binding)
    content2 = ERB.new(content2).result(builder_binding) if content2
    
    content = capture(builder,&block)
    concat builder.dialog_begin
    concat builder.dialog_title 
    concat(content)
    concat(content2) if content2
    concat builder.dialog_end
  end
  
  def self.pretty_button(name, options = {})
    prefix     = options[:prefix] ? options[:prefix] + "_" : ""
    attr_name  = options[:text] || name.to_s.capitalize
    attr_id    = options[:id]   || (prefix + name.to_s)
    attr_href  = options[:href] || "#"
    attr_class = options[:button_class] || "button" + " " + options[:class].to_s

    %Q(<a id="#{attr_id}" class="#{attr_class}" href="#{attr_href}">#{attr_name}</a>)
  end
  
  class PrettyDialogBuilder
    def initialize(options)
      @options = options
      @buttons = ''
    end
    
    def set_width(value)
      #TODO refactor
      @options[:style]= @options[:style].gsub(/width:\s*\w*(;|$)/,'')
      @options[:style]= @options[:style]+"width:#{value};"
    end
    
    def button(name, options = {})
      options[:prefix] = @options[:id]
      @buttons << PrettyDialogHelper::pretty_button(name, options)
      ''
    end
    
    def button_separator(name, options = {})
      attr_class = "button-separator" + " " + options[:class].to_s
      attr_style = @options[:style] ? %Q( style="#{@options[:style]}") : ""
      @buttons << %Q(<span class="#{attr_class}"#{attr_style}>#{@options[:text]}</span>)
      ''
    end
    
    def inline_button(name, options = {})
      options[:prefix] = @options[:id]
      pretty_button(name, options)
    end

    def dialog_begin
      %Q(<div class="pretty-dialog #{@options[:class]}" style="cursor: default; #{@options[:style]}" #{'id="' + @options[:id] + '"' if @options[:id]} >)
    end

    def dialog_title
      %Q(
          <a class="close" href="#">&times;</a>
          <h2 class="caption">#{@options[:title]}</h2>
          <div class="body">)
    end
    
    def dialog_end
      %Q(          
          </div>) + ( @buttons == '' ? '' : %Q(
          <div class="buttons">
                #{ @buttons }
          </div> ) ) + %Q(
        </div>)
    end
  end
  
  class UglyDialogBuilder
    
    def initialize(options)
      @options = options
    end
       
    def button(name, options = {})
      %Q(<div id="#{@options[:id]+'_'+name.to_s}" class="btn #{options[:class]}"><a href="#">#{name.to_s.capitalize}</a></div>)
    end
    
    alias_method  :inline_button, :button

    def dialog_begin
      %Q(<div class="vi-dialog" style="cursor: default; #{@options[:style]}" #{'id="' + @options[:id] + '"' if @options[:id]} >)
    end

    def dialog_title
      %Q(
        	   <div class="vi-dialog-titlebar">
        	      <span id="vi-dialog-title-dialog" class="vi-dialog-title">#{@options[:title]}</span>
        	      <a class="vi-dialog-titlebar-close close_dialog-button" href="#">
        						<span class="vi-icon vi-icon-closethick"></span>
        				</a>
        	   </div>
        	   <div class="vi-dialog-content vi-widget-content">)
    end
    
    def dialog_end
      %Q(          
        	  </div>
          </div>)
    end
  end
  
end
