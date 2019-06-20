module CopyTunerClient
  module DottedHash
    def to_h(dotted_hash)
      hash = {}
      dotted_hash.to_h.transform_keys(&:to_s).sort.each do |key, value|
        _hash = key.split('.').reverse.inject(value) { |memo, key| { key => memo } }
        hash.deep_merge!(_hash)
      end
      hash
    end

    def conflict_keys(dotted_hash)
      all_keys = dotted_hash.keys.sort
      results = {}

      all_keys.each_with_index do |key, index|
        prefix = "#{key}."
        conflict_keys = ((index + 1)..Float::INFINITY)
          .take_while { |i| all_keys[i]&.start_with?(prefix) }
          .map { |i| all_keys[i] }

        if conflict_keys.present?
          results[key] = conflict_keys
        end
      end

      results
    end

    module_function :to_h, :conflict_keys
  end
end
