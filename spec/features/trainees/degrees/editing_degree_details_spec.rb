require "rails_helper"

RSpec.feature "editing a degree" do
  context "UK degree" do
    scenario "without filling in the fields" do
      given_a_trainee_with_an_uk_degree_exists
      when_i_visit_the_degree_details_page
      and_i_click_the_continue_button
      then_i_see_the_error_summary
    end

    scenario "filling in the fields correct" do
      given_a_trainee_with_an_uk_degree_exists
      when_i_visit_the_degree_details_page
      and_i_fill_the_degree_details
      and_i_click_the_continue_button
      then_i_am_on_the_summary_page
    end
  end

  xcontext "Non UK degree" do
    scenario "without filling in the fields" do
      given_a_trainee_with_an_non_uk_degree_exists ## question about this? (whats the difference)
      when_i_visit_the_non_uk_degree_details_page
      and_i_click_the_continue_button
      then_i_am_on_the_summary_page
    end

    scenario "filling the fields correct" do
      given_a_trainee_with_an_non_uk_degree_exists
      when_i_visit_the_non_degree_details_page
      and_i_fill_the_non_uk_degree_details
      and_i_click_the_continue_button
      then_i_am_on_the_summary_page
    end
  end

private

  def given_a_trainee_with_an_uk_degree_exists
    trainee
  end

  def given_a_trainee_with_an_non_uk_degree_exists
    non_uk_trainee
  end

  def and_i_click_the_continue_button
    degree_details_page.continue.click
  end

  def and_i_fill_the_non_uk_degree_details
    template = build(:degree, :non_uk_degree_with_details)
    degree_details_page.degree_subject.select(template.degree_subject)
    degree_details_page.degree_country.select(template.country)
    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def and_i_fill_the_degree_details
    template = build(:degree, :uk_degree_with_details)

    degree_details_page.degree_subject.select(template.degree_subject)
    degree_details_page.institution.select(template.institution)
    degree_details_page.degree_grade.choose(template.degree_grade)
    degree_details_page.graduation_year.fill_in(with: template.graduation_year)
  end

  def when_i_visit_the_non_uk_degree_details_page
    degree_details_page.load(trainee_id: non_uk_trainee.id,
                             id: non_uk_trainee.degrees.first.id)
  end

  def when_i_visit_the_degree_details_page
    degree_details_page.load(trainee_id: trainee.id,
                             id: trainee.degrees.first.id)
  end

  def then_i_am_on_the_summary_page
    summary_page.load(id: @trainee.id)
    expect(summary_page).to be_displayed
  end

  def then_i_see_the_error_summary
    expect(degree_details_page.error_summary).to be_visible
  end

  def degree_details_page
    @degree_details_page ||= PageObjects::Trainees::DegreeDetails.new
  end

  def summary_page
    @summary_page ||= PageObjects::Trainees::Summary.new
  end

  def trainee
    @trainee ||= create(:degree, :uk_degree_type).trainee
  end

  def non_uk_trainee
    @non_uk_trainee = create(:degree, :non_uk_degree_type).trainee
  end

  def degree
    trainee.degrees.first
  end
end
