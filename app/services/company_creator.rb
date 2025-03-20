class CompanyCreator
  def initialize(user, company_params, default_profile_flag)
    @user = user
    @company_params = company_params

    @default_profile_flag = ActiveModel::Type::Boolean.new.cast(default_profile_flag)
  end

  def call
    Company.transaction do
      company = Company.create!(@company_params)
      admin_profile_type = ProfileType.find_by!(name: "administrator")

      if @default_profile_flag
        @user.profiles.where(default_profile: true).update_all(default_profile: false)
      end
      @user.profiles.create!(
        company: company,
        profile_type: admin_profile_type,
        default_profile: @default_profile_flag,
        active: true
      )

      company
    end
  end
end
