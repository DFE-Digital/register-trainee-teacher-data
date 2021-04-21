# frozen_string_literal: true

module TraineeHelper
  def trainee_name(trainee)
    [trainee.first_names, trainee.middle_names, trainee.last_name]
      .compact
      .reject(&:empty?)
      .join(" ")
  end

  def view_trainee(trainee)
    if trainee.draft?
      review_draft_trainee_path(trainee)
    else
      trainee_path(trainee)
    end
  end

  def trainees_page_title(trainees, total_trainees_count)
    total_pages = trainees.total_pages
    total_trainees_count_text = pluralize(total_trainees_count, "record")

    if total_pages <= 1
      return I18n.t(
        "components.page_titles.trainees.index",
        total_trainees_count_text: total_trainees_count_text,
      )
    end

    I18n.t(
      "components.page_titles.trainees.paginated_index",
      current_page: trainees.current_page,
      total_pages: total_pages,
      total_trainees_count_text: total_trainees_count_text,
    )
  end

  def show_publish_courses?(trainee)
    courses_available = trainee.available_courses.present?
    manual_entry_chosen = PublishCourseDetailsForm.new(trainee).manual_entry_chosen?

    FeatureService.enabled?(:publish_course_details) && courses_available && !manual_entry_chosen
  end

  def last_updated_event_for(trainee)
    Trainees::CreateTimeline.call(audits: trainee.own_and_associated_audits).first
  end
end
