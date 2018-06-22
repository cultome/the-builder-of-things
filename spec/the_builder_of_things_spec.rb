
RSpec.describe TheBuilderOfThings do
  let(:jane){ Thing.new('Jane') }

  it 'has a name' do
    expect(jane.name).to eq 'Jane'
  end

  it 'can define boolean methods on an instance' do
    jane.is_a.person
    jane.is_a.woman
    jane.is_not_a.man

    expect(jane).to be_person # => true
    expect(jane).to be_woman # => true
    expect(jane).not_to be_man # => false
  end

  it 'can define properties on a per instance level' do
    jane.is_the.parent_of.joe

    expect(jane.parent_of).to eq 'joe'
  end

  context 'can define number of child things' do
    it 'when more than 1, an array is created' do
      jane.has(2).legs

      expect(jane.legs.size).to eq 2 # => 2
      expect(jane.legs.first).to be_instance_of Thing # => true
    end

    it 'can define single items' do
      jane.has(1).head

      expect(jane.head).to be_instance_of Thing # => true
    end
  end

  it 'can define number of things in a chainable and natural format' do
    jane.has(2).arms.each { having(1).hand.having(5).fingers }

    expect(jane.arms.first.hand.fingers.size).to eq 5 # => 5
    expect(jane.arms.first.name).to eq "arm"
    expect(jane.arms.first.arm?).to be true
  end


  it 'can define properties on nested items' do
    jane.has(1).head.having(2).eyes.each { being_the.color.blue.with(1).pupil.being_the.color.black }

    expect(jane.head.eyes.first.color).to eq "blue"
    expect(jane.head.eyes.first.pupil.color).to eq "black"
  end

  it 'should allow chaining via the and_the method' do
    jane.has(2).eyes.each { being_the.color.blue.and_the.shape.round }
    expect(jane.eyes.first.color).to eq 'blue'
    expect(jane.eyes.first.shape).to eq 'round'
  end


  describe 'define behavior' do
    before :each do
      jane.can.speak('spoke') do |phrase|
        "#{name} says: #{phrase}"
      end
    end

    it 'can define methods' do
      expect(jane.speak("hello")).to eq "Jane says: hello"
    end

    it 'if past tense was provided then method calls are tracked' do
      jane.speak("hello")
      jane.speak("bye")
      expect(jane.spoke).to eq ["Jane says: hello", "Jane says: bye"]
    end
  end
end
