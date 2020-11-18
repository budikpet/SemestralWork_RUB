# frozen_string_literal: true

# Contains all String custom methods
module StringPatch
  refine String do
    # @return [Boolean] True <=> it is not nil or empty
    def has_data?
      !nil? || !empty?
    end
  end
end

# Contains all Array custom methods
module ArrayPatch
  refine Array do
    # @return [Boolean] True <=> it is not nil or empty
    def has_data?
      !nil? || !empty?
    end
  end
end

# Contains all NilClass custom methods
module NilClassPatch
  refine NilClass do
    # @return [Boolean] False always
    def has_data?
      false
    end
  end
end
