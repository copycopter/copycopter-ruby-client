module CopyTunerClient
  module DottedHash
    def to_hash(dotted_hash)
      hash = {}
      dotted_hash.transform_keys(&:to_s).sort.each do |key, value|
        _hash = key.split('.').reverse.inject(value) { |memo, key| { key => memo } }
        hash.deep_merge!(_hash)
      end
      hash
    end

    def to_json(dotted_hash)
      to_hash(dotted_hash).to_json
    end

    def to_yaml(dotted_hash)
      to_hash(dotted_hash).to_yaml
    end

    def invalid_keys(dotted_hash)
      all_keys = dotted_hash.keys
      results = Hash.new {[]}

      all_keys.sort.each do |key|
        invalid_keys = all_keys.find_all { |k| k.start_with?("#{key}.") }
        if invalid_keys.present?
          results[key] = invalid_keys
        end
      end

      results
    end

    module_function :to_hash, :to_json, :to_yaml, :invalid_keys
  end
end
