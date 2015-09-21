module CampusSolutions
  module ProfileFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_profile
    end
    alias_method(:is_cs_profile_feature_enabled, :is_feature_enabled)
  end
end
