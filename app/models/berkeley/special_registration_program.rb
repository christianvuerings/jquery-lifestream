module Berkeley
  module SpecialRegistrationProgram
    extend self

    # See http://registrar.berkeley.edu/DisplayMedia.aspx?ID=reg_spec_pgm_cd_key.pdf for key.
    def attributes_from_code(reg_special_pgm_cd)
      case reg_special_pgm_cd
        when 'E', 'F'
          {education_abroad: true}
        else
          {}
      end

    end
  end
end
