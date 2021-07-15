# frozen_string_literal: true

require "rails_helper"

feature "apply registrations", type: :feature do
  include CourseDetailsHelper

  let(:subjects) { [] }

  background do
    given_i_am_authenticated
    given_a_trainee_exists_with_apply_application
    given_i_am_on_the_review_draft_page

  end

  before do
    FormStore.clear_all(trainee.id)
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  scenario "renders a 'not started' status when no details provided" do
    then_the_section_should_be(not_started)
  end

  describe "with a course that doesn't require selecting a specialism" do
    let(:subjects) { [Dttp::CodeSets::AllocationSubjects::HISTORY] }

    scenario "renders a 'completed' status when details fully provided" do
      when_i_visit_the_apply_registrations_course_details_page
      save_and_open_page
      then_i_should_see_the_subject_described_as("History")
    end
  end

private

  def given_a_trainee_exists_with_apply_application
    course_code = ApiStubs::ApplyApi.course.as_json["course_code"]
    training_route = :school_direct_tuition_fee
    given_a_trainee_exists(:with_apply_application, course_code: course_code, training_route: training_route)

    create(:course_with_subjects,
           subject_names: subjects,
           code: course_code,
           route: training_route,
           accredited_body_code: trainee.provider.code)
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def when_i_visit_the_apply_registrations_course_details_page
    apply_registrations_course_details_page.load(id: trainee.slug)
  end
  def then_i_should_see_the_subject_described_as(description)
    expect(apply_registrations_course_details_page.subject_description).to eq(description)
  end
end
