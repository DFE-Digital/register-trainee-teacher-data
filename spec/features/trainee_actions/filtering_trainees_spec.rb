# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Filtering trainees" do
  before do
    given_i_am_authenticated
    given_trainees_exist_in_the_system
    given_a_subject_specialism_is_available_for_selection
    when_i_visit_the_trainee_index_page
    then_all_trainees_are_visible
  end

  scenario "can filter by subject" do
    when_i_filter_by_subject("Biology")
    then_only_biology_trainees_are_visible
    then_the_tag_is_visible_for("Biology")
    then_the_select_should_still_show("Biology")
    when_i_remove_a_tag_for("Biology")
    then_all_trainees_are_visible
    when_i_filter_by_subject("All subjects")
    then_all_trainees_are_visible
  end

  scenario "can filter by apply_drafts", feature_imported_from_apply_filter: true do
    when_i_filter_by_apply_draft_status
    then_only_the_apply_draft_trainee_is_visible
  end

  scenario "can filter by status" do
    when_i_filter_by_draft_status
    then_only_the_draft_trainee_is_visible
  end

  scenario "can filter by training route" do
    when_i_filter_by_assessment_only
    then_only_assessment_only_trainee_is_visible
  end

  scenario "can clear filters" do
    when_i_filter_by_subject("Biology")
    then_only_biology_trainees_are_visible
    when_i_clear_filters
    then_all_trainees_are_visible
  end

  scenario "no matches" do
    when_i_filter_by_a_subject_which_returns_no_matches
    then_i_see_a_no_records_found_message
    then_i_should_not_see_sort_links
  end

  context "searching" do
    before { when_i_search_for(search_term) }

    shared_examples_for "a working search" do
      it "returns the correct trainee" do
        then_only_the_searchable_trainee_is_visible
        then_the_tag_is_visible_for(search_term)
      end
    end

    context "by name" do
      let(:search_term) { @searchable_trainee.first_names }

      it_behaves_like "a working search"
    end

    context "by trn" do
      let(:search_term) { @searchable_trainee.trn }

      it_behaves_like "a working search"
    end

    context "by trainee_id" do
      let(:search_term) { @searchable_trainee.trainee_id }

      it_behaves_like "a working search"
    end
  end

  context "exporting", feature_trainee_export: true do
    scenario "exporting with no filter" do
      and_i_export_the_results
      then_i_see_my_trainee_search_results
    end

    scenario "exporting with a filter" do
      when_i_filter_by_subject("Biology")
      and_i_export_the_results
      then_i_see_my_filtered_trainee_search_results
    end
  end

private

  def given_trainees_exist_in_the_system
    @assessment_only_trainee ||= create(:trainee, training_route: TRAINING_ROUTE_ENUMS[:assessment_only])
    @provider_led_postgrad_trainee ||= create(:trainee, training_route: TRAINING_ROUTE_ENUMS[:provider_led_postgrad])
    @biology_trainee ||= create(:trainee, :with_subject_specialism, subject_name: Dttp::CodeSets::CourseSubjects::BIOLOGY)
    @history_trainee ||= create(:trainee, :with_subject_specialism, subject_name: Dttp::CodeSets::CourseSubjects::HISTORY)
    @searchable_trainee ||= create(:trainee, trn: "123")
    @draft_trainee ||= create(:trainee, :draft)
    @withdrawn_trainee ||= create(:trainee, :withdrawn)
    @apply_draft_trainee ||= create(:trainee, :with_apply_application)
    Trainee.update_all(provider_id: @current_user.provider.id)
  end

  def given_a_subject_specialism_is_available_for_selection
    @subject_specialism ||= create(:subject_specialism, name: Dttp::CodeSets::CourseSubjects::CHEMISTRY)
  end

  def when_i_visit_the_trainee_index_page
    trainee_index_page.load
    expect(trainee_index_page).to be_displayed
  end

  def when_i_filter_by_assessment_only
    trainee_index_page.assessment_only_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_draft_status
    trainee_index_page.draft_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_apply_draft_status
    trainee_index_page.imported_from_apply_checkbox.click
    trainee_index_page.apply_filters.click
  end

  def when_i_remove_a_tag_for(value)
    click_link(value)
    trainee_index_page.apply_filters.click
  end

  def when_i_filter_by_subject(value)
    trainee_index_page.subject.select(value)
    trainee_index_page.apply_filters.click
  end

  def when_i_search_for(value)
    trainee_index_page.text_search.fill_in(with: value)
    trainee_index_page.apply_filters.click
  end

  def when_i_clear_filters
    trainee_index_page.clear_filters_link.click
  end

  def when_i_filter_by_a_subject_which_returns_no_matches
    when_i_filter_by_subject(@subject_specialism.name.capitalize)
  end

  def then_i_see_a_no_records_found_message
    expect(trainee_index_page.no_records_found).to have_text("No records found")
  end

  def then_i_should_not_see_sort_links
    expect(trainee_index_page).not_to have_content("Sort by")
  end

  def then_the_checkbox_should_still_be_checked_for(value)
    checkbox = trainee_index_page.public_send("#{value}_checkbox")
    expect(checkbox.checked?).to be(true)
  end

  def then_the_select_should_still_show(value)
    select = trainee_index_page.subject
    expect(select.value.upcase_first).to eq value
  end

  def then_all_trainees_are_visible
    Trainee.all.each { |trainee| expect(trainee_index_page).to have_text(full_name(trainee)) }
  end

  def then_only_biology_trainees_are_visible
    expect(trainee_index_page).to have_text(full_name(@biology_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@history_trainee))
  end

  def then_only_the_searchable_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@searchable_trainee))
    [
      @assessment_only_trainee,
      @provider_led_postgrad_trainee,
      @history_trainee,
      @biology_trainee,
      @draft_trainee,
    ].each do |trainee|
      expect(trainee_index_page).not_to have_text(full_name(trainee))
    end
  end

  def then_only_the_apply_draft_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@apply_draft_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@draft_trainee))
  end

  def then_only_the_draft_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@draft_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@withdrawn_trainee))
  end

  def then_only_assessment_only_trainee_is_visible
    expect(trainee_index_page).to have_text(full_name(@assessment_only_trainee))
    expect(trainee_index_page).not_to have_text(full_name(@provider_led_postgrad_trainee))
  end

  def then_the_tag_is_visible_for(*values)
    values.each do |value|
      expect(trainee_index_page.filter_tags).to have_text(value)
    end
  end

  def full_name(trainee)
    [trainee.first_names, trainee.last_name].join(" ")
  end

  def and_i_export_the_results
    trainee_index_page.export_link.click
  end

  def then_i_see_my_trainee_search_results
    expect(csv_output).to include(@assessment_only_trainee.trainee_id)
    expect(csv_output).to include(@provider_led_postgrad_trainee.trainee_id)
    expect(csv_output).to include(@biology_trainee.trainee_id)
    expect(csv_output).to include(@history_trainee.trainee_id)
  end

  def then_i_see_my_filtered_trainee_search_results
    expect(csv_output).to include(@biology_trainee.trainee_id)

    expect(csv_output).not_to include(@assessment_only_trainee.trainee_id)
    expect(csv_output).not_to include(@provider_led_postgrad_trainee.trainee_id)
    expect(csv_output).not_to include(@searchable_trainee.trainee_id)
    expect(csv_output).not_to include(@history_trainee.trainee_id)
  end

  def csv_output
    @csv_output ||= CSV.parse(trainee_index_page.text).flatten.compact.map(&:strip)
  end
end
