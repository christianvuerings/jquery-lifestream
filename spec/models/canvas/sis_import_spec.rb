describe Canvas::SisImport do

  let(:fake_proxy) { Canvas::SisImport.new(fake: true) }

  it 'should get the status of an existing import' do
    status = fake_proxy.import_status('5842657')
    expect(status['progress']).to eq 100
    expect(status['workflow_state']).to eq 'imported'
    expect(fake_proxy.import_successful? status).to be_truthy
  end

  describe '#import_successful?' do
    let(:sis_import_status_hash) do
      {
        'id'=>6220856,
        'workflow_state'=>'imported',
        'data'=>{
          'import_type'=>'instructure_csv',
          'supplied_batches'=>['enrollment'],
          'counts'=>{
            'accounts'=>0,
            'terms'=>0,
            'abstract_courses'=>0,
            'courses'=>0,
            'sections'=>0,
            'xlists'=>0,
            'users'=>0,
            'enrollments'=>121,
            'groups'=>0,
            'group_memberships'=>0,
            'grade_publishing_results'=>0,
          }
        },
        'progress'=>100,
        'created_at'=>'2014-02-12T00:49:46Z',
        'ended_at'=>'2014-02-12T03:18:41Z',
        'updated_at'=>'2014-02-12T03:18:41Z',
      }
    end
    context 'when import completed' do

      context 'and state is imported' do
        let(:sis_import_status_json) { JSON.parse(sis_import_status_hash.to_json) }
        it 'returns true' do
          result = fake_proxy.import_successful?(sis_import_status_json)
          expect(result).to be_truthy
        end
      end

      context 'and state is imported with messages' do
        let(:sis_import_status_json) do
          JSON.parse(sis_import_status_hash.merge({
            'workflow_state' => 'imported_with_messages',
            'processing_warnings'=>[
              ['attachment_4500280720140212-5774-dzagti.csv', 'No user_id given for an enrollment'],
              ['attachment_4500280720140212-5774-dzagti.csv', 'No user_id given for an enrollment'],
            ],
          }).to_json)
        end

        it 'logs warning' do
          logger_double = double
          allow(Canvas::SisImport).to receive(:logger).and_return(logger_double)
          expected_log_message = "SIS import partially succeeded; status: #{sis_import_status_json}"
          expect(logger_double).to receive(:warn).with(expected_log_message).and_return nil
          fake_proxy.import_successful?(sis_import_status_json)
        end

        it 'returns true' do
          result = fake_proxy.import_successful?(sis_import_status_json)
          expect(result).to be_truthy
        end
      end
    end

    context 'when no response or progress not completed' do
      let(:sis_import_status_json) do
        JSON.parse(sis_import_status_hash.merge({'workflow_state' => 'failed', 'progress' => 85}).to_json)
      end

      it 'logs error' do
        logger_double = double
        allow(Canvas::SisImport).to receive(:logger).and_return(logger_double)
        expected_log_message = "SIS import failed or incompletely processed; status: #{sis_import_status_json}"
        expect(logger_double).to receive(:error).with(expected_log_message).and_return nil
        fake_proxy.import_successful?(sis_import_status_json)
      end
      it 'returns false' do
        result = fake_proxy.import_successful?(sis_import_status_json)
        expect(result).to be_falsey
      end
    end
  end

  context 'in dry-run mode' do
    before do
      allow(Settings.canvas_proxy).to receive(:dry_run_import).and_return('anything')
    end
    it 'does not tell Canvas to import the CSV files' do
      expect_any_instance_of(Canvas::SisImport).to receive(:post_sis_import).never
      subject.import_users('bogus.csv')
    end
  end

end
