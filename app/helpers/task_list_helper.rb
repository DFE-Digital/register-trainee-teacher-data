# frozen_string_literal: true

module TaskListHelper
  def row_helper(trainee, task)
    task_list = {
      publish_course_details:
        {
          task_name: "Course details",
          path: edit_trainee_publish_course_details_path(trainee),
          confirm_path: trainee_course_details_confirm_path(trainee),
          classes: "course-details",
          status: ProgressService.call(
            validator: ValidatePublishCourseForm.new(trainee),
            progress_value: trainee.progress.course_details,
          ).status,
        },

      course_details:
        {
          task_name: "Course details",
          path: edit_trainee_course_details_path(trainee),
          confirm_path: trainee_course_details_confirm_path(trainee),
          classes: "course-details",
          status: ProgressService.call(
            validator: CourseDetailsForm.new(trainee),
            progress_value: trainee.progress.course_details,
          ).status,
        },

      training_details:
        {
          task_name: (trainee.apply_application? ? "Training details" : "Trainee start date and ID"),
          path: edit_trainee_training_details_path(trainee),
          confirm_path: trainee_training_details_confirm_path(trainee),
          classes: "training-details",
          hint_text: "Start date and trainee ID",
          status: ProgressService.call(
            validator: TrainingDetailsForm.new(trainee),
            progress_value: trainee.progress.training_details,
          ).status,
        },

      placement_details:
        {
          task_name: "Placement details",
          path: review_draft_trainee_path(trainee),
          confirm_path: review_draft_trainee_path(trainee),
          classes: "placement-details",
          status: ProgressService.call(
            validator: PlacementDetailForm.new(trainee),
            progress_value: trainee.progress.placement_details,
          ).status,
        },

      school_details:
        {
          task_name: school_details_title(trainee.training_route),
          path: edit_trainee_lead_schools_path(trainee),
          confirm_path: trainee_schools_confirm_path(trainee),
          classes: "school-details",
          status: ProgressService.call(
            validator: Schools::FormValidator.new(trainee),
            progress_value: trainee.progress.schools,
          ).status,
        },

      trainee_data:
        {
          task_name: "Trainee data",
          path: edit_trainee_apply_trainee_data_path(trainee),
          confirm_path: edit_trainee_apply_trainee_data_path(trainee),
          classes: "trainee-data",
          status: "review",
        },

      personal_details:
      {
        task_name: "Personal details",
        path: edit_trainee_personal_details_path(trainee),
        confirm_path: trainee_personal_details_confirm_path(trainee),
        classes: "personal-details",
        status: ProgressService.call(
          validator: PersonalDetailsForm.new(trainee),
          progress_value: trainee.progress.personal_details,
        ).status,
      },

      contact_details:
        {
          task_name: "Contact details",
          path: edit_trainee_contact_details_path(trainee),
          confirm_path: trainee_contact_details_confirm_path(trainee),
          classes: "contact-details",
          status: ProgressService.call(
            validator: ContactDetailsForm.new(trainee),
            progress_value: trainee.progress.contact_details,
          ).status,
        },

      diversity_information:
        {
          task_name: "Diversity information",
          path: edit_trainee_diversity_disclosure_path(trainee),
          confirm_path: trainee_diversity_confirm_path(trainee),
          classes: "diversity-details",
          status: ProgressService.call(
            validator: Diversities::FormValidator.new(trainee),
            progress_value: trainee.progress.diversity,
          ).status,
        },

      degree:
        {
          task_name: "Degree",
          path: trainee_degrees_new_type_path(trainee),
          confirm_path: trainee_degrees_confirm_path(trainee),
          status: ProgressService.call(
            validator: DegreesForm.new(trainee),
            progress_value: trainee.progress.degrees,
          ).status,
          classes: "degree-details",
        },

      funding_active:
        {
          task_name: "Funding",
          path: edit_trainee_funding_training_initiative_path(trainee),
          confirm_path: trainee_funding_confirm_path(trainee),
          status: ProgressService.call(
            validator: Funding::TrainingInitiativesForm.new(trainee),
            progress_value: trainee.progress.funding,
          ).status,
          classes: "funding",
        },

      funding_inactive:
        {
          task_name: "Funding",
          path: nil,
          confirm_path: nil,
          status: "cannot start yet",
          classes: "funding",
          hint_text: "Complete course details first",
          active: false,
        },
    }

    task_list[task]
  end

private

  def school_details_title(route)
    tuition_title = I18n.t("components.review_draft.draft.schools.titles.tuition")
    salaried_title = I18n.t("components.review_draft.draft.schools.titles.salaried")
    pg_teaching_apprenticeship_title = I18n.t("components.review_draft.draft.schools.titles.pg_teaching_apprenticeship")

    {
      school_direct_tuition_fee: tuition_title,
      school_direct_salaried: salaried_title,
      pg_teaching_apprenticeship: pg_teaching_apprenticeship_title,
    }[route.to_sym]
  end
end
