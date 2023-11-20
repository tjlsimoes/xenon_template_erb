require 'csv'

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

  CSV.open("/home/tjlsimoes/Downloads/Xénon_II/inscriptions_new_headers.csv", "w") do |csv|
    copy.each do |row|
      csv << row
    end
  end
end

new_headers_csv
