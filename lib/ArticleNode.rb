class ArticleNode 
  attr_reader :leaf_name, :link, :article, :children

  def initialize(leaf_name, link=nil, article=nil)
    @leaf_name = leaf_name
    @link = link
    @article = article
    @children = {}
  end

  def get_child(name_downward)
    return self if name_downward.length == 1 && name_downward[0] == @leaf_name
    return nil if name_downward[0] != @leaf_name
    @children.each do |child|
      response = child.get_child name[1...]
      return response if response
    end
  end

  def add_child(node, name_downward)
    if name_downward.length == 1
      @children[name_downward[0]] = node
    else
      if @children[name_downward[0]]
        @children[name_downward[0]].add_child node, name_downward[1...]
      else
        @children[name_downward[0]] = ArticleNode.new(name_downward[0])
        @children[name_downward[0]].add_child node, name_downward[1...]
      end
    end
  end

  def add_article_to_self(link, article)
    if !@article
      @article = article 
    end
    if !@link
      @link = link 
    end
  end

  def render_html
    # This should handle duplicate article names gracefully. Check article id & such
    content = ""
    if @children.length >= 1
      flag_close_details = nil
      if @link
        flag_close_details = true
        content += "<details id=\"article-sidebar-details-#{@article.id}\"><summary>#{@link}</summary><ul>"
      elsif @leaf_name
        flag_close_details = true
        # there is a potential intersection here. two articles which swap name or have the same leaf name will be opened
        # if we keep them open by id
        content += "<details id=\"article-sidebar-details-#{@leaf_name}\"><summary>#{@leaf_name}</summary><ul>"
      end
      @children.each do |key_child_pair|
        content += "#{key_child_pair[1].render_html}"
      end
      content += "</ul>#{flag_close_details ? '</details>' : ''}"
    elsif @link
      content = "<li>#{@link}</li>"
    else
      content = "<li>#{@leaf_name}</li>"
    end
    return content
  end
end