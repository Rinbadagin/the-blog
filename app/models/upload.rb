class Upload < ApplicationRecord
  has_one_attached :content

  validates :title, presence: true, uniqueness: true, format: { with: /\A[A-Za-z0-9]+\z/, message: "has to be alphanumeric" }
end
