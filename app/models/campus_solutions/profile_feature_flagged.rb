module CampusSolutions
  module ProfileFeatureFlagged
    def is_feature_enabled
      Settings.features.cs_profile
    end
    alias_method(:is_cs_profile_feature_enabled, :is_feature_enabled)

    def is_profile_visible_for_legacy_users
      Settings.features.cs_profile_visible_for_legacy_users
    end
  end
end
