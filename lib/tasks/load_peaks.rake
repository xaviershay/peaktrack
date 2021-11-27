task load_peaks: :environment do

  Dir["data/regions/*.osm"].each do |filename|
    base = File.basename(filename, ".osm")
    tokens = base.split('-')
    id = tokens[0]

    attrs = {
      name: tokens[1..-1].map(&:titleize).join(' ')
    }

    region = begin
               Region.find(id).tap {|x| x.update!(attrs) }
             rescue ActiveRecord::RecordNotFound
               Region.create!(attrs.merge(id: id))
             end

    doc = Nokogiri.parse(File.read(filename))
    doc.xpath('//node').each do |node|
      id = node.attribute('id').value
      name_node = (
        node.xpath('tag[@k = "name"]').first ||
        node.xpath('tag[@k = "alt_name"]').first
      )
      next unless name_node
      attrs = {
        name: name_node.attribute("v").value,
        elevation: node.xpath('tag[@k = "ele"]').first.attribute("v").value.to_i,
        lat: node.attribute('lat').value.to_f,
        lon: node.attribute('lon').value.to_f
      }
      peak = begin
                Peak.find(id).tap {|p| p.update!(attrs) }
             rescue ActiveRecord::RecordNotFound
               Peak.create!(attrs.merge(id: id))
             end

      RegionPeak.find_or_create_by(
        region_id: region.id,
        peak_id: peak.id
      )
    end
    # TODO: Remove region peaks that no longer exist
    # TODO: Remove peaks not in any regions
  end
end
