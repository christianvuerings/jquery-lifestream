describe Oec::DepartmentRegistry do

    it 'should load OEC settings when no departments specified' do
      registry = Oec::DepartmentRegistry.new
      registry.should match_array Settings.oec.departments
    end

    it 'should add BIOLOGY if, for example, INTEGBI is requested' do
      registry = Oec::DepartmentRegistry.new %w(INTEGBI 'POL SCI')
      registry.should match_array %w(BIOLOGY INTEGBI MCELLBI 'POL SCI')
    end

    it 'should add sister departments' do
      registry = Oec::DepartmentRegistry.new %w(MCELLBI)
      registry.should match_array %w(BIOLOGY INTEGBI MCELLBI)
    end

    it 'should add, for example, INTEGBI because BIOLOGY is present' do
      registry = Oec::DepartmentRegistry.new %w('POL SCI' BIOLOGY)
      registry.should match_array %w(BIOLOGY INTEGBI MCELLBI 'POL SCI')
    end

    it 'should add nothing if BIOLOGY and related are not found' do
      registry = Oec::DepartmentRegistry.new %w('POL SCI' STAT)
      registry.should match_array %w('POL SCI' STAT)
    end

end
