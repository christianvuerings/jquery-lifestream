describe Oec::CommandLine do

  it 'should pay attention ENV variables' do
    src_path = '/path/to/src'
    dest_path = '/path/to/dest'
    ENV['src'] = src_path
    ENV['dest'] = dest_path
    ENV['options'] = 'd , y'
    cmd_line = Oec::CommandLine.new
    expect(cmd_line.src_dir).to eq src_path
    expect(cmd_line.dest_dir).to eq dest_path
    expect(cmd_line.is_debug_mode).to be_truthy
    expect(cmd_line.is_limited_diff).to be_truthy
  end

  it 'should have default for each property' do
    ENV['src'] = ENV['dest'] = ENV['options'] = nil
    cmd_line = Oec::CommandLine.new
    expect(cmd_line.src_dir).should_not be_nil
    expect(cmd_line.dest_dir).should_not be_nil
    expect(cmd_line.is_debug_mode).to_not be_truthy
    expect(cmd_line.is_limited_diff).to_not be_truthy
  end

  it 'should parse comma-separated values of "options" arg' do
    ENV['options'] = ' Y '
    expect(Oec::CommandLine.new.is_limited_diff).to be_truthy
    expect(Oec::CommandLine.new.is_debug_mode).to_not be_truthy
  end

  it 'should reference logic of department-registry to pick up BIOLOGY-related relationships' do
    ENV['departments'] = 'POL SCI, CHEM, INTEGBI'
    departments = Oec::CommandLine.new.departments
    departments.should match_array %w(BIOLOGY INTEGBI MCELLBI CHEM POL\ SCI)
  end

  it 'should not pull in BIOLOGY-related relationships' do
    ENV['departments'] = 'POL SCI, CHEM'
    departments = Oec::CommandLine.new.departments
    departments.should match_array %w(CHEM POL\ SCI)
  end

  it 'should pull all OEC departments when none specified' do
    ENV['departments'] = nil
    Oec::CommandLine.new.departments.should be_empty
  end

end
