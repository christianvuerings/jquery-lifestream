module SIS
  class SlugParsers
    class << self
      def parse_section_slug(sis_section_id)
        namespace = 'SEC:'
        slug = verify_namespace!(sis_section_id, namespace)
        tuple = slug.split('-')

        if tuple.size != 3
          raise ArgumentError, "#{self.class.name} Section slug #{tuple} length != 3"
        end

        {
          year: tuple[0],
          term_cd: tuple[1],
          ccn: tuple[2]
        }
      end

      private

      def verify_namespace!(id, namespace)
        raise ArgumentError, "#{self.class.name} Slug or slug namespace cannot be empty" if namespace.empty? || id.nil? || id.empty?
        raise ArgumentError, "#{self.class.name}: Slug namespace (#{namespace}) cannot be parsed #{id}" unless id.start_with?(namespace)
        id[namespace.length..-1]
      end
    end
  end
end