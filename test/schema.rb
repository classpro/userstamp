ActiveRecord::Schema.define(:version => 0) do
  # Users are created and updated by other Users
  create_table :users, :force => true do |t|
    t.column :name,           :string
    t.column :creatorr_id,     :integer
    t.column :created_on,     :datetime
    t.column :updatorr_id,     :integer
    t.column :updated_at,     :datetime
  end

  # People are created and updated by Users
  create_table :people, :force => true do |t|
    t.column :name,           :string
    t.column :creatorr_id,     :integer
    t.column :created_on,     :datetime
    t.column :updatorr_id,     :integer
    t.column :updated_at,     :datetime
  end

  # Posts are created and updated by People
  create_table :posts, :force => true do |t|
    t.column :title,          :string
    t.column :creatorr_id,     :integer
    t.column :created_on,     :datetime
    t.column :updatorr_id,     :integer
    t.column :updated_at,     :datetime
    t.column :deleter_id,     :integer
    t.column :deleted_at,     :datetime
  end

  # Comments are created and updated by People
  # and also use non-standard foreign keys.
  create_table :comments, :force => true do |t|
    t.column :post_id,        :integer
    t.column :comment,        :string
    t.column :created_by_id,     :integer
    t.column :created_at,     :datetime
    t.column :updated_by_id,     :integer
    t.column :updated_at,     :datetime
    t.column :deleted_by_id,     :integer
    t.column :deleted_at,     :datetime
  end

  # Pings are created and updated by People,
  # but they store their foreign keys as strings.
  create_table :pings, :force => true do |t|
    t.column :post_id,        :integer
    t.column :ping,           :string
    t.column :creatorr_name,   :string
    t.column :created_at,     :datetime
    t.column :updatorr_name,   :string
    t.column :updated_at,     :datetime
    t.column :deleter_name,   :string
    t.column :deleted_at,     :datetime
  end
end