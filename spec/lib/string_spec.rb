# coding: UTF-8

require 'spec_helper'

describe String do

  it 'should normalize string for filtering' do
    expect('Mendes   de Sá'.name_normalization).to eq('mendes de sa')
    expect(' Vale S/A'.name_normalization).to eq('vale')
    expect('Vale S/A '.name_normalization).to eq('vale')
    expect('Vale S.A. '.name_normalization).to eq('vale')
    expect('Tábua S/A. '.name_normalization).to eq('tabua')
    expect('Saúde S/A. '.name_normalization).to eq('saude')
  end

end
