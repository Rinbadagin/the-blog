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

  def generate_tree_from_article_list(article_list)
    root = ArticleNode.new(nil)
    article_list.each do |article|
      list = article.title.split("/")
      # root.add_child(ArticleNode.new(list[-1], link_to(list[-1], article_path(article)), article), list)
      root.add_child(ArticleNode.new(list[-1], link_to(list[-1], article_path(article)), article), list)
    end

    return root.render_html
  end
end
