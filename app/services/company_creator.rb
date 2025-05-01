class CompanyCreator
  def initialize(user, company_params, default_profile_flag)
    @user = user
    @company_params = company_params

    @default_profile_flag = ActiveModel::Type::Boolean.new.cast(default_profile_flag)
  end

  def call
    company = Company.new(@company_params)

    Company.transaction do
      unless company.save
        raise ActiveRecord::Rollback
      end

      admin_profile_type = ProfileType.admin
      if @default_profile_flag
        @user.profiles.where(default_profile: true).update_all(default_profile: false)
      end

      @user.profiles.create!(
        company: company,
        profile_type: admin_profile_type,
        default_profile: @default_profile_flag,
        active: true
      )
    end

    company
  end
end
