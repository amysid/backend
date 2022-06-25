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

  attribute :total_time do |book, _params|
    total = book.operations.sum(:listening_status)
    Time.at(total).utc.strftime("%H:%M:%S")
  end

end