module Canvas
  class SectionsReport < Canvas::Report

    def initialize(options = {})
      super options
    end

    def get_csv(term_id)
      get_provisioning_csv('sections', term_id)
    end

  end
end
