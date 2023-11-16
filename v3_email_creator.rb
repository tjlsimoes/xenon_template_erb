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

  fee = fee_calc(fee)
  if i['Quer ajudar?'].include?('50%')
    fee += 25
  elsif i['Quer ajudar?'].include?('100%')
    fee += 50                                         # Is it 50 or 45?
  end

  i['QUOTA'] = fee.to_s
end

hashes_array.each do |hash|
  p hash['NOME DO PARTICIPANTE']
  p hash['QUOTA']
end

CSV.open("/home/tjlsimoes/Downloads/Xénon/24_header_change_e.csv", "w") do |csv|
  csv << hashes_array.first.keys # adds the attributes name on the first line
  hashes_array.each do |hash|
    csv << hash.values
  end
end

new_inscriptions = CSV.read('/home/tjlsimoes/Downloads/Xénon/24_header_change_e.csv',
                        headers: true)

p new_inscriptions.headers
new_inscriptions.each do |new_inscription|
  p new_inscription['NOME DO PARTICIPANTE']
  p new_inscription['QUOTA']
end
