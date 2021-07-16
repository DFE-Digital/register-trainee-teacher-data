# frozen_string_literal: true

class Trainee < ApplicationRecord
  include Sluggable
  include PgSearch::Model

  belongs_to :provider
  belongs_to :apply_application, optional: true
  has_many :degrees, dependent: :destroy
  has_many :nationalisations, dependent: :destroy, inverse_of: :trainee
  has_many :nationalities, through: :nationalisations
  has_many :trainee_disabilities, dependent: :destroy, inverse_of: :trainee
  has_many :disabilities, through: :trainee_disabilities
  belongs_to :lead_school, optional: true, class_name: "School"
  belongs_to :employing_school, optional: true, class_name: "School"

  attribute :progress, Progress.to_type

  delegate :award_type, :requires_placement_details?, :requires_schools?,
           :requires_employing_school?, :early_years_route?, to: :training_route_manager

  delegate :update_training_route!, to: :route_data_manager

  validates :training_route, presence: {
    message: I18n.t("activerecord.errors.models.trainee.attributes.training_route"),
  }

  enum training_route: TRAINING_ROUTES_FOR_TRAINEE

  enum training_initiative: ROUTE_INITIATIVES

  enum bursary_tier: BURSARY_TIERS

  enum locale_code: { uk: 0, non_uk: 1 }

  enum gender: {
    male: 0,
    female: 1,
    other: 2,
    gender_not_provided: 3,
  }

  enum diversity_disclosure: {
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_disclosed] => 0,
    Diversities::DIVERSITY_DISCLOSURE_ENUMS[:diversity_not_disclosed] => 1,
  }

  enum disability_disclosure: {
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:disabled] => 0,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:no_disability] => 1,
    Diversities::DISABILITY_DISCLOSURE_ENUMS[:not_provided] => 2,
  }

  enum ethnic_group: {
    Diversities::ETHNIC_GROUP_ENUMS[:asian] => 0,
    Diversities::ETHNIC_GROUP_ENUMS[:black] => 1,
    Diversities::ETHNIC_GROUP_ENUMS[:mixed] => 2,
    Diversities::ETHNIC_GROUP_ENUMS[:white] => 3,
    Diversities::ETHNIC_GROUP_ENUMS[:other] => 4,
    Diversities::ETHNIC_GROUP_ENUMS[:not_provided] => 5,
  }

  enum withdraw_reason: {
    WithdrawalReasons::UNKNOWN => 0,
    WithdrawalReasons::FOR_ANOTHER_REASON => 1,
    WithdrawalReasons::DEATH => 2,
    WithdrawalReasons::EXCLUSION => 3,
    WithdrawalReasons::FINANCIAL_REASONS => 4,
    WithdrawalReasons::GONE_INTO_EMPLOYMENT => 5,
    WithdrawalReasons::HEALTH_REASONS => 6,
    WithdrawalReasons::PERSONAL_REASONS => 7,
    WithdrawalReasons::TRANSFERRED_TO_ANOTHER_PROVIDER => 8,
    WithdrawalReasons::WRITTEN_OFF_AFTER_LAPSE_OF_TIME => 9,
  }

  enum state: {
    draft: 0,
    submitted_for_trn: 1,
    trn_received: 2,
    recommended_for_award: 3,
    withdrawn: 4,
    deferred: 5,
    awarded: 6,
  } do
    event :submit_for_trn do
      before do
        self.submitted_for_trn_at = Time.zone.now
      end

      transition %i[draft deferred] => :submitted_for_trn
    end

    event :receive_trn do
      transition %i[submitted_for_trn deferred] => :trn_received
    end

    event :recommend_for_award do
      before do
        self.recommended_for_award_at = Time.zone.now
      end

      transition %i[trn_received] => :recommended_for_award
    end

    event :withdraw do
      transition %i[submitted_for_trn trn_received deferred] => :withdrawn
    end

    event :defer do
      transition %i[submitted_for_trn trn_received] => :deferred
    end

    event :award do
      before do
        self.awarded_at = Time.zone.now
      end

      transition %i[recommended_for_award] => :awarded
    end
  end

  pg_search_scope :with_name_trainee_id_or_trn_like,
                  against: %i[first_names middle_names last_name trainee_id trn],
                  using: { tsearch: { prefix: true } }

  scope :ordered_by_date, -> { order(updated_at: :desc) }
  scope :ordered_by_last_name, -> { order(last_name: :asc) }
  scope :with_subject, ->(subject) { where("LOWER(course_subject_one) = :subject OR LOWER(course_subject_two) = :subject OR LOWER(course_subject_three) = :subject", subject: subject.downcase) }

  # Returns draft trainees first, then all trainees in any other state.
  scope :ordered_by_drafts, -> { order(ordered_by_drafts_clause) }

  scope :with_award_states, lambda { |*award_states|
    qts_states = award_states.select { |s| s.start_with? "qts" }.map { |s| genericize_state(s) }
    eyts_states = award_states.select { |s| s.start_with? "eyts" }.map { |s| genericize_state(s) }

    where(training_route: EARLY_YEARS_ROUTES, state: eyts_states).or(
      where(state: qts_states).where.not(training_route: EARLY_YEARS_ROUTES),
    )
  }

  audited associated_with: :provider
  has_associated_audits

  def trn_requested!(dttp_id, placement_assignment_dttp_id)
    update!(dttp_id: dttp_id, placement_assignment_dttp_id: placement_assignment_dttp_id)
  end

  def trn_received!(new_trn = nil)
    raise StateTransitionError, "Cannot transition to :trn_received without a trn" unless new_trn || trn

    # Skip deferred and withdrawn to avoid state change
    # but to still register trn
    receive_trn! unless deferred? || withdrawn?
    # A deferred trainee will probably already have a trn - don't overwrite that!
    update!(trn: new_trn) unless trn
  end

  def dttp_id=(value)
    raise LockedAttributeError, "dttp_id update failed for trainee ID: #{id}, with value: #{value}" if dttp_id.present?

    super
  end

  def sha
    Digest::SHA1.hexdigest(digest)
  end

  def digest
    exclude_list = %w[created_at updated_at dttp_update_sha]

    [as_json.except(*exclude_list), degrees, nationalities, disabilities].map(&:to_json).join(",")
  end

  def self.ordered_by_drafts_clause
    Arel.sql <<~SQL
      CASE trainees.state
      WHEN #{states.fetch('draft')} THEN 0
      ELSE 1
      END
    SQL
  end

  def training_route_manager
    @training_route_manager ||= TrainingRouteManager.new(self)
  end

  def available_courses
    provider.courses.where(route: training_route) if TRAINING_ROUTES_FOR_COURSE.keys.include?(training_route)
  end

  def clear_disabilities
    disabilities.clear
  end

  def apply_application?
    apply_application.present?
  end

  def course_age_range
    [course_min_age, course_max_age].compact
  end

  def course_age_range=(range)
    self.course_min_age, self.course_max_age = range
  end

  def course_subjects
    [course_subject_one, course_subject_two, course_subject_three].reject(&:blank?)
  end

  def route_data_manager
    @route_data_manager ||= RouteDataManager.new(trainee: self)
  end

  def self.genericize_state(state)
    if state.end_with? "awarded"
      "awarded"
    elsif state.end_with? "recommended"
      "recommended_for_award"
    else
      state
    end
  end

  def timeline
    Rails.cache.fetch([self, :timeline]) do
      Trainees::CreateTimeline.call(trainee: self)
    end
  end

  def bursary_amount
    CalculateBursary.for_route_and_subject(training_route.to_sym, course_subject_one)
  end

  def set_early_years_course_details
    if early_years_route?
      self.course_subject_one = Dttp::CodeSets::CourseSubjects::EARLY_YEARS_TEACHING
      self.course_age_range = AgeRange::ZERO_TO_FIVE
    end
  end

  def can_apply_for_bursary?
    training_route == TRAINING_ROUTE_ENUMS[:early_years_postgrad] || bursary_amount.present?
  end
end
