require 'simplews'

# Gene list must be in Entrez Gene id format

genes = STDIN.read.split

driver = SimpleWS.get_driver('http://localhost:8081', 'GeneDiseasesWS')

job = driver.diseases(genes, 'test_client')

while ! driver.done job
  puts "Status: #{driver.status job} [#{driver.messages(job).last}]"
  sleep 5
end

raise "Error: #{driver.messages(job).last}" if driver.error job

puts driver.result(driver.results(job))


