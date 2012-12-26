class Product < ActiveRecord::Base
  belongs_to :category
  has_many   :items
  has_many   :orders, through: :items

  mount_uploader :cover, ImageUploader

  attr_accessible :category_id, :name, :description, :quantity, :price, :cover

  scope :last_four_products, order('created_at DESC').limit(4)
  scope :available,          -> { where("quantity != ?", 0) }

  include PgSearch
  pg_search_scope :search, against: [:name, :description],
                  using: {tsearch: {dictionary: "english"}},
                  associated_against: {category: :name}

  def self.by_category(category_id)
    category_id.present? ? joins(:category).where(categories: { slug: category_id }) : scoped
  end

  def self.by_price_range(min, max)
    (min.present? and max.present?) ? where("price >= ? and price <= ?", min, max) : scoped
  end
end