# encoding: utf-8
class SakaiUserSitesProxy < SakaiProxy

  def site_url_prefix
    "#{Settings.sakai_proxy.host}/portal/site/"
  end

  def get_filtered_users_sites
    if (sakai_user_id = get_sakai_user_id)
      all_sites = SakaiData.get_users_sites(sakai_user_id)
      hidden_site_ids = SakaiData.get_hidden_site_ids(sakai_user_id)
      sites = all_sites.select do |site|
        !hidden_site_ids.include?(site['site_id']) &&
            ((site['type'] != 'course') || current_terms.include?(site['term']))
      end
      sites
    else
      []
    end
  end

  def get_categorized_sites
    if @fake
      return {"Spring 2013"=>
                  [{"id"=>"29fc31ae-ff14-419f-a132-5576cae2474e",
                    "title"=>"RUSSWIKI 2B Sp13",
                    "short_description"=>"Добро пожаловать в Русский 1!",
                    "description"=>
                        "<p>\n\t<strong>Знаете ли вы?</strong></p>\n<ul>\n\t<li>\n\t\tКузен Петра I был произведён в генералы только после смерти императора.</li>\n</ul>\n<p>\n\t&nbsp;</p>",
                    "url"=>
                        "https://sakai-dev.berkeley.edu/portal/site/29fc31ae-ff14-419f-a132-5576cae2474e"},
                   {"id"=>"45042d5d-9b88-43cf-a83a-464e1f0444fc",
                    "title"=>"MATH 1853 Sp13",
                    "short_description"=>"",
                    "description"=>
                        "<p>\n\tThe following work is not a republication of a former treatise by the Author, entitled, &ldquo;The Mathematical Analysis of Logic.&rdquo; Its earlier portion is indeed devoted to the same object, and it begins by establishing the same system of fundamental laws, but its methods are more general, and its range of applications far wider.</p>\n<p>\n\t&nbsp;</p>",
                    "url"=>
                        "https://sakai-dev.berkeley.edu/portal/site/45042d5d-9b88-43cf-a83a-464e1f0444fc"}],
              "Projects"=>
                  [{"id"=>"29d475ae-a1c1-493f-b721-fcfeebdb038d",
                    "title"=>"Digital Library Project",
                    "short_description"=>"",
                    "description"=>"",
                    "url"=>
                        "https://sakai-dev.berkeley.edu/portal/site/29d475ae-a1c1-493f-b721-fcfeebdb038d"}]}
    end
    self.class.fetch_from_cache @uid do
      categories = {}
      get_filtered_users_sites.each do |row|
        site = {}
        site_id = row['site_id']
        site['id'] = site_id
        site['title'] = row['title']
        site['short_description'] = row['short_desc']
        site['description'] = row['description']
        site['url'] = "#{site_url_prefix}#{site_id}"
        case row['type']
          when 'project'
            (categories['Projects'] ||= []) << site
          when 'course'
            term = row['term']
            (categories[term] ||= []) << site
        end
      end
      categories
    end
  end

end