module Appsignal
  module Utils
    def self.sanitize(params, only_top_level=false, key_sanitizer=nil)
      if params.is_a?(Hash)
        {}.tap do |hsh|
          params.each do |key, val|
            hsh[self.sanitize_key(key, key_sanitizer)] = if only_top_level
              '?'
            else
              sanitize(val, only_top_level, key_sanitizer=nil)
            end
          end
        end
      elsif params.is_a?(Array)
        if only_top_level
          sanitize(params[0], only_top_level, key_sanitizer=nil)
        elsif params.first.is_a?(String)
          ['?']
        else
          params.map do |item|
            sanitize(item, only_top_level, key_sanitizer=nil)
          end
        end
      else
        '?'
      end
    end

    def self.sanitize_key(key, sanitizer)
      case sanitizer
      when :mongodb then key.to_s.gsub(/(\..+)/, '.?')
      else key
      end
    end

    def self.json_generate(body)
      JSON.generate(jsonify(body))
    end

    def self.jsonify(value)
      case value
      when String
        value.encode(
          'utf-8',
          :invalid => :replace,
          :undef   => :replace
        )
      when Numeric, NilClass, TrueClass, FalseClass
        value
      when Hash
        Hash[value.map { |k, v| [jsonify(k), jsonify(v)] }]
      when Array
        value.map { |v| jsonify(v) }
      else
        jsonify(value.to_s)
      end
    end
  end
end