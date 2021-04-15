# frozen_string_literal: true

class DegreeForm
  include ActiveModel::Model
  include ActiveModel::AttributeAssignment
  include ActiveModel::Validations::Callbacks

  FIELDS = %i[
    slug
    locale_code
    uk_degree
    non_uk_degree
    subject
    institution
    graduation_year
    grade
    other_grade
    country
  ].freeze

  AUTOCOMPLETE_FIELDS = %i[
    uk_degree_raw
    subject_raw
    institution_raw
  ].freeze

  attr_accessor(*FIELDS, *AUTOCOMPLETE_FIELDS, :degrees_form, :degree)

  validates :uk_degree, :subject, :institution, autocomplete: true, allow_nil: true
  validate :validate_with_degree_model

  delegate :uk?, :non_uk?, :non_uk_degree_non_naric?, :persisted?,
           to: :degree

  def initialize(degrees_form:, degree:, autocomplete_params: {})
    @degrees_form = degrees_form
    @degree = degree
    self.attributes = degree.attributes
      .symbolize_keys
      .slice(*FIELDS)
    assign_attributes(autocomplete_params)
  end

  def self.model_name
    ActiveModel::Name.new(self, nil, "Degree")
  end

  def id
    slug
  end

  def fields
    degree.attributes
      .symbolize_keys
      .slice(*FIELDS)
      .merge(attributes)
  end

  def attributes
    FIELDS.index_with do |f|
      public_send(f)
    end
  end

  def attributes=(attrs)
    attrs.each do |k, v|
      public_send(:"#{k}=", v)
    end
  end

  def save_or_stash
    if degrees_form.trainee.draft?
      save!
    else
      stash
    end
  end

  def stash
    return false unless valid?

    degrees_form.stash_degree_on_store(slug, fields)
    true
  end

  def save!
    return false unless valid?

    degree.attributes = fields
    degree.save!(context: locale_code.to_sym)
    degrees_form.delete_degree_on_store(slug)
    true
  end

  def destroy!
    degrees_form.delete_degree_on_store(slug)
    degree.destroy! unless degree.new_record?
  end

private

  def validate_with_degree_model
    degree.attributes = fields
    unless degree.valid?(locale_code.to_sym)
      degree.errors.each do |e|
        errors.add(e.attribute, e.message)
      end
    end
  end
end
