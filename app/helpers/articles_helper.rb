module ArticlesHelper
  def process_body(article)
    html_content = ""
    article.body.each_line do |line|
      if line.starts_with? "######"
        html_content += "<h6>#{line.delete_prefix "######"}</h6>"
      elsif line.starts_with? "#####"
        html_content += "<h5>#{line.delete_prefix "#####"}</h5>"
      elsif line.starts_with? "####"
        html_content += "<h4>#{line.delete_prefix "####"}</h4>"
      elsif line.starts_with? "###"
        html_content += "<h3>#{line.delete_prefix "###"}</h3>"
      elsif line.starts_with? "##"
        html_content += "<h2>#{line.delete_prefix "##"}</h2>"
      elsif line.starts_with? "#"
        html_content += "<h1>#{line.delete_prefix "#"}</h1>"
      elsif line.starts_with? "*"
        html_content += "<ul><li>#{line.delete_prefix "*"}</li></ul>"
      elsif line.starts_with? "_"
        html_content += "<p>#{line.delete_prefix "_"}</p><div class='border'></div>"
      elsif line.equal? ""
        html_content += "<br>"
      else html_content += "<p>#{line}</p>"
      end
    end
    return html_content
  end

  def sidebar_tree_html(article_list)
    content = ""
    article_list.each do |article|
      # Explicit handling of article id 1 should probably not happen - why is this a special case?
      # ID 1 is the index post - perhaps we could handle this differently in the future?
      if article.id != 1
        if article.title.starts_with? "Special/"
          content += "<li>#{link_to article.title.delete_prefix("Special/"), article}</li>"
        else
          content += "<li>#{link_to article.title, article}</li>"
        end
      else 
        content += "<li>#{link_to article.title.delete_prefix("Special/"), root_path}</li>"
      end
    end
    return "<ul>#{content}</ul>"
  end
end
