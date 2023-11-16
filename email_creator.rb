require 'csv'
puts 'CSV Parsing and HTML building initialized.'

def name_replacement(new_email, name, inscription, inscriptions_name)
  name_to_be = inscription["#{inscriptions_name}"]
  name_to_be = name_to_be.split[0].capitalize unless name_to_be.nil?
  if name_to_be
    new_email.gsub!(name, name_to_be)
  end
  return new_email
end

def activity_replacement(new_email, name, inscription, inscriptions_name, nbr = 0)
  name_to_be = inscription["#{inscriptions_name}"]
  if name_to_be && !(name_to_be.include?('nenhuma')) && !(name_to_be.empty?)
    nbr += 1
    new_email.gsub!(name, name_to_be)
  end
  return [new_email, nbr]
end

def empty_days_replacement(new_email, name)
    new_email.gsub!(name, '')
  return new_email
end

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


inscriptions = CSV.open('/home/tjlsimoes/Downloads/Xénon/24_header_change.csv',
                        headers: true)
name_pairs = [['SONS_NAME', 'NOME DO PARTICIPANTE'], ['MOTHERS_NAME', 'NOME DA MÃE'],
        ['FATHERS_NAME', 'NOME DO PAI']]
saturday_activitiy_pairs = [['SATURDAY_1', 'Sábado atividade 1 [1º tempo [15h00/16h00]]a'],
                    ['SATURDAY_1', 'Sábado atividade 1 [1º tempo [15h00/16h00]]b'],
                    ['SATURDAY_2', 'Sábado atividade 2 [2º tempo [16h00/17h00]]a'],
                    ['SATURDAY_2', 'Sábado atividade 2 [2º tempo [16h00/17h00]]b'],
                    ['SATURDAY_3', 'Sábado atividade 3 [4º tempo [18h00/19h00]]'],
                    ['SATURDAY_3', 'Sábado atividade 3 [3º tempo [17h00/18h00]]']]
week_activity_pairs = [['MONDAY', 'Segunda-feira [2.ª feira]a'],
                    ['MONDAY', 'Segunda-feira [2.ª feira]b'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]a'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]b'],
                    ['WEDNESDAY', 'Quarta-feira [4.ª feira]'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]a'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]b']]
days = ['SATURDAY_1', 'SATURDAY_2', 'SATURDAY_3','MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY']

inscriptions.each do |inscription|
  fee = 'n'
  confirmation_email = File.read('template_confirmation.html')
  new_email = confirmation_email
  for i in name_pairs
    new_email = name_replacement(new_email, i[0], inscription, i[1])
  end
  if inscription['Inscrever-se nas atividades de sábado?a'] == 'Sim' ||
        inscription['Inscrever-se nas atividades de sábado?b'] == 'Sim'
    fee = 's'
    for i in saturday_activitiy_pairs
      new_email = activity_replacement(new_email, i[0], inscription, i[1])[0]
    end
  end
  nbr = 0
  if inscription['Inscrever-se nas atividades durante a semana?a'] == 'Sim' ||
      inscription['Inscrever-se nas atividades durante a semana?b'] == 'Sim'
    for i in week_activity_pairs
      new_email_and_nbr = activity_replacement(new_email, i[0], inscription, i[1], nbr)
      new_email = new_email_and_nbr[0]
      nbr = new_email_and_nbr[1]
    end
  end
  fee = fee + nbr.to_s
  for i in days
    new_email = empty_days_replacement(new_email, i)
  end
  fee = fee_calc(fee)
  if inscription['Quer ajudar?'].include?('50%')
    fee += 25
  elsif inscription['Quer ajudar?'].include?('100%')
    fee += 50                                         # Is it 50 or 45?
  end

  annual_fee = (fee * 10 * 0.9).to_s
  new_email.gsub!('MONTHLY', fee.to_s)
  new_email.gsub!('ANNUAL', annual_fee)
  puts new_email
end
