class Note < ApplicationRecord
    has_many_attached :attachments

    validates :subject, presence: true, format: { with: /\A[A-Za-z0-9\s]+\z/, message: "has to be alphanumeric + whitespace" }
    validates :body, presence: true
end
