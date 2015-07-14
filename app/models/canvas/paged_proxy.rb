module Canvas
  module PagedProxy

    def mock_paged_interaction(fixture_name)
      on_request(mock_request).set_response do |request|
        page_requested = request.uri.query_values['page'] || '1'
        pages = Dir.glob Rails.root.join('fixtures', 'json', "#{fixture_name}_page_*")
        if page_requested.to_i <= pages.count
          {
            body: read_file('fixtures', 'json', "#{fixture_name}_page_#{page_requested}.json"),
            headers: {'link' => paging_header(request, page_requested.to_i, pages)}
          }
        end
      end
    end

    def paging_header(request, page_requested, pages)
      link_header = {
        current: request.uri.dup,
        first: request.uri.dup,
        last: request.uri.dup
      }
      link_header[:current].query_values = request.uri.query_values.merge('page' => page_requested.to_s)
      link_header[:first].query_values = request.uri.query_values.merge('page' => '1')
      link_header[:last].query_values = request.uri.query_values.merge('page' => pages.count.to_s)
      if page_requested > 1
        link_header[:prev] = request.uri.dup
        link_header[:prev].query_values = request.uri.query_values.merge('page' => (page_requested - 1).to_s)
      end
      if page_requested < pages.count
        link_header[:next] = request.uri.dup
        link_header[:next].query_values = request.uri.query_values.merge('page' => (page_requested + 1).to_s)
      end
      link_header.map{|rel, url| "<#{url}>; rel=\"#{rel}\""}.join(',')
    end

  end
end
