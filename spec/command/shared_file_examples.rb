RSpec.shared_examples 'common file command specs' do
  file_attributes = %i[file_path]

  describe 'attributes' do

    it 'should have the correct attributes' do
      expect(described_class.attribute_names).to include(*file_attributes.map(&:to_s))
    end

    it 'should not include activity_descriptor in the attributes' do
      expect(described_class.attribute_names).not_to include(:activity_descriptor)
    end

    describe 'validation' do

      it 'should be valid' do
        expect(subject).to be_valid
      end

      file_attributes.each do |attribute_name|
        it "should require #{attribute_name} to be set" do
          subject.assign_attributes(attribute_name => nil)

          expect(subject).to be_invalid
          expect(subject.errors).to be_of_kind(attribute_name, :blank)
        end
      end

    end

  end

end
