module I18n
  module Backend
    module Helpers
      # Return a new hash with all keys and nested keys converted to symbols.
      def deep_symbolize_keys(hash)
        hash.inject({}) { |result, (key, value)|
          value = deep_symbolize_keys(value) if value.is_a?(Hash)
          result[(key.to_sym rescue key) || key] = value
          result
        }
      end

      # Flatten keys for nested Hashes by chaining up keys using the separator
      #   >> { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}.wind
      #   => { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }
      def wind_keys(hash, separator = ".", prev_key = nil, result = {})
        hash.inject(result) do |result, pair|
          key, value = *pair
          curr_key = [prev_key, key].compact.join(separator)
          if value.is_a?(Hash)
            wind_keys(value, separator, curr_key, result)
          else
            result[curr_key] = value
          end
          result
        end
      end

      # Expand keys chained by the the given separator through nested Hashes
      #   >> { "a.b.c" => "d", "a.b.e" => "f", "a.g" => "h", "i" => "j" }.unwind
      #   => { "a" => { "b" => { "c" => "d", "e" => "f" }, "g" => "h" }, "i" => "j"}
      def unwind_keys(hash, separator = ".")
        result = {}
        hash.each do |key, value|
          keys = key.split(separator)
          curr = result
          curr = curr[keys.shift] ||= {} while keys.size > 1
          curr[keys.shift] = value
        end
        result
      end

      # # Flatten the given array once
      # def flatten_once(array)
      #   result = []
      #   for element in array # a little faster than each
      #     result.push(*element)
      #   end
      #   result
      # end
    end
  end
end
