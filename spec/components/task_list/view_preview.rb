class TaskList::ViewPreview < ViewComponent::Preview
  def default_state
    render_component TaskList::View.new do |component|
      component.slot(
        :row,
        task_name: "Personal",
        path: "#aardvark",
        status: "completed",
      )
    end
  end

  def with_multiple_status
    render_component TaskList::View.new do |component|
      component.slot(
        :row,
        task_name: "Personal",
        path: "#aardvark",
        status: "completed",
      )

      component.slot(
        :row,
        task_name: "Contact Details",
        path: "#details",
        status: "in progress",
      )

      component.slot(
        :row,
        task_name: "Diversity information",
        path: "#diversity",
        status: "not started",
      )
    end
  end
end
