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

  attr_accessor :mark_as_reviewed

  def initialize(trainee:)
    @trainee = trainee
  end

  def save
    trainee.progress.personal_details = true
    trainee.progress.contact_details = true
    trainee.progress.diversity = true
    trainee.progress.degrees = true
    trainee.save!
  end

  def progress_status(progress_key)
    return :not_provided if trainee.apply_application? && !progress_service(progress_key).started?

    progress_service(progress_key).status.parameterize(separator: "_").to_sym
  end

  def display_type(section_key)
    if section_key == :degrees
      progress_status(section_key) == :not_provided ? :collapsed : :expanded
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
