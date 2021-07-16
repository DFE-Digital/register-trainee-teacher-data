# frozen_string_literal: true

require "rails_helper"

module CollapsedSection
  describe View do
    alias_method :component, :page
    let(:title) { "title" }
    let(:link_text) { "link_text" }
    let(:hint_text) { "hint_text" }
    let(:url) { "url" }

    context "default" do
      before do
        render_inline(
          described_class.new(title: title, link_text: link_text, hint_text: hint_text, url: url),
        )
      end

      it "renders the title" do
        expect(component).to have_css(".app-inset-text__title", text: title)
      end

      it "renders the link" do
        expect(component).to have_link(link_text, href: url)
      end

      it "renders the hint text" do
        expect(component).to have_css(".govuk-hint", text: hint_text)
      end

      it "renders the correct css classes" do
        expect(component).to have_css(".govuk-inset-text.app-inset-text--narrow-border.app-inset-text--important")
      end
    end

    context "error" do
      before do
        render_inline(
          described_class.new(title: title, link_text: link_text, url: url, error: true),
        )
      end

      it "renders the title" do
        expect(component).to have_css(".app-inset-text__title", text: title)
      end

      it "renders the link" do
        expect(component).to have_link(link_text, href: url)
      end

      it "renders the correct css classes" do
        expect(component).to have_css(".govuk-inset-text.app-inset-text--narrow-border.app-inset-text--error")
      end
    end
  end
end
