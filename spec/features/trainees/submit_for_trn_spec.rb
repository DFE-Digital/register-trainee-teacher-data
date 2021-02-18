# frozen_string_literal: true

require "rails_helper"

feature "submit for TRN" do
  include TraineeHelper
  background { given_i_am_authenticated }

  before do
    stub_dttp_batch_request
  end

  describe "submission" do
    context "when all sections are completed" do
      let(:trainee) do
        create(
          :trainee,
          :with_start_date,
          :with_programme_details,
          provider: current_user.provider,
          ethnic_background: "some background",
          nationalities: [create(:nationality)],
          disabilities: [create(:disability)],
          degrees: [create(:degree, :uk_degree_with_details)],
          progress: {
            degrees: true,
            diversity: true,
            contact_details: true,
            personal_details: true,
            programme_details: true,
            training_details: true,
          },
        )
      end

      scenario "can submit the application" do
        when_i_am_viewing_the_review_draft_page
        and_i_want_to_review_record_before_submitting_for_trn
        then_i_review_the_trainee_data
        and_i_click_the_submit_for_trn_button
        and_i_am_redirected_to_the_success_page
      end

      scenario "displays trainee name" do
        when_i_am_viewing_the_review_draft_page
        and_i_want_to_review_record_before_submitting_for_trn
        then_i_review_the_trainee_data
        expect(page).to have_content(trainee_name(trainee))
      end
    end

    context "when all sections are not completed" do
      before do
        given_a_trainee_exists
      end

      scenario "shows me an error if I try to submit" do
        when_i_am_viewing_the_review_draft_page
        and_i_want_to_review_record_before_submitting_for_trn
        then_i_review_the_trainee_data
        and_i_click_the_submit_for_trn_button
        then_i_see_an_error_message
      end
    end
  end

  describe "navigation" do
    context "clicking back to draft record" do
      scenario "returns the user to the summary page" do
        given_a_trainee_exists
        and_i_am_on_the_check_details_page
        when_i_click_back_to_draft_record
        then_i_am_redirected_to_the_review_draft_page
      end
    end

    context "clicking return to draft record later" do
      scenario "returns the user to the trainee records page" do
        given_a_trainee_exists
        and_i_am_on_the_check_details_page
        when_i_click_return_to_draft_later
        then_i_am_redirected_to_the_trainee_records_page
      end
    end
  end

  def when_i_am_viewing_the_review_draft_page
    review_draft_page.load(id: trainee.slug)
  end

  def and_i_want_to_review_record_before_submitting_for_trn
    review_draft_page.review_this_record_link.click
  end

  def then_i_do_not_see_the_review_details_link
    expect(review_draft_page).not_to have_review_this_record_link
  end

  def then_i_review_the_trainee_data
    expect(check_details_page).to be_displayed(id: trainee.slug)
  end

  def then_i_am_redirected_to_the_review_draft_page
    expect(review_draft_page).to be_displayed(id: trainee.slug)
  end

  def then_i_see_an_error_message
    expect(page).to have_content(
      I18n.t("activemodel.errors.models.trn_submission_form.attributes.trainee.incomplete"),
    )
  end

  def and_i_click_the_submit_for_trn_button
    check_details_page.submit_button.click
  end

  def and_i_am_redirected_to_the_success_page
    expect(trn_success_page).to be_displayed(trainee_id: trainee.slug)
  end

  def and_i_am_on_the_check_details_page
    check_details_page.load(id: trainee.slug)
  end

  def when_i_click_back_to_draft_record
    check_details_page.back_to_draft_record.click
  end

  def when_i_click_return_to_draft_later
    check_details_page.return_to_draft_later.click
  end

  def then_i_am_redirected_to_the_trainee_records_page
    expect(trainee_index_page).to be_displayed
  end
end
