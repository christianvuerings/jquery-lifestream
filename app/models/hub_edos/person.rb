module HubEdos
  class Person < Proxy

    def initialize(options = {})
      super(Settings.hub_edos_proxy, options)
      initialize_mocks if @fake
    end

    def url
      "#{@settings.base_url}"
    end

    def json_filename
      'person_edo.json'
    end

  end
end
