require 'rexml/document'

class SakaiData < OracleDatabase

  def self.table_prefix
    Settings.campusdb.bspace_prefix || ''
  end

  def self.get_hidden_site_ids(sakai_user_id)
    sites = []
    sql = <<-SQL
    select xml from #{table_prefix}sakai_preferences
      where preferences_id = #{connection.quote(sakai_user_id)}
    SQL
    if (xml = connection.select_one(sql))
      xml = REXML::Document.new(xml['xml'])
      xml.elements.each('preferences/prefs/properties/property[@name="exclude"]') do |el|
        sites.push(Base64.decode64(el.attributes['value']))
      end
    end
    sites
  end

  # TODO This query can be cached forever, more or less.
  def self.get_sakai_user_id(person_id)
    sql = <<-SQL
    select user_id from #{table_prefix}sakai_user_id_map
      where eid = #{connection.quote(person_id)}
    SQL
    if (user_id = connection.select_one(sql))
      user_id = user_id['user_id']
    end
    user_id
  end

  def self.get_site(site_id)
    sql = <<-SQL
    select site_id, title, type, published from #{table_prefix}sakai_site where site_id = #{connection.quote(site_id)}
    SQL
    connection.select_one(sql)
  end

  # Only returns published Course and Project sites, not special sites like the user's dashboard or the administrative workspace.
  def self.get_users_sites(sakai_user_id)
    sql = <<-SQL
    select s.site_id, s.type, s.title, s.short_desc, s.description, sp.value as term
    from #{table_prefix}sakai_site s join #{table_prefix}sakai_site_user su on
      su.user_id = #{connection.quote(sakai_user_id)} and su.site_id = s.site_id and s.published = 1 and s.type in ('course', 'project')
      left outer join #{table_prefix}sakai_site_property sp on s.site_id = sp.site_id and sp.name = 'term'
    SQL
    connection.select_all(sql)
  end

end