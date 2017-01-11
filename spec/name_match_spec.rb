require_relative '../company_name_match'

describe 'Test Company Name matching' do

  it 'compares names with punctution differences' do

    match = CompanyNameMatcher::Match.new('John Doe Inc', 'John Doe Inc.')

    expect(match.score).to eq 100
  end

  it 'compares names with abbreviation differences' do

    match = CompanyNameMatcher::Match.new('John Doe Inc', 'John Doe Incorporated')

    expect(match.score).to eq 95
  end

  it 'compares names with locales differences' do

    # two accent changes should deduct 6 from the score
    match = CompanyNameMatcher::Match.new('Âbba Singérs', 'Abba Singers')

    expect(match.score).to eq 94
  end

  it 'compares names with common word differences' do

    # two accent changes should deduct 6 from the score
    match = CompanyNameMatcher::Match.new('Abba Singers', 'The Abba Singers')

    expect(match.score).to eq 90
  end

  it 'compares names with missing words' do

    match = CompanyNameMatcher::Match.new('Big Trampoline Company', 'Big Trampoline Delivery Company')

    expect(match.score).to eq 75
  end

  it 'compares names with different word order' do

    match = CompanyNameMatcher::Match.new('Big Trampoline Delivery Company', 'Big Trampoline Company Delivery')

    expect(match.score).to eq 70
  end

  it 'compares a mix of differences' do

    match = CompanyNameMatcher::Match.new('Jolly Green Giant Corp', 'The Jolly Green Giant Corporation')

    expect(match.score).to eq 85
  end


end
