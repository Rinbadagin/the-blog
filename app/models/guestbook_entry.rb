class GuestbookEntry < ApplicationRecord
  validates :name, length: {minimum: 1, maximum: 30 }
  validates :body, length: { minimum: 2, maximum: 140 }
end
