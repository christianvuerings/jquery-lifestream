class MyActivities::MyFinAid

  def self.append!(uid, activities)
    finaid_proxy = MyfinaidProxy.new({user_id: uid})

    return unless finaid_proxy.lookup_student_id.present?
    return unless feed = finaid_proxy.get.try(:[], :body)
    begin
      content = Nokogiri::XML(feed, &:strict)
    rescue Nokogiri::XML::SyntaxError
      return
    end

    append_diagnostic!(content.css("DiagnosticData").css("Diagnostic"), activities)

  end

  private
  def self.append_diagnostic!(diagnostics, activities)
    diagnostics.each do |diagnostic|
      next unless can_show_diagnostic_category? diagnostic.css("Categories").css("Category")

      title = diagnostic.css("Message").text.strip
      url = diagnostic.css("URL").text.strip || ""
      summary = get_diagnostic_content diagnostic.css("Usage").css("Content")

      next unless (title.present? && summary.present?)

      activities <<  {
        id: '',
        title: title,
        summary: summary,
        source: "Financial Aid",
        type: "alert",
        date: "",
        source_url: url,
        emitter: "Financial Aid",
        color_class: "myfinaid-class"
      }
    end
  end

  def self.can_show_diagnostic_category?(category_collection)
    (category_collection.select { |category|
      category["Name"].strip == "CAT01" &&
        category.text.strip == "W"
    }).present?
  end

  def self.get_diagnostic_content(usage_collection)
    content_css = usage_collection.find { |content| content["Type"] == "TXT" }
    return content_css.text.strip if content_css
    ""
  end
end
