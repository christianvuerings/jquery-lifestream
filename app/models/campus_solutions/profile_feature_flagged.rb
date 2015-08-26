module CampusSolutions
  module ProfileFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_profile
    end
  end
end
