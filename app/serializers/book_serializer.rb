class BookSerializer  < ApplicationSerializer

  attributes :id,  :title, :author_name, :body, :book_duration, :status, :reason_for_rejection,
              :listen_count, :last_listening_at, :created_at, :updated_at, :audio_type, :language,
              :arabic_title, :arabic_body, :arabic_author_name

  # attribute :last_listening do |book, _params|
  #   book.operations.last.created_at if book.operations.present?
  # end

  attribute :selected_categories do |book, _param|
    book.categories.present? ? book.categories.pluck(:name, :id) : [] 
  end

  attribute :selected_categories_id do |book, _params|
    book.categories.present? ? book.categories.pluck(:id) : [] 
  end

  attribute :display_categories do |book, _params|
    book.categories.pluck(:name).join(",")
  end

  attribute :display_ar_categories do |book, _params|
    book.categories.pluck(:arabic_name).join(",")
  end

  attribute :total_time do |book, _params|
    total = book.operations.sum(:listening_status)
    Time.at(total).utc.strftime("%H:%M:%S")
  end

  attribute :book_cover_file_url do |book, _params|
    book.book_cover_file_url
    #ENV["BACKEND_URL"] + Rails.application.routes.url_helpers.rails_blob_path(book.book_cover_file , only_path: true) if book.book_cover_file.present?
  end

  attribute :audio_url do |book, _params|
    ENV["BACKEND_URL"] + Rails.application.routes.url_helpers.rails_blob_path(book.audio , only_path: true) if book.audio.present?
  end
  
  attribute :short_audio_url do |book, _params|
    ENV["BACKEND_URL"] + Rails.application.routes.url_helpers.rails_blob_path(book.short_audio_file , only_path: true) if book.short_audio_file.present?
  end

end