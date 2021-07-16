# frozen_string_literal: true

require "rails_helper"

feature "apply registrations", type: :feature do
  include CourseDetailsHelper

  let(:subjects) { [] }

  background do
    given_i_am_authenticated
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  scenario "renders a 'not started' status when no details provided" do
    then_the_section_should_be(not_started)
  end

  describe "with a course that doesn't require selecting a specialism" do
    let(:subjects) { [Dttp::CodeSets::AllocationSubjects::HISTORY] }

    xscenario "renders a 'completed' status when details fully provided" do
      given_a_trainee_created_from_apply_that_doesnt_require_selecting_specialism
      when_i_visit_the_apply_registrations_course_details_page
      then_i_am_redirected_to_the_apply_registrations_confirm_course_page
    end
  end

private

  def given_a_trainee_created_from_apply_that_doesnt_require_selecting_specialism
    course_code = ApiStubs::ApplyApi.course.as_json["course_code"]
    training_route = :school_direct_tuition_fee
    given_a_trainee_exists(:with_apply_application,
                           :with_course_details,
                           course_code: course_code,
                           training_route: training_route)
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def when_i_visit_the_apply_registrations_course_details_page
    apply_registrations_course_details_page.load(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_apply_registrations_confirm_course_page
    expect(apply_registrations_confirm_course_page).to be_displayed(id: trainee.slug)
  end
end
