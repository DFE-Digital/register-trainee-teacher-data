# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Adding a degree" do
  background do
    given_i_am_authenticated
    given_a_trainee_exists
  end

  describe "summary page" do
    scenario "no degrees entered" do
      and_i_visit_the_review_draft_page
      then_the_degree_status_should_be(not_started)
    end
  end

  describe "Validation before route is picked" do
    scenario "the user enters invalid details" do
      and_i_visit_the_review_draft_page
      and_i_click_the_degree_on_the_review_draft_page
      when_i_visit_the_degree_type_page
      and_i_click_the_continue_button_on_the_degree_type_page
      then_i_see_the_error_summary_for_degree_type_page
    end
  end

  describe "UK Route" do
    context "the user enters valid details " do
      background do
        given_i_visited_the_review_draft_page
        and_i_have_selected_uk_route
        when_i_visit_the_degree_details_page
        and_i_fill_in_the_form
        and_i_click_the_continue_button_on_the_degree_details_page
        then_i_am_redirected_to_the_trainee_degrees_confirmation_page
      end

      scenario "the user deletes a degree" do
        confirm_details_page.delete_button.click
        then_i_see_a_flash_message
        and_i_visit_the_review_draft_page
        then_the_degree_status_should_be(not_started)
      end

      scenario "the user confirms degree details" do
        and_confirm_my_details
        then_i_am_redirected_to_the_review_draft_page
        then_the_degree_status_should_be(completed)
      end

      scenario "the user does not confirm degree details" do
        and_i_click_continue
        then_i_am_redirected_to_the_review_draft_page
        then_the_degree_status_should_be(in_progress)
      end
    end

    context "the user enters valid details, with an 'Other' grade" do
      let(:other_grade) { "A different grade" }

      background do
        and_i_have_selected_uk_route
        when_i_visit_the_degree_details_page
        and_i_fill_in_the_form(other_grade: other_grade)
        and_i_click_the_continue_button_on_the_degree_details_page
        then_i_am_redirected_to_the_trainee_degrees_confirmation_page
      end

      scenario "records the other grade" do
        expect(confirm_details_page).to have_text(other_grade)
      end
    end

    scenario "the user enters invalid details on UK degree details page" do
      and_i_have_selected_uk_route
      when_i_visit_the_degree_details_page
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_see_the_error_summary_for_degree_details_page
    end

    scenario "the user submits partially entered autocompletes", js: true do
      and_i_have_selected_uk_route
      when_i_visit_the_degree_details_page
      and_i_fill_in_subject_without_selecting_a_value(with: "moose")
      and_i_fill_in_degree_without_selecting_a_value(with: "goose")
      and_i_fill_in_institution_without_selecting_a_value(with: "obtuse")
      and_i_click_continue
      then_subject_is_populated(with: "moose")
      then_degree_is_populated(with: "goose")
      then_institution_is_populated(with: "obtuse")
      # TODO: error message
    end
  end

  describe "Non-UK Route" do
    scenario "the user enters valid details on Non-UK degree details page" do
      given_i_visited_the_review_draft_page
      and_i_have_selected_non_uk_route
      when_i_visit_the_degree_details_page
      and_i_fill_in_the_form
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_am_redirected_to_the_trainee_degrees_confirmation_page
      and_confirm_my_details
      then_i_am_redirected_to_the_review_draft_page
    end

    scenario "the user enters invalid details on Non-UK degree details page" do
      and_i_have_selected_non_uk_route
      when_i_visit_the_degree_details_page
      and_i_click_the_continue_button_on_the_degree_details_page
      then_i_see_the_error_summary_for_degree_details_page
    end

    scenario "the user submits partially entered autocompletes", js: true do
      and_i_have_selected_non_uk_route
      when_i_visit_the_degree_details_page
      and_i_fill_in_subject_without_selecting_a_value(with: "moose")
      and_i_click_continue
      then_subject_is_populated(with: "moose")
      # TODO: error message
    end
  end

private

  def and_i_visit_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def and_i_visit_the_record_page
    record_page.load(id: trainee.slug)
    expect(record_page).to be_displayed(id: trainee.slug)
  end

  def and_i_click_the_degree_on_the_review_draft_page
    review_draft_page.degree_details.link.click
  end

  def when_i_visit_the_degree_type_page
    degree_type_page.load(trainee_id: trainee.slug)
  end

  def and_i_click_the_continue_button_on_the_degree_type_page
    degree_type_page.continue.click
  end

  def then_i_see_the_error_summary_for_degree_type_page
    expect(degree_type_page.error_summary).to be_visible
  end

  def and_i_click_the_continue_button_on_the_degree_details_page
    degree_details_page.continue.click
  end

  def then_i_see_the_error_summary_for_degree_details_page
    expect(degree_details_page.error_summary).to be_visible
  end

  def and_i_have_selected_uk_route
    @locale = "uk"
  end

  def and_i_have_selected_non_uk_route
    @locale = "non_uk"
  end

  def and_i_fill_in_the_form(other_grade: nil)
    if @locale == "uk"
      and_i_fill_in_the_uk_form(other_grade)
    else
      and_i_fill_in_the_non_uk_form
    end
  end

  def and_i_fill_in_the_uk_form(other_grade)
    template = build(:degree, :uk_degree_with_details)
    degree_abbreviation = Dttp::CodeSets::DegreeTypes::MAPPING[template.uk_degree][:abbreviation]
    option_text = degree_abbreviation ? "#{template.uk_degree} (#{degree_abbreviation})" : template.uk_degree
    degree_details_page.uk_degree.select(option_text)
    degree_details_page.subject.select(template.subject)
    degree_details_page.institution.select(template.institution)

    if other_grade
      degree_details_page.grade.choose("Other")
      degree_details_page.other_grade.fill_in(with: other_grade)
    else
      degree_details_page.grade.choose(template.grade)
    end

    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def and_i_fill_in_the_non_uk_form
    template = build(:degree, :non_uk_degree_with_details)

    degree_details_page.public_send(template.non_uk_degree.parameterize(separator: "_")).choose
    degree_details_page.subject.select(template.subject)
    degree_details_page.country.select(template.country)
    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def when_i_visit_the_degree_details_page
    degree_details_page.load(trainee_id: trainee.slug, locale_code: @locale)
    expect(degree_details_page).to be_displayed(trainee_id: trainee.slug, locale_code: @locale)
  end

  def then_i_am_redirected_to_the_trainee_degrees_confirmation_page
    expect(degrees_confirm_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_confirm_my_details
    expect(confirm_details_page).to be_displayed(id: trainee.slug, section: "degrees")
    confirm_details_page.confirm.click
    confirm_details_page.continue_button.click
  end

  def and_i_click_continue
    confirm_details_page.continue_button.click
  end

  def then_the_degree_status_should_be(status)
    expect(review_draft_page.degree_details.status.text).to eq(status)
  end

  def then_i_see_a_flash_message
    expect(confirm_details_page).to have_text("Trainee degree deleted")
  end

  def and_i_fill_in_subject_without_selecting_a_value(with:)
    degree_details_page.subject_raw.fill_in with: with
  end

  def then_subject_is_populated(with:)
    expect(degree_details_page.subject_raw.value).to eq(with)
  end

  def and_i_fill_in_degree_without_selecting_a_value(with:)
    degree_details_page.uk_degree_raw.fill_in with: with
  end

  def then_degree_is_populated(with:)
    expect(degree_details_page.uk_degree_raw.value).to eq(with)
  end

  def and_i_fill_in_institution_without_selecting_a_value(with:)
    degree_details_page.institution_raw.fill_in with: with
  end

  def then_institution_is_populated(with:)
    expect(degree_details_page.institution_raw.value).to eq(with)
  end
end
