# frozen_string_literal: true

require "rails_helper"

feature "publish course details", type: :feature, feature_publish_course_details: true do
  include CourseDetailsHelper

  let(:subjects) { [] }

  background do
    given_i_am_authenticated
    given_a_trainee_exists_with_some_courses(with_subjects: subjects)
    given_i_am_on_the_review_draft_page
  end

  before do
    FormStore.clear_all(trainee.id)
  end

  after do
    FormStore.clear_all(trainee.id)
  end

  describe "tracking the progress" do
    scenario "renders a 'not started' status when no details provided" do
      when_i_visit_the_review_draft_page
      then_the_section_should_be(not_started)
    end

    describe "with a course that doesn't require selecting a specialism" do
      let(:subjects) { [Dttp::CodeSets::AllocationSubjects::HISTORY] }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        then_i_should_see_the_subject_described_as("History")
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    describe "with a course that requires selecting a single specialism" do
      let(:subjects) do
        [
          Dttp::CodeSets::AllocationSubjects::COMPUTING,
        ]
      end

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Computer science")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Computer science")
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    describe "with a course that requires selecting multiple specialisms" do
      let(:subjects) do
        [
          Dttp::CodeSets::AllocationSubjects::COMPUTING,
          Dttp::CodeSets::AllocationSubjects::MATHEMATICS,
        ]
      end

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        and_i_select_a_specialism("Mathematics")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Applied computing with mathematics")
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    describe "with a course that requires selecting language specialisms" do
      let(:subjects) { ["Modern languages (other)"] }

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_languages("Arabic languages", "Welsh", "Portuguese")
        and_i_submit_the_language_specialism_form
        then_i_should_see_the_subject_described_as("Arabic languages with Portuguese and Welsh")
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end

    describe "with a course that has a miture of multiple specalism subjects single specialism ones" do
      let(:subjects) do
        [
          Dttp::CodeSets::AllocationSubjects::MUSIC,
          Dttp::CodeSets::AllocationSubjects::COMPUTING,
          Dttp::CodeSets::AllocationSubjects::HISTORY,
        ]
      end

      scenario "renders a 'completed' status when details fully provided" do
        when_i_visit_the_publish_course_details_page
        and_i_select_a_course
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Music education and teaching with applied computing and history")
        and_i_confirm_the_course
        and_i_visit_the_review_draft_page
        then_the_section_should_be(completed)
      end
    end
  end

  describe "available courses" do
    scenario "there aren't any courses for the trainee's provider and route" do
      given_there_arent_any_courses
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_course_details_edit_page
    end

    scenario "there are some courses for the trainee's provider and route" do
      when_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_publish_course_details_page
    end
  end

  describe "selecting a course" do
    scenario "not selecting anything" do
      given_a_trainee_exists_with_some_courses
      when_i_visit_the_publish_course_details_page
      and_i_submit_the_form
      then_i_see_an_error_message
    end

    describe "selecting a course with one specialism" do
      let(:subjects) { [Dttp::CodeSets::AllocationSubjects::MUSIC] }

      scenario do
        when_i_visit_the_publish_course_details_page
        and_some_courses_for_other_providers_or_routes_exist
        then_i_see_the_route_message
        and_i_only_see_the_courses_for_my_provider_and_route
        when_i_select_a_course
        and_i_submit_the_form
        then_i_see_the_confirm_publish_course_page
      end
    end

    describe "selecting a course with multiple possible specialisms" do
      let(:subjects) { [Dttp::CodeSets::AllocationSubjects::COMPUTING] }

      scenario do
        when_i_visit_the_publish_course_details_page
        and_some_courses_for_other_providers_or_routes_exist
        and_i_only_see_the_courses_for_my_provider_and_route
        when_i_select_a_course
        and_i_submit_the_form
        then_i_see_the_subject_specialism_page
      end
    end

    scenario "selecting 'Another course not listed'" do
      when_i_visit_the_publish_course_details_page
      and_i_select_another_course_not_listed
      and_i_submit_the_form
      then_i_see_the_course_details_page
      and_i_visit_the_review_draft_page
      then_the_link_takes_me_to_the_publish_course_details_page
    end

    describe "selecting a new course from the confirm page" do
      let(:subjects) { [Dttp::CodeSets::AllocationSubjects::COMPUTING] }

      scenario do
        given_a_course_exists(with_subjects: ["Modern languages (other)"])
        when_i_visit_the_publish_course_details_page
        when_i_select_a_course("Computing")
        and_i_submit_the_form
        and_i_select_a_specialism("Applied computing")
        and_i_submit_the_specialism_form
        then_i_should_see_the_subject_described_as("Applied computing")
        when_i_visit_the_publish_course_details_page
        when_i_select_a_course("Modern languages (other)")
        and_i_submit_the_form
        and_i_select_languages("Arabic languages", "Welsh", "Portuguese")
        and_i_submit_the_language_specialism_form
        then_i_should_see_the_subject_described_as("Arabic languages with Portuguese and Welsh")
      end
    end
  end

  def given_a_trainee_exists_with_some_courses(with_subjects: [])
    given_a_trainee_exists(:with_related_courses, subject_names: with_subjects, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    @matching_courses = trainee.provider.courses.where(route: trainee.training_route)
  end

  def given_a_course_exists(with_subjects: [])
    create_list(:course_with_subjects, 1,
                subject_names: with_subjects,
                accredited_body_code: @trainee.provider.code,
                route: @trainee.training_route)
  end

  def then_the_section_should_be(status)
    expect(review_draft_page.course_details.status.text).to eq(status)
  end

  def then_the_link_takes_me_to_the_course_details_edit_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_course_details_path(trainee)
  end

  def then_the_link_takes_me_to_the_publish_course_details_page
    expect(review_draft_page.course_details.link[:href]).to eq edit_trainee_publish_course_details_path(trainee)
  end

  def when_i_visit_the_publish_course_details_page
    publish_course_details_page.load(id: trainee.slug)
  end

  def and_i_select_a_course(course_title = nil)
    if course_title
      option = publish_course_details_page.course_options.find { |o| o.label.text.include?(course_title) }
      option.choose
    else
      publish_course_details_page.course_options.first.choose
    end
  end

  def and_i_select_languages(*languages)
    options = language_specialism_page.language_specialism_options.select do |option|
      languages.include?(option.label.text)
    end

    options.each { |checkbox| click(checkbox.input) }
  end

  alias_method :when_i_select_a_course, :and_i_select_a_course

  def and_i_submit_the_form
    publish_course_details_page.submit_button.click
  end

  def and_i_submit_the_specialism_form
    subject_specialism_page.submit_button.click
  end

  def and_i_submit_the_language_specialism_form
    language_specialism_page.submit_button.click
  end

  def and_i_confirm_the_course
    confirm_publish_course_page.submit_button.click
  end

  def and_i_select_another_course_not_listed
    publish_course_details_page.course_options.last.choose
  end

  def and_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def and_i_select_a_specialism(specialism)
    option = subject_specialism_page.specialism_options.find { |o| o.label.text == specialism }
    option.choose
  end

  alias_method :when_i_visit_the_review_draft_page, :and_i_visit_the_review_draft_page

  def then_i_see_an_error_message
    translation_key_prefix = "activemodel.errors.models.publish_course_details_form.attributes"

    expect(publish_course_details_page).to have_content(
      I18n.t("#{translation_key_prefix}.code.blank"),
    )
  end

  def then_i_see_the_course_details_page
    expect(course_details_page).to be_displayed(id: trainee.slug)
  end

  def given_there_arent_any_courses
    CourseSubject.destroy_all
    Course.destroy_all
  end

  def and_some_courses_for_other_providers_or_routes_exist
    other_route = TRAINING_ROUTES_FOR_COURSE.keys.excluding(trainee.training_route).sample
    create(:course, accredited_body_code: trainee.provider.code, route: other_route)
    create(:course, route: trainee.training_route)
  end

  def and_i_only_see_the_courses_for_my_provider_and_route
    course_codes_on_page = publish_course_details_page.course_options
      .map { |o| o.label.text.match(/\((.{4})\)/) }
      .compact
      .map { |m| m[1] }
      .sort

    expect(@matching_courses.map(&:code).sort).to eq(course_codes_on_page)
  end

  def then_i_see_the_route_message
    expected_message = t("views.forms.publish_course_details.route_message", route: route_title(@trainee.training_route))
    expect(publish_course_details_page.route_message.text).to eq(expected_message)
  end

  def then_i_see_the_confirm_publish_course_page
    expect(confirm_publish_course_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_see_the_subject_specialism_page
    expect(subject_specialism_page).to be_displayed(trainee_id: trainee.slug, position: 1)
  end

  def then_i_see_the_language_specialism_page
    expect(language_specialism_page).to be_displayed(trainee_id: trainee.slug)
  end

  def then_i_should_see_the_subject_described_as(description)
    expect(confirm_publish_course_page.subject_description).to eq(description)
  end
end
