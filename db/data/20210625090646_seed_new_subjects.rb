# frozen_string_literal: true

class SeedNewSubjects < ActiveRecord::Migration[6.1]
  def up
    Dttp::CodeSets::AllocationSubjects::MAPPING.each do |allocation_subject, metadata|
      allocation_subject = AllocationSubject.find_or_create_by!(name: allocation_subject)
      if allocation_subject.name == Dttp::CodeSets::AllocationSubjects::PRIMARY
        allocation_subject.subject_specialisms.find_or_create_by!(name: Dttp::CodeSets::CourseSubjects::PRIMARY_TEACHING)
      else
        metadata[:subject_specialisms].each do |subject_specialism|
          allocation_subject.subject_specialisms.find_or_create_by!(name: subject_specialism[:name])
        end
      end
    end

    SEED_BURSARIES.each do |b|
      bursary = Bursary.find_or_create_by!(training_route: b.training_route, amount: b.amount)
      b.allocation_subjects.map do |subject|
        allocation_subject = AllocationSubject.find_by!(name: subject)
        bursary.bursary_subjects.find_or_create_by!(allocation_subject: allocation_subject)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
