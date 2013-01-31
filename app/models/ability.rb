class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    
    if user.has_role?(Role::SUPER_ADMIN)
      can :manage, :all
    elsif user.has_role?(Role::TECHNICIAN)
      can :read, :all
      can :create, [Measurement, TreatmentPlan, TreatmentSession, Treatment, Testimonial]
      can :manage, [TreatmentFacility, Patient, Measurement, TreatmentPlan, TreatmentSession, Treatment, Testimonial]
      cannot :destroy, [Machine, Measurement, Protocol, Role, Testimonial, TreatmentFacility, TreatmentPlan, TreatmentSession, Treatment, User]
    else
      # Not logged in
      can :read, [Testimonial, TreatmentFacility]
    end
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
