shared_context 'instructor for crosslisted courses' do
  let(:instructor_id) { '212388' }
end

shared_examples 'a feed including crosslisted courses' do
  it 'merges crosslisted courses' do
    expect(subject.size).to eq 2
    crosslisted_course = subject[0]
    expect(crosslisted_course[:listings].count).to eq 2
    expect(crosslisted_course[:listings][0][:course_code]).to eq 'BUDDSTD C50'
    expect(crosslisted_course[:listings][1][:course_code]).to eq 'S,SEASN C52'
    expect(crosslisted_course[:crossListingHash]).to be_present
  end

  it 'concatenates and links crosslisted sections' do
    crosslisted_sections = subject[0][:sections]
    expect(crosslisted_sections.size).to eq 6
    crosslisted_sections.each_with_index do |section, i|
      expect(section[:courseCode]).to be_present
      if i < 3
        expect(section[:scheduledWithCcn]).to be_nil
      else
        expect(section[:scheduledWithCcn]).to eq crosslisted_sections[i-3][:ccn]
      end
    end
    expect(crosslisted_sections[0][:schedules].size).to eq 1
    expect(crosslisted_sections[0][:instructors].size).to eq 1
    expect(crosslisted_sections[1][:schedules].size).to eq 1
    expect(crosslisted_sections[1][:instructors].size).to eq 2
    expect(crosslisted_sections[2][:schedules].size).to eq 1
    expect(crosslisted_sections[2][:instructors].size).to eq 2

    expect(subject[0][:scheduledSectionCount]).to eq 3
    expect(subject[0][:scheduledSections]).to include({format: 'lecture', count: 1})
    expect(subject[0][:scheduledSections]).to include({format: 'discussion', count: 2})
  end

  it 'does not mark non-crosslisted courses as crosslisted' do
    non_crosslisted_course = subject[1]
    expect(non_crosslisted_course[:listings].count).to eq 1
    expect(non_crosslisted_course[:crossListingHash]).to be_blank
  end
end
