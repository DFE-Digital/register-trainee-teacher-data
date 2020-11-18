module Trainees
  module Confirmation
    module Degrees
      class View < GovukComponent::Base
        attr_accessor :degrees, :trainee, :show_add_another_degree_button

        def initialize(trainee:, show_add_another_degree_button: true)
          @trainee = trainee
          @degrees = trainee.degrees
          @show_add_another_degree_button = show_add_another_degree_button
        end

        def degree_title(degree)
          if degree.uk?
            "#{degree.uk_degree}: #{degree.subject.downcase}"
          else
            "Non-UK #{degree.non_uk_degree}: #{degree.subject.downcase}"
          end
        end

        def get_degree_rows(degree)
          if degree.uk?
            [
              {
                key: "Degree type",
                value: degree.uk_degree,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> degree type</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Subject",
                value: degree.subject,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Institution",
                value: degree.institution,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> institution</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Graduation year",
                value: degree.graduation_year,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Grade",
                value: degree.grade,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> grade</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
            ]
          else
            [
              {
                key: "Comparable UK degree",
                value: degree.non_uk_degree,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> comparable UK degree</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Subject",
                value: degree.subject,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> subject</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Country",
                value: degree.country,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> country</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
              {
                key: "Graduation year",
                value: degree.graduation_year,
                action: govuk_link_to('Change<span class="govuk-visually-hidden"> graduation year</span>'.html_safe, edit_trainee_degree_path(trainee, degree)),
              },
            ]
          end
        end
      end
    end
  end
end
