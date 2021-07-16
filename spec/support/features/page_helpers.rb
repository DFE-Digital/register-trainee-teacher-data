# frozen_string_literal: true

module Features
  module PageHelpers
    def trainee_index_page
      @trainee_index_page ||= PageObjects::Trainees::Index.new
    end

    def request_an_account_page
      @request_an_account_page ||= PageObjects::RequestAnAccount.new
    end

    def new_trainee_page
      @new_trainee_page ||= PageObjects::Trainees::New.new
    end

    def trainee_edit_training_route_page
      @trainee_edit_training_route_page = PageObjects::Trainees::EditTrainingRoute.new
    end

    def training_details_page
      @training_details_page ||= PageObjects::Trainees::TrainingDetails.new
    end

    def confirm_training_details_page
      @confirm_training_details_page ||= PageObjects::Trainees::ConfirmTrainingDetails.new
    end

    def confirm_schools_page
      @confirm_schools_page ||= PageObjects::Trainees::ConfirmSchoolDetails.new
    end

    def record_page
      @record_page ||= PageObjects::Trainees::Record.new
    end

    def review_draft_page
      @review_draft_page ||= PageObjects::Trainees::ReviewDraft.new
    end

    def confirm_draft_deletions_page
      @confirm_draft_deletions_page ||= PageObjects::Trainees::ConfirmDraftDeletions.new
    end

    def confirm_details_page
      @confirm_page ||= PageObjects::Trainees::ConfirmDetails.new
    end

    def disability_disclosure_page
      @disability_disclosure_page ||= PageObjects::Trainees::Diversities::DisabilityDisclosure.new
    end

    def ethnic_background_page
      @ethnic_background_page ||= PageObjects::Trainees::Diversities::EthnicBackground.new
    end

    def ethnic_group_page
      @ethnic_group_page ||= PageObjects::Trainees::Diversities::EthnicGroup.new
    end

    def diversity_disclosure_page
      @diversity_disclosure_page ||= PageObjects::Trainees::Diversities::Disclosure.new
    end

    def diversities_confirm_page
      @diversities_confirm_page ||= PageObjects::Trainees::Diversities::ConfirmDetails.new
    end

    def new_provider_page
      @new_provider_page ||= PageObjects::Providers::New.new
    end

    def provider_index_page
      @provider_index_page ||= PageObjects::Providers::Index.new
    end

    def provider_show_page
      @provider_show_page ||= PageObjects::Providers::Show.new
    end

    def dttp_provider_index_page
      @provider_index_page ||= PageObjects::DttpProviders::Index.new
    end

    def validation_errors_index_page
      @validation_errors_index_page ||= PageObjects::ValidationErrors::Index.new
    end

    def sign_in_page
      @sign_in_page ||= PageObjects::SignIn.new
    end

    def degree_type_page
      @degree_type_page ||= PageObjects::Trainees::DegreeType.new
    end

    def degree_details_page
      @degree_details_page ||= PageObjects::Trainees::NewDegreeDetails.new
    end

    def degrees_confirm_page
      @degrees_confirm_page ||= PageObjects::Trainees::DegreesConfirm.new
    end

    def edit_degree_details_page
      @edit_degree_details_page ||= PageObjects::Trainees::EditDegreeDetails.new
    end

    def disabilities_page
      @disabilities_page ||= PageObjects::Trainees::Diversities::Disabilities.new
    end

    def not_supported_route_page
      @not_supported_route_page ||= PageObjects::Trainees::NotSupportedRoute.newx
    end

    def deferral_page
      @defer_date_page ||= PageObjects::Trainees::Deferral.new
    end

    def deferral_confirmation_page
      @deferral_confirmation_page ||= PageObjects::Trainees::ConfirmDeferral.new
    end

    def contact_details_page
      @contact_details_page ||= PageObjects::Trainees::ContactDetails.new
    end

    def personal_details_page
      @personal_details_page ||= PageObjects::Trainees::PersonalDetails.new
    end

    def course_details_page
      @course_details_page ||= PageObjects::Trainees::CourseDetails.new
    end

    def apply_registrations_course_details_page
      @apply_registrations_course_details_page ||= PageObjects::Trainees::ApplyRegistrations::CourseDetails.new
    end

    def apply_registrations_confirm_course_page
      @apply_registrations_confirm_course_page ||= PageObjects::Trainees::ApplyRegistrations::ConfirmCourse.new
    end

    def publish_course_details_page
      @publish_course_details_page ||= PageObjects::Trainees::PublishCourseDetails.new
    end

    def subject_specialism_page
      @subject_specialism_page ||= PageObjects::Trainees::SubjectSpecialism.new
    end

    def language_specialism_page
      @language_specialism_page ||= PageObjects::Trainees::LanguageSpecialism.new
    end

    def confirm_publish_course_page
      @confirm_publish_course_page ||= PageObjects::Trainees::ConfirmPublishCourse.new
    end

    def trainee_id_edit_page
      @trainee_id_edit_page ||= PageObjects::Trainees::EditTraineeId.new
    end

    def confirm_trainee_id_page
      @confirm_trainee_id_page ||= PageObjects::Trainees::ConfirmTraineeId.new
    end

    def trainee_start_date_edit_page
      @trainee_id_edit_page ||= PageObjects::Trainees::EditTraineeStartDate.new
    end

    def outcome_date_edit_page
      @outcome_date_page ||= PageObjects::Trainees::EditOutcomeDate.new
    end

    def confirm_outcome_details_page
      @confirm_outcome_details_page ||= PageObjects::Trainees::ConfirmOutcomeDetails.new
    end

    def trn_success_page
      @trn_success_page ||= PageObjects::Trainees::TrnSuccess.new
    end

    def check_details_page
      @check_details_page ||= PageObjects::Trainees::CheckDetails::Show.new
    end

    def timeline_page
      @timeline_page ||= PageObjects::Trainees::Timeline.new
    end

    def withdrawal_page
      @withdrawal_page ||= PageObjects::Trainees::Withdrawal.new
    end

    def withdrawal_confirmation_page
      @withdrawal_confirmation_page ||= PageObjects::Trainees::ConfirmWithdrawal.new
    end

    def reinstatement_page
      @reinstatement_page ||= PageObjects::Trainees::Reinstatement.new
    end

    def reinstatement_confirmation_page
      @reinstatement_confirmation_page ||= PageObjects::Trainees::ConfirmReinstatement.new
    end

    def start_page
      @start_page ||= PageObjects::Start.new
    end

    def lead_schools_search_page
      @lead_schools_search_page ||= PageObjects::Trainees::LeadSchoolsSearch.new
    end

    def employing_schools_search_page
      @employing_schools_search_page ||= PageObjects::Trainees::EmployingSchoolsSearch.new
    end

    def edit_lead_school_page
      @edit_lead_school_page ||= PageObjects::Trainees::EditLeadSchool.new
    end

    def edit_employing_school_page
      @edit_employing_school_page ||= PageObjects::Trainees::EditEmployingSchool.new
    end

    def accessibility_page
      @accessibility_page ||= PageObjects::Accessibility.new
    end

    def recommended_for_qts_page
      @recommended_for_qts_page ||= PageObjects::Trainees::RecommendedForQts.new
    end

    def training_initiative_page
      @training_initiative_page ||= PageObjects::Trainees::Funding::TrainingInitiative.new
    end

    def bursary_page
      @bursary_page ||= PageObjects::Trainees::Funding::Bursary.new
    end

    def edit_funding_page
      @edit_funding_page ||= PageObjects::Trainees::EditTraineeFunding.new
    end

    def confirm_funding_page
      @confirm_funding_page ||= PageObjects::Trainees::ConfirmFunding.new
    end

    def apply_trainee_data_page
      @apply_trainee_data_pate ||= PageObjects::Trainees::ApplyTraineeData.new
    end

    def cookies_page
      @cookies_page ||= PageObjects::Cookies.new
    end

    def privacy_policy_page
      @privacy_policy_page ||= PageObjects::PrivacyPolicy.new
    end

    def not_started
      progress_with_prefix(Progress::STATUSES[:not_started])
    end

    def in_progress
      progress_with_prefix(Progress::STATUSES[:in_progress])
    end

    def completed
      progress_with_prefix(Progress::STATUSES[:completed])
    end

  private

    def progress_with_prefix(status)
      "Status #{status}"
    end
  end
end
