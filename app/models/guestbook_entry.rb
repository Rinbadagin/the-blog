class GuestbookEntry < ApplicationRecord
  validates :name, length: {minimum: 1, maximum: 45 }
  validates :body, length: { minimum: 2, maximum: 400 }
end
