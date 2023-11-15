require 'csv'
puts "CSV Parsing and HTML building initialized."

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
  if name_to_be && !(/\[/.match?(name_to_be))
    nbr += 1
    new_email.gsub!(name, name_to_be)
  end
  return [new_email, nbr]
end

def empty_days_replacement(new_email, name, inscription)
    new_email.gsub!(name, "")
  return new_email
end

def fee_calc(fee)
  case fee
  when "n"
    fee = 5
  when "n1"
    fee = 30
  when "n2"
    fee = 40
  when "n3"
    fee = 50
  when "s0"
    fee = 45
  when "s1"
    fee = 55
  when "s2"
    fee = 65
  when "s3"
    fee = 75
  end
  return fee
end


inscriptions = CSV.open('/home/tjlsimoes/Downloads/Xénon/24.csv',
                        headers: true)

name_pairs = [['SONS_NAME', 'NOME DO PARTICIPANTE'], ['MOTHERS_NAME', 'NOME DA MÃE'],
        ['FATHERS_NAME', 'NOME DO PAI']]
saturyday_activitiy_pairs = [['SATURDAY_1', 'Sábado atividade 1 [1º tempo [15h00/16h00]]'],
                    ['SATURDAY_2', 'Sábado atividade 2 [2º tempo [16h00/17h00]]'],
                    ['SATURDAY_3', 'Sábado atividade 3 [4º tempo [18h00/19h00]]'],
                    ['SATURDAY_3', 'Sábado atividade 3 [3º tempo [17h00/18h00]]']]
week_activity_pairs = [['MONDAY', 'Segunda-feira [2.ª feira]'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]'],
                    ['WEDNESDAY', 'Quarta-feira [4.ª feira]'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]']]
days = ['SATURDAY_1', 'SATURDAY_2', 'SATURDAY_3','MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY']

inscriptions.each do |inscription|
  fee = "n"
  confirmation_email = File.read('template_confirmation.html')
  new_email = confirmation_email
  for i in name_pairs
    new_email = name_replacement(new_email, i[0], inscription, i[1])
  end
  if inscription["Inscrever-se nas atividades de sábado?"]
    fee = "s"
    for i in saturyday_activitiy_pairs
      new_email = activity_replacement(new_email, i[0], inscription, i[1])[0]
    end
  end
  if inscription["Inscrever-se nas atividades durante a semana?"]
    for i in week_activity_pairs
      new_email_and_nbr = activity_replacement(new_email, i[0], inscription, i[1])
      new_email = new_email_and_nbr[0]
      nbr = new_email_and_nbr[1]
    end
    fee = fee + nbr.to_s
  end
  for i in days
    empty_days_replacement(new_email, i, inscription)
  end
  fee = fee_calc(fee)
  annual_fee = (fee * 10 * 0.9).to_s
  new_email.gsub!('MONTHLY', fee.to_s)
  new_email.gsub!('ANNUAL', annual_fee)
  puts new_email
end
