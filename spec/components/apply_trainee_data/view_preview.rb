# frozen_string_literal: true

require "govuk/components"

module ApplyTraineeData
  class ViewPreview < ViewComponent::Preview
    def default
      render(View.new(trainee([degree]), form))
    end

    def with_no_degrees
      render(View.new(trainee, form))
    end

  private

    # rubocop:disable Lint/NestedMethodDefinition
    def trainee(degrees = [])
      @trainee ||= Trainee.new(
        id: 0,
        degrees: degrees,
      ).tap do |t|
        t.degrees&.singleton_class&.class_eval do
          # This is to avoid having activerecord call an sql query when
          # an ordering is applied in the degrees confirmation component.
          # Unfortunately even if we pass in degrees as an array, or any
          # class, activereord casts it to a collection so we need a
          # monkeypatch
          def order(_)
            to_a
          end
        end

        t.degrees&.first&.singleton_class&.class_eval do
          # Again, to get url generation working correctly, we need to make
          # this fake degree appear to be persisted
          def persisted?
            true
          end
        end
      end
    end
    # rubocop:enable Lint/NestedMethodDefinition

    def degree
      Degree.new(
        id: 0,
        locale_code: :uk,
        uk_degree: "BSc - Bachelor of Science",
        subject: "Aviation studies",
        institution: "The Royal College of Nursing",
        graduation_year: "2012",
        grade: "Pass",
      )
    end

    def form
      ApplyTraineeDataForm.new(trainee)
    end
  end
end
