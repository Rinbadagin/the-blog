module ArticlesHelper
  def process_body(article)
    html_content = ""
    first_pass = ""
    temp_content = ""
    mode = nil
    article.body.each_line do |line|
      if line.include?("![") && line.include?(']') && line.split("![")[1].split("]")[0]
        #get content between first ![ and ]
        up = Upload.find_by(title: line.split("![")[1].split("]")[0])
        if up
          url = url_for(Upload.find_by(title: line.split("![")[1].split("]")[0]).content)
          temp_content += "#{line.split("![")[0]}#{url || "Couldn't find link" }#{line.split("]")[1..].join}"
        else 
          temp_content += "#{line.split("![")[0]}![Couldn't find link]#{line.split("]")[1..].join}"
        end
      else
        temp_content += line
      end
    end
    temp_content.each_line do |line|
      if line.starts_with? "```"
        line = line.delete_prefix "```"
        if mode == :raw_html
          mode = nil
        else
          mode = :raw_html
        end
      end
      if mode == :raw_html
        html_content += line
      else
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
    end
    return html_content
  end

  def generate_tree_from_article_list(article_list, current_article)
    root = ArticleNode.new(nil)
    article_list.each do |article|
      list = article.title.split("/")
      if (article == current_article)
        if !article.visibility
          link = link_to(list[-1], article_path(article), id: "current-article-link", class: "hidden-article", article_id: article.id)
        else
          link = link_to(list[-1], article_path(article), id: "current-article-link", class: "visible-article", article_id: article.id)
        end
      else
        if !article.visibility
          link = link_to(list[-1], article_path(article), class: "hidden-article", article_id: article.id)
        else
          link = link_to(list[-1], article_path(article), class: "visible-article", article_id: article.id)
        end
      end
      if article.visibility || current_user
        root.add_child(ArticleNode.new(list[-1], link, article), list)
      end
    end

    return root.render_html
  end
end
