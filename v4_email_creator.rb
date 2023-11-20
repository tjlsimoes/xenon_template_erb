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
  return "/home/tjlsimoes/Downloads/Xénon_II/inscriptions_sing_quota.csv"
end


# Generate a new CSV with the calculation of the
# quota taking brothers into account.
#
# The idea was:
# - From the CSV file with the singular quotas
#    create an array of inscriptions' hashes.
# - Add BROTHERS_QUOTA key to each hash and fill
#    accordingly (default == nil).
# - Create a new CSV file with the new BROTHERS_QUOTA
#    column, so to speak.

def create_brothers_quota_column(inscriptions)
  hashes_array = []
  inscriptions.each do |inscription|
    hashes_array << inscription.to_h
  end
  hashes_array.each do |hash|
    hash['BROTHERS_QUOTA'] = nil
  end
  return hashes_array
end

def brothers?(inscription_a, inscription_b)
  inscription_a['CÓDIGO POSTAL'].split[0] == inscription_b['CÓDIGO POSTAL'].split[0] &&
    inscription_a['NOME DO PARTICIPANTE'].split[-1] == inscription_b['NOME DO PARTICIPANTE'].split[-1]
end

def brothers_array(inscription, idx, inscriptions_hashes, inscriptions_hashes_length)
  brothers = []
  brothers << inscription
  j = idx + 1
  while j < inscriptions_hashes_length
    if  brothers?(inscriptions_hashes[idx], inscriptions_hashes[j])
      brothers << inscriptions_hashes[j]
    end
    j += 1
  end
  return brothers
end

def two_brothers_quota_calc(quota_1, quota_2)
  if quota_1 == quota_2
    case quota_1
    when '45'
      quota = 72
    when '55'
      quota = 88
    when '65'
      quota = 104
    when '75'
      quota = 120
    when '30'
      quota = 48
    when '40'
      quota = 64
    when '50'
      quota = 80
    when '5'
      quota = 10
    end
  else
    quota = (quota_1.to_i + quota_2.to_i) * 0.8
  end
  return quota
end

def three_brothers_quota_calc(quota_1, quota_2, quota_3)
  if quota_1 == quota_2 && quota_2 == quota_3
    case quota_1
    when '45'
      quota = 94
    when '55'
      quota = 115
    when '65'
      quota = 136
    when '75'
      quota = 158
    when '30'
      quota = 63
    when '40'
      quota = 84
    when '50'
      quota = 105
    when '5'
      quota = 15
    end
  else
    quota = (quota_1.to_i + quota_2.to_i + quota_3.to_i) * 0.7
  end
  return quota
end

def brothers_quota_calc(brothers)
  if brothers.length == 2
    quota = two_brothers_quota_calc(brothers[0]['QUOTA'], brothers[1]['QUOTA'])
  elsif brothers.length == 3
    quota = three_brothers_quota_calc(brothers[0]['QUOTA'], brothers[1]['QUOTA'], brothers[2]['QUOTA'])
  end
  return quota
end

def financial_aid_add(brothers, quota)
  for i in brothers
    if !i['Quer ajudar?'].nil? && i['Quer ajudar?'].include?('50%')
      quota += 25
    elsif !i['Quer ajudar?'].nil? && i['Quer ajudar?'].include?('100%')
      quota += 45                                         # Is it 50 or 45?
    end
  end
  return quota
end

def update_brothers_quota(brothers, quota)
  i = 0
  while i < brothers.length
    if i == 0
      brothers[i]['BROTHERS_QUOTA'] = quota.to_s
    else
      brothers[i]['BROTHERS_QUOTA'] = '-'
    end
    i += 1
  end
end

def brothers_quota_calc_csv(quota_calc_csv_loc)
  inscriptions = CSV.read(quota_calc_csv_loc, headers: true)
  inscriptions_hashes = create_brothers_quota_column(inscriptions)

  inscriptions_hashes_length = inscriptions_hashes.length

  i = 0
  while i < inscriptions_hashes_length
    if inscriptions_hashes[i]['BROTHERS_QUOTA'].nil?
      brothers = brothers_array(inscriptions_hashes[i], i, inscriptions_hashes, inscriptions_hashes_length)

      if brothers.length > 1
        joint_quota = brothers_quota_calc(brothers)
        joint_quota = financial_aid_add(brothers, joint_quota)
      else
        joint_quota = financial_aid_add(brothers, brothers[0]['QUOTA'].to_i)  # Joint so to speak. Here it deals
                                                                              # with no-brothers' case.
      end
      update_brothers_quota(brothers, joint_quota.round)
    end
    i += 1
  end

  CSV.open("/home/tjlsimoes/Downloads/Xénon_II/inscriptions_brothers_quotas.csv", "w") do |csv|
    csv << inscriptions_hashes.first.keys
    inscriptions_hashes.each do |inscription_hash|
      csv << inscription_hash.values
    end
  end
end


sing_quota_loc = quota_calc_csv(new_headers_csv)
brothers_quota_loc = brothers_quota_calc_csv(sing_quota_loc)
