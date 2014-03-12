module Notifications
  class EducLevelTranslator

    def translate(educ_level)
      if (educ_level.eql? "Adv Doc")
        educ_level = "Advanced Doctoral"
      end
      educ_level
    end

  end
end
