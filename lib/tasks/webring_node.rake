namespace :webring_node do
  desc "All tasks relating to webring nodes"
  task check_servers: :environment do
    nodes = WebringNode.all
    nodes.find_each do |node|
      begin
        response = HTTParty.get("http://#{node.site_link}/")
        if response.code > 300
          node.in_the_ring = false
        else
          node.in_the_ring = true
        end
        puts "Node info: link: #{node.site_link} in ring after check #{node.in_the_ring}"
      rescue StandardError => e
        puts "Error occured: #{e}"
        puts "Setting node #{node.id} #{node.site_link} to not in the ring"
        node.in_the_ring = false
      end
      node.save!
    end
  end
end
