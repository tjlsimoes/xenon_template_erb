require 'csv'

$week_activity_pairs = [['MONDAY', 'Segunda-feira [2.ª feira]a'],
                    ['MONDAY', 'Segunda-feira [2.ª feira]b'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]a'],
                    ['TUESDAY', 'Terça-feira [3.ª feira]b'],
                    ['WEDNESDAY', 'Quarta-feira [4.ª feira]'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]a'],
                    ['THURSDAY', 'Quinta-feira [5.ª feira]b']]

# Generate a new CSV file with differentiated headers
# for the saturday and week activities of younger and
# older kids. Rename financial aid field header to:
# 'Quer ajudar?'

def new_headers_csv
  original = CSV.read('/home/tjlsimoes/Downloads/Xénon_II/Inscriptions.csv')
  copy = original

  i = 5
  while i <= 21
    if i <= 12
      copy[0][i] = copy[0][i] + 'a'
    else
      copy[0][i] = copy[0][i] + 'b'
    end
    i += 1
  end
  copy[0][37] = 'Quer ajudar?'
  CSV.open("/home/tjlsimoes/Downloads/Xénon_II/inscriptions_new_headers.csv", "w") do |csv|
    copy.each do |row|
      csv << row
    end
  end
  return "/home/tjlsimoes/Downloads/Xénon_II/inscriptions_new_headers.csv"
end




# Generate a new CSV with the calculation of the
# quota for each individual kid, irregardless
# of number of brothers.
#
# The idea was:
# - From the CSV file with changed headers
#    create an array of inscriptions' hashes.
# - Add QUOTA key to each hash and fill
#    accordingly (default == 0).
# - Create a new CSV file with the new QUOTA
#    column, so to speak.

def quota_calc(quota)
  case quota
  when 'n0'
    quota = 5
  when 'n1'
    quota = 30
  when 'n2'
    quota = 40
  when 'n3'
    quota = 50
  when 's0'
    quota = 45
  when 's1'
    quota = 55
  when 's2'
    quota = 65
  when 's3'
    quota = 75
  end
  return quota
end


def create_quota_column(inscriptions)
  hashes_array = []
  inscriptions.each do |inscription|
    hashes_array << inscription.to_h
  end
  hashes_array.each do |hash|
    hash['QUOTA'] = 0
  end
  return hashes_array
end

def signed_up_saturday?(inscr)
  quota_str = 'n'
  if inscr['Inscrever-se nas atividades de sábado?a'] == 'Sim' ||
    inscr['Inscrever-se nas atividades de sábado?b'] == 'Sim'
    quota_str = 's'
  end
  return quota_str
end

def nbr_activities_week?(inscr)
  nbr = 0
  if inscr['Inscrever-se nas atividades durante a semana?a'] == 'Sim' ||
    inscr['Inscrever-se nas atividades durante a semana?b'] == 'Sim'
    for j in $week_activity_pairs
      act_name = inscr[j[1]]
      if act_name && !(act_name.include?('nenhuma')) && !(act_name.empty?)
        nbr += 1
      end
    end
  end
  return nbr
end

def quota_calc_csv(new_headers_csv_loc)
  inscriptions = CSV.read(new_headers_csv_loc, headers: true)
  inscriptions_hashes = create_quota_column(inscriptions)

  for i in inscriptions_hashes
    quota_str = signed_up_saturday?(i)
    nbr = nbr_activities_week?(i)
    quota_str = quota_str + nbr.to_s
    quota = quota_calc(quota_str)
    i['QUOTA'] = quota.to_s
  end

  CSV.open("/home/tjlsimoes/Downloads/Xénon_II/inscriptions_sing_quota.csv", "w") do |csv|
    csv << inscriptions_hashes.first.keys
    inscriptions_hashes.each do |inscription_hash|
      csv << inscription_hash.values
    end
  end
end

quota_calc_csv(new_headers_csv)
