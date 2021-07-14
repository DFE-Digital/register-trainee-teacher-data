# frozen_string_literal: true

class ApplyTraineeDataForm
  include ActiveModel::Model

  class_attribute :form_validators, instance_writer: false, default: {}

  class << self
    def validator(name, options)
      form_validators[name] = options
    end
  end

  validator :personal_details, form: "PersonalDetailsForm"
  validator :contact_details, form: "ContactDetailsForm"
  validator :diversity, form: "Diversities::FormValidator"
  validator :degrees, form: "DegreesForm"

  delegate :apply_application?, to: :trainee

  attr_accessor :mark_as_reviewed

  def initialize(trainee)
    @trainee = trainee
  end

  def save
    return unless all_forms_valid?

    trainee.progress.personal_details = true
    trainee.progress.contact_details = true
    trainee.progress.diversity = true
    trainee.progress.degrees = true
    trainee.save!
  end

  def all_forms_valid?
    form_validators.each_value do |section|
      return false unless form(section).valid?
    end
  end

  def form(section)
    section[:form].constantize.new(trainee)
  end

  def progress_status(progress_key)
    progress_service(progress_key).status.parameterize(separator: "_").to_sym
  end

  def progress
    form_progress = true
    form_validators.each_key do |section_key|
      progress = trainee.progress.public_send(section_key)
      case progress
      when false
        form_progress = false
      end
    end
    form_progress
  end

  def fields
    fields = {}
    form_validators.each_value do |section|
      fields.merge!(form(section).fields)
    end
    fields
  end

  def display_type(section_key)
    if section_key == :degrees
      progress_status(section_key) == :not_started ? :collapsed : :expanded
    else
      :expanded
    end
  end

private

  def progress_service(progress_key)
    validator = validator(progress_key).new(trainee)
    progress_value = trainee.progress.public_send(progress_key)
    ProgressService.call(validator: validator, progress_value: progress_value)
  end

  def validator(section)
    form_validators[section][:form].constantize
  end

  attr_reader :trainee
end
