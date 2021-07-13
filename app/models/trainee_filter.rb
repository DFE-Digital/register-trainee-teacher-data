# frozen_string_literal: true

class TraineeFilter
  AWARD_STATES = %w[qts_recommended qts_awarded eyts_recommended eyts_awarded].freeze
  STATES = Trainee.states.keys.excluding("recommended_for_award", "awarded") + AWARD_STATES

  def initialize(params:)
    @params = params
  end

  def filters
    return if params.empty?

    return if merged_filters.empty?

    merged_filters
  end

private

  attr_reader :params

  def merged_filters
    @merged_filters ||= text_search.merge(
      **training_route, **state, **subject, **text_search, **record_source,
    ).with_indifferent_access
  end

  def training_route
    return {} unless training_route_options.any?

    { "training_route" => training_route_options }
  end

  def record_source
    return {} unless record_source_options.any?

    { "record_source" => record_source_options }
  end

  def record_source_options
    params[:record_source] ? ["imported_from_apply"] : []
  end

  def training_route_options
    Trainee.training_routes.keys.each_with_object([]) do |option, arr|
      arr << option if params[:training_route]&.include?(option)
    end
  end

  def state
    return {} unless state_options.any?

    { "state" => state_options }
  end

  def state_options
    STATES.each_with_object([]) do |option, arr|
      arr << option if params[:state]&.include?(option)
    end
  end

  def subject
    return {} unless params[:subject].present? && params[:subject] != "All subjects"

    { "subject" => params[:subject].capitalize }
  end

  def text_search
    return {} if params[:text_search].blank?

    { "text_search" => params[:text_search] }
  end
end
