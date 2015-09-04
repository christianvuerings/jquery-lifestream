# encoding: utf-8

shared_examples 'non-empty alert' do
  it 'checks if an alert is non-empty' do
    alert = subject.get_latest
    expect(alert[:title]).to be_present
    expect(alert[:link]).to be_present
    expect(alert[:timestamp][:epoch]).to be_present
  end
end

shared_examples 'xml with multibyte characters' do
  it 'should parse' do
    alert = subject.get_latest
    expect(alert[:title]).to eq '¡El Señor González se zampó un extraño sándwich de vodka y ajo! (¢, ®, ™, ©, •, ÷, –, ¿)'
    expect(alert[:link]).to eq 'hדג סקרן שט בים מאוכזב ולפתע מצא לו חברה'
    expect(alert[:snippet]).to eq 'جامع الحروف عند البلغاء يطلق على الكلام المركب من جميع حروف التهجي بدون تكرار أحدها في لفظ واحد، أما في لفظين فهو جائز'
  end
end

shared_examples 'invalid alert xml' do
  its(:get_latest) { is_expected.to eq '' }
end
