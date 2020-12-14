# frozen_string_literal: true

module ApplicationHelper
  def to_options(array)
    result = array.map do |name|
      OpenStruct.new(name: name)
    end
    result.unshift(OpenStruct.new(name: nil))
    result
  end

  def govuk_button_link_to(body, url, html_options = {})
    html_options = {
      role: "button",
      data: { module: "govuk-button" },
      draggable: false,
    }.merge(html_options)

    html_options[:class] = prepend_css_class("govuk-button", html_options[:class])

    return link_to(url, html_options) { yield } if block_given?

    link_to(body, url, html_options)
  end

private

  def prepend_css_class(css_class, current_class)
    if current_class
      "#{css_class} #{current_class}"
    else
      css_class
    end
  end
end
