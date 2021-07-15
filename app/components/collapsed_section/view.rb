# frozen_string_literal: true

class CollapsedSection::View < ViewComponent::Base
  attr_accessor :title, :url, :link_text, :hint_text, :error

  def initialize(title:, link_text: nil, url: nil, hint_text: nil, error: false)
    @url = url
    @link_text = link_text
    @title = title
    @hint_text = hint_text
    @error = error
  end
end
