class Item < ActiveRecord::Base
	  validates_presence_of :name, :category, :description, :value, :category_id, :image_path

	  validates :name, length: { minimum: 10, message: "Your item name is too short.  Please be more descriptive." }
	  validates :description, length: { minimum: 20, message: "Your item description is too short.  Please be more descriptive." }

	belongs_to :category
	belongs_to :user
	has_many :loans

	before_validation :defaults

	def defaults
		self.condition ||= rand(100)
		self.image_path = rand(100).to_s if self.image_path.blank?
		self.category_id ||=rand(15)
		self.value ||=rand(500)
		self.tags ||="boring, default, blah"
	end



	def condition_qual
		grades = {(90..100) =>"Excellent", (75..89)=>"Good", (55..74)=>"Fair", (40..54)=>"Worn", (0..39)=>"Very Worn"}

		grades.each do |quant_score, qual_grade|
			if quant_score === self.condition
				return qual_grade
				else
			end
		end
	end

	  def tags_array
	  	if self.tags.nil?
	  		nil
	  	else
	  	self.tags.downcase.split(',')
	  	end
	  end

	  def item_loans
	  	Loan.where(item_id: self.id).count
	  end


	def available?
		item = self.id
		last_loan = Loan.where(item_id: item).last

		if last_loan.nil? == true || (last_loan.owner_approved == false || last_loan.expired? == true)
			true
		else
			false
		end
	end


	def self.available_items
		items = Item.all.order(created_at: :desc).collect {|item| item.available? ? item : nil}.compact
			
	end

	def self.not_user_items(user)
		Item.where.not(user_id: user).order(updated_at: :desc)
	end


	# def self.other_users_items
	# 	Item.where.not(user_id: current_user.id).order(updated_at: :desc)
	# end

	# def self.user_items
	# 	Item.where(user_id: current_user.id).order(updated_at: :desc)
	# end



end
