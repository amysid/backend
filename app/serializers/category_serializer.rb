class CategorySerializer  < ApplicationSerializer
  attributes :id,  :name, :arabic_name

  attribute :icon_url do |category, _params|
    rails_blob_path(category.icon , only_path: true) if category.icon.present?
  end

  attribute :white_icon_url do |category, _params|
    rails_blob_path(category.white_icon , only_path: true) if category.white_icon.present?
  end

  attribute :booths do |category, _params|
    category.booths.pluck(:name, :id)
  end

end