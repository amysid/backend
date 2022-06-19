class ApplicationSerializer

  include FastJsonapi::ObjectSerializer

  def self.param?(name)
    return proc {|_record, params|
      params && params[name].present?
    }
  end

  attribute :created_at, if: param?(:include_timestamps)
  attribute :updated_at, if: param?(:include_timestamps)

end