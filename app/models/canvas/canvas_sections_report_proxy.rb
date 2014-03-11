module Canvas
  class CanvasSectionsReportProxy < Canvas::CanvasReportProxy

    def get_csv(term_id)
      get_provisioning_csv('sections', term_id)
    end

  end
end
