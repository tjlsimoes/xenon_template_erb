# The idea was:
# - From the inscriptions' CSV file
#    create an array of inscriptions' hashes.
# - Add QUOTA key to each hash and fill
#    accordingly.
# - Create a new CSV file with the new QUOTA
#    column, so to speak.

require 'csv'

week_activity_pairs = [['MONDAY', 'Segunda-feira [2.ª feira]a'],
                    ['MONDAY', 'Segunda-feira [2.ª feira]b'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]a'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]b'],
                    ['WEDNESDAY', 'Quarta-feira [4.ª feira]'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]a'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]b']]

def fee_calc(fee)
  case fee
  when 'n0'
    fee = 5
  when 'n1'
    fee = 30
  when 'n2'
    fee = 40
  when 'n3'
    fee = 50
  when 's0'
    fee = 45
  when 's1'
    fee = 55
  when 's2'
    fee = 65
  when 's3'
    fee = 75
  end
  return fee
end

def two_brothers_fee_calc(fee_1, fee_2)
  if fee_1 == fee_2
    case fee_1
    when '45'
      fee = 72
    when '55'
      fee = 88
    when '65'
      fee = 104
    when '75'
      fee = 120
    when '30'
      fee = 48
    when '40'
      fee = 64
    when '50'
      fee = 80
    when '5'
      fee = 10
    end
  else
    fee = (fee_1.to_i + fee_2.to_i) * 0.8
  end
  return fee
end

def three_brothers_fee_calc(fee_1, fee_2, fee_3)
  if fee_1 == fee_2 && fee_2 == fee_3
    case fee_1
    when '45'
      fee = 94
    when '55'
      fee = 115
    when '65'
      fee = 136
    when '75'
      fee = 158
    when '30'
      fee = 63
    when '40'
      fee = 84
    when '50'
      fee = 105
    when '5'
      fee = 15
    end
  else
    fee = (fee_1.to_i + fee_2.to_i + fee_3.to_i) * 0.7
  end
  return fee
end

def brothers_fee_calc(brothers)
  if brothers.length == 2
    fee = two_brothers_fee_calc(brothers[0]['QUOTA'], brothers[1]['QUOTA'])
  elsif brothers.length == 3
    fee = three_brothers_fee_calc(brothers[0]['QUOTA'], brothers[1]['QUOTA'], brothers[2]['QUOTA'])
  end
  return fee
end

def financial_aid?(brothers, fee)
  for i in brothers
    if i['Quer ajudar?'].include?('50%')
      fee += 25
    elsif i['Quer ajudar?'].include?('100%')
      fee += 50                                         # Is it 50 or 45?
    end
  end
  return fee
end

def update_brothers_quota(brothers, fee)
  i = 0
  while i < brothers.length
    if i == 0
      brothers[i]['BROTHERS_QUOTA'] = fee.to_s
    else
      brothers[i]['BROTHERS_QUOTA'] = '-'
    end
    i += 1
  end
end

inscriptions = CSV.read('/home/tjlsimoes/Downloads/Xénon/24_header_change.csv',
                        headers: true)

hashes_array = []

inscriptions.each do |inscription|
  hashes_array << inscription.to_h
end

hashes_array.each do |hash|
 hash['QUOTA'] = 0
end

for i in hashes_array
  fee = 'n'
  if i['Inscrever-se nas atividades de sábado?a'] == 'Sim' ||
    i['Inscrever-se nas atividades de sábado?b'] == 'Sim'
    fee = 's'
  end
  nbr = 0
  if i['Inscrever-se nas atividades durante a semana?a'] == 'Sim' ||
    i['Inscrever-se nas atividades durante a semana?b'] == 'Sim'
    for j in week_activity_pairs
      name_to_be = i[j[1]]
      if name_to_be && !(name_to_be.include?('nenhuma')) && !(name_to_be.empty?)
        nbr += 1
      end
    end
  end
  fee = fee + nbr.to_s

  # Removal of addition of financial aid to singular inscription quota's
  # calculation.
  # It would tamper with brothers' joint fee calculation.

  fee = fee_calc(fee)
  # if i['Quer ajudar?'].include?('50%')
  #   fee += 25
  # elsif i['Quer ajudar?'].include?('100%')
  #   fee += 50                                         # Is it 50 or 45?
  # end

  i['QUOTA'] = fee.to_s
end

# hashes_array.each do |hash|
#   p hash['NOME DO PARTICIPANTE']
#   p hash['QUOTA']
# end

CSV.open("/home/tjlsimoes/Downloads/Xénon/24_header_change_e.csv", "w") do |csv|
  csv << hashes_array.first.keys # adds the attributes name on the first line
  hashes_array.each do |hash|
    csv << hash.values
  end
end

new_inscriptions = CSV.read('/home/tjlsimoes/Downloads/Xénon/24_header_change_e.csv',
                        headers: true)

# p new_inscriptions.headers
# new_inscriptions.each do |new_inscription|
#   p new_inscription['NOME DO PARTICIPANTE']
#   p new_inscription['QUOTA']
# end

new_hashes_array = []

new_inscriptions.each do |new_inscription|
  new_hashes_array << new_inscription.to_h
end

new_hashes_array.each do |hash|
  hash['BROTHERS_QUOTA'] = nil
end

new_hashes_length = new_hashes_array.length

i = 0
while i < new_hashes_length
  brothers = []
  if new_hashes_array[i]['BROTHERS_QUOTA'].nil?
    brothers << new_hashes_array[i]
    j = i + 1
    while j < new_hashes_length
      if new_hashes_array[i]['CÓDIGO POSTAL'].split[0] ==
          new_hashes_array[j]['CÓDIGO POSTAL'].split[0]
        brothers << new_hashes_array[j]
      end
      j += 1
    end
    p brothers.map {|brother| brother['NOME DO PARTICIPANTE']}

    if brothers.length > 1
      joint_fee = brothers_fee_calc(brothers)
      joint_fee = financial_aid?(brothers, joint_fee)
    else
      joint_fee = financial_aid?(brothers, brothers[0]['QUOTA'].to_i)  # Joint so to speak. Here it deals with no-brothers'
                                                                  # case.
    end
    update_brothers_quota(brothers, joint_fee)
  end
  i += 1
end

CSV.open("/home/tjlsimoes/Downloads/Xénon/24_header_change_f.csv", "w") do |csv|
  csv << new_hashes_array.first.keys # adds the attributes name on the first line
  new_hashes_array.each do |hash|
    csv << hash.values
  end
end

inscriptions_w_brothers = CSV.read('/home/tjlsimoes/Downloads/Xénon/24_header_change_f.csv',
                        headers: true)

p inscriptions_w_brothers.headers
inscriptions_w_brothers.each do |inscription_w_brothers|
  p inscription_w_brothers['NOME DO PARTICIPANTE']
  p inscription_w_brothers['QUOTA']
  p inscription_w_brothers['BROTHERS_QUOTA']
end
