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


inscriptions = CSV.open('/home/tjlsimoes/Downloads/24.csv',
                        headers: true)
name_pairs = [['SONS_NAME', 'NOME DO PARTICIPANTE'], ['MOTHERS_NAME', 'NOME DA MÃE'],
        ['FATHERS_NAME', 'NOME DO PAI']]
inscriptions.each do |inscription|
  confirmation_email = File.read('template_confirmation.html')
  new_email = confirmation_email
  for i in name_pairs
    new_email = name_replacement(new_email, i[0], inscription, i[1])
  end
  puts new_email
end
