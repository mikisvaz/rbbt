equal    do |w| [w] end
standard do |w| [w.downcase.split(/\s+/).sort.join("")] end
cleaned  do |w| [w.downcase.sub(/,.*/,'').sub(/\(.*\)/,'').gsub(/s(?:=\W)/,'')] end
special  do |w| s = w.split.select{|w| w.is_special?}.collect{|w| w.downcase.sub(/p$/,'')} end
words    do |w| 
  w.sub(/(.*)I$/,'\1I \1').
    scan(/[a-z][a-z]+/i).
    sort{|a,b| b.length <=> a.length}. 
    collect{|n| n.downcase}
end
