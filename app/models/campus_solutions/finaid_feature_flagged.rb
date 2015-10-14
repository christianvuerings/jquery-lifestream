module CampusSolutions
  module FinaidFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_fin_aid
    end
  end
end
