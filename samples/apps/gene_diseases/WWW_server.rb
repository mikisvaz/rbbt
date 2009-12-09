require 'rubygems'
require 'sinatra'
require 'haml'
require 'simplews'

$driver = SimpleWS.get_driver('http://localhost:8081', 'GeneDiseasesWS')

get '/' do
  @title = 'Home'
  haml :index
end

post '/' do
  genes = params[:list].split(/[,\s]+/)
  name  = params[:name]
  job = $driver.diseases(genes, name)

  redirect "/" + job
end

get '/:job' do
  @job   = params[:job]
  @title = @job

  case 
  when $driver.error(@job)
    @error = $driver.messages(@job).last
    haml :error

  when ! $driver.done(@job)
    @status   = $driver.status(@job)
    @messages = $driver.messages(@job)
    haml :wait

  else
    @results = {}
    $driver.result($driver.results(@job).first).each_line do |line|
      disease, count    = line.split(/\t/).values_at(0,1)
      @results[disease] = count.to_i
    end

    @results = @results.sort_by{|k,v| v}.reverse
    haml :results
  end

end

__END__
@@ layout
%html
  %head
    %title== Gene Diseases: #{@title}
  %body
    = yield

@@ index
%form(action='/'  method='post')
  %h3 Paste Human Entrez Gene Ids
  %textarea(name='list' cols=30 rows=20)
  %h3 Name your job (optional)
  %input(name='name')
  %input(type='submit')

@@ error
%h1
  == Job #{@job} finished with error status
  %p= @error

@@ wait
%h1== Status: #{@status}
%ul
  - @messages.each do |msg|
    %li= msg
%head
  %meta{ 'http-equiv' => 'refresh', :content => "5" }

@@ results
%h1== Results for #{@job}

%ul
  - @results.each do |disease, count|
    %li== #{disease} (#{count})

