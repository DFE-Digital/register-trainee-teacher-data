# frozen_string_literal: true

require "rails_helper"

describe RouteDataManager do
  describe "#update_training_route!" do
    subject do
      described_class.new(trainee: trainee).update_training_route!("provider_led_postgrad")
    end

    let(:progress) { Progress.new(course_details: true, funding: true, personal_details: true) }

    context "when a trainee selects a new route" do
      let(:trainee) { create(:trainee, :assessment_only) }

      it "changes route" do
        expect { subject }
          .to change { trainee.training_route }
          .from(trainee.training_route).to("provider_led_postgrad")
      end

      context "when a trainee has course details" do
        let(:trainee) { create(:trainee, :assessment_only, :with_course_details, progress: progress) }

        it "wipes the course details" do
          expect { subject }
            .to change { trainee.course_code }
            .from(trainee.course_code).to(nil)
            .and change { trainee.course_subject_one }
            .from(trainee.course_subject_one).to(nil)
            .and change { trainee.course_age_range }
            .from(trainee.course_age_range).to([])
            .and change { trainee.course_start_date }
            .from(trainee.course_start_date).to(nil)
            .and change { trainee.course_end_date }
            .from(trainee.course_end_date).to(nil)
        end

        it "resets the course details progress" do
          expect { subject }
            .to change { trainee.progress.course_details }
            .from(true).to(false)
        end

        it "does not change any other progress" do
          expect { subject }
            .not_to change { trainee.progress.personal_details }
            .from(true)
        end
      end

      context "when the trainee has funding" do
        let(:trainee) { create(:trainee, :assessment_only, :with_funding, progress: progress) }

        it "wipes initiative details" do
          expect { subject }
            .to change { trainee.training_initiative }
            .from(trainee.training_initiative).to(nil)
            .and change { trainee.training_route }
            .from(trainee.training_route).to("provider_led_postgrad")
        end

        it "wipes bursary details and changes route" do
          expect { subject }
            .to change { trainee.applying_for_bursary }
            .from(trainee.applying_for_bursary).to(nil)
        end

        it "resets the funding progress" do
          expect { subject }
            .to change { trainee.progress.funding }
            .from(true).to(false)
        end
      end
    end

    context "when a trainee selects the same route" do
      before do
        subject
        trainee.reload
      end

      context "when a trainee has course details" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_course_details) }

        it "does not clear the course details section of the trainee" do
          expect(trainee.course_code).to be_present
          expect(trainee.course_subject_one).to be_present
          expect(trainee.course_age_range).to be_present
          expect(trainee.course_start_date).to be_present
          expect(trainee.course_end_date).to be_present
        end
      end

      context "when a trainee has funding" do
        let(:trainee) { create(:trainee, :provider_led_postgrad, :with_funding) }

        it "does not clear the funding section of the trainee" do
          expect(trainee.training_initiative).to be_present
          expect(trainee.applying_for_bursary).to be(true).or be(false)
        end
      end
    end
  end
end
