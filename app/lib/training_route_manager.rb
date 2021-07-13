# frozen_string_literal: true

class TrainingRouteManager
  def initialize(trainee)
    @trainee = trainee
  end

  def requires_placement_details?
    enabled? :provider_led_postgrad
  end

  def requires_schools?
    %i[school_direct_salaried school_direct_tuition_fee pg_teaching_apprenticeship].any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def requires_employing_school?
    %i[school_direct_salaried pg_teaching_apprenticeship].any? { |training_route_enums_key| enabled?(training_route_enums_key) }
  end

  def award_type
    TRAINING_ROUTE_AWARD_TYPE[training_route&.to_sym]
  end

  def early_years_route?
    training_route.to_s.starts_with?("early_years")
  end

private

  attr_reader :trainee

  delegate :training_route, to: :trainee

  def enabled?(training_route_enums_key)
    FeatureService.enabled?("routes.#{training_route_enums_key}") && training_route == TRAINING_ROUTE_ENUMS[training_route_enums_key]
  end
end
