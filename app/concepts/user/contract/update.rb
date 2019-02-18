class User
  module Contract
    class Update < Reform::Form
      property :note

      validation do
        required(:note).maybe(:str?)
      end
    end
  end
end
