class MarkdownParser
    def initialize
      @html_content = []
      @mode = nil
      @list_depth = 0
    end
  
    def parse(content)
      content.each_line do |line|
        line = line.chomp
        parse_line(line)
      end
      
      # Clean up any open lists
      close_lists if @list_depth > 0
      @html_content.join("\n")
    end
  
    private
  
    def parse_line(line)
      return handle_code_block(line) if code_block?(line)
      return handle_raw_html(line) if @mode == :raw_html
      return handle_list(line) if list_line?(line)
      
      case line
      when /^(#{1,6})(?!#)/  # Headers
        level = $&.length
        text = line[level..].strip
        @html_content << "<h#{level}>#{text}</h#{level}>"
      when /^_(.+)/  # Special paragraph with border
        @html_content << "<p>#{$1}</p><div class='border'></div>"
      when /^\s*$/  # Empty line
        @html_content << "<br>"
      else  # Regular paragraph
        @html_content << "<p>#{line}</p>"
      end
    end
  
    def code_block?(line)
      line.start_with?('```')
    end
  
    def handle_code_block(line)
      line = line.delete_prefix('```')
      if @mode == :raw_html
        @mode = nil
      else
        @mode = :raw_html
      end
      @html_content << line unless line.empty?
    end
  
    def list_line?(line)
      line.start_with?('*') || line.start_with?('+')
    end
  
    def handle_list(line)
      if line.start_with?('+')
        @html_content << "<ul>"
        return
      end
  
      asterisk_count = line.count('*')
      text = line.delete_prefix('*' * asterisk_count).strip
  
      if @list_depth == 0
        @html_content << "<ul>"
      elsif asterisk_count > @list_depth
        (@list_depth...asterisk_count).each { @html_content << "<ul>" }
      elsif asterisk_count < @list_depth
        (@list_depth - asterisk_count).times { @html_content << "</ul>" }
      end
  
      @list_depth = asterisk_count
      @html_content << "<li>#{text}</li>"
    end
  
    def handle_raw_html(line)
      @html_content << line
    end
  
    def close_lists
      @list_depth.times { @html_content << "</ul>" }
      @list_depth = 0
    end
  end