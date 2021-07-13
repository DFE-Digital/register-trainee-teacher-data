# frozen_string_literal: true

class TraineesController < ApplicationController
  before_action :ensure_trainee_is_not_draft!, only: :show
  before_action :ensure_trainee_is_draft!, only: :destroy
  before_action :save_filter, only: :index
  helper_method :filter_params

  def index
    return redirect_to trainees_path(filter_params) if current_page_exceeds_total_pages?

    @total_trainees_count = filtered_trainees.count

    # We can't use `#draft` to find @draft_trainees since that applies a `WHERE`
    # clause, removing Kaminari's pagination. Hence the use of `#select`.
    @draft_trainees = paginated_trainees.select(&:draft?)
    @completed_trainees = paginated_trainees.reject(&:draft?)
    @apply_draft_trainees = policy_scope(Trainee).draft_with_apply_application
    @training_routes = policy_scope(Trainee).group(:training_route).count.keys

    respond_to do |format|
      format.html
      format.csv { send_data data_export.data, filename: data_export.filename, disposition: :attachment }
    end
  end

  def show
    authorize trainee
    clear_form_stash(trainee)
    page_tracker.save_as_origin!
    render layout: "trainee_record"
  end

  def new
    skip_authorization
    @trainee = Trainee.new
  end

  def create
    if trainee_params[:training_route] == "other"
      redirect_to trainees_not_supported_route_path
    else
      authorize @trainee = Trainee.new(trainee_params.merge(provider_id: current_user.provider_id))
      trainee.set_early_years_course_details
      if trainee.save
        redirect_to review_draft_trainee_path(trainee)
      else
        render :new
      end
    end
  end

  def destroy
    authorize trainee
    trainee.destroy!
    flash[:success] = "Draft deleted"
    redirect_to trainees_path
  end

private

  def trainee
    @trainee ||= Trainee.from_param(params[:id])
  end

  def current_page_exceeds_total_pages?
    paginated_trainees.total_pages.nonzero? && paginated_trainees.current_page > paginated_trainees.total_pages
  end

  def paginated_trainees
    @paginated_trainees ||= filtered_trainees.page(params[:page] || 1)
  end

  def filtered_trainees
    @filtered_trainees ||= Trainees::Filter.call(
      trainees: ordered_trainees,
      filters: filters,
    )
  end

  def ordered_trainees
    sort_scope = filter_params[:sort_by] == "last_name" ? :ordered_by_last_name : :ordered_by_date
    policy_scope(Trainee.ordered_by_drafts.public_send(sort_scope))
  end

  def filters
    @filters ||= TraineeFilter.new(params: filter_params).filters
  end

  def trainee_params
    params.fetch(:trainee, {}).permit(:training_route)
  end

  def filter_params
    params.permit(:subject, :text_search, :sort_by, training_route: [], state: [])
  end

  def save_filter
    FilteredBackLink::Tracker.new(session: session, href: trainees_path).save_path(request.fullpath)
  end

  def data_export
    @data_export ||= Exports::TraineeSearchData.new(filtered_trainees, include_provider: current_user.system_admin?)
  end
end
