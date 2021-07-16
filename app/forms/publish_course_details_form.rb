# frozen_string_literal: true

class PublishCourseDetailsForm < TraineeForm
  NOT_LISTED = "not_listed"

  FIELDS = %i[
    code
    specialism_form
  ].freeze

  attr_accessor(*FIELDS)

  validates :code, presence: true

  def manual_entry_chosen?
    code == NOT_LISTED
  end

  def specialism_form=(form)
    @specialism_form = form
    @fields.merge!(specialism_form: form)
  end

private

  def compute_fields
    new_attributes
  end
end
