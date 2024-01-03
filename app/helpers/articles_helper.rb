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
      else html_content += "<p>#{line}</p>"
      end
    end
    return html_content
  end

  def sidebar_tree_html(article_list)
    content = ""
    article_list.each do |article|
      content += "<li>#{link_to article.title, article}</li>"
    end
    return "<ul>#{content}</ul>"
  end
end
