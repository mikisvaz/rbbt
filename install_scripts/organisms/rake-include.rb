require 'rbbt'
require 'rbbt/util/open'
require 'rbbt/util/arrayHash'
require 'rbbt/sources/biomart'
require 'rbbt/sources/entrez'
require 'rbbt/sources/pubmed'



file 'name' do
  Open.write('name', $name)
end

file 'all.pmid' do
  Open.write('all.pmid', PubMed.query($query).join("\n"))
end

file 'lexicon' do
  begin

    data = nil
    # Read from file
    if $lexicon[:file]
      file = Open.to_hash($lexicon[:file][:url], $lexicon[:file])
      data = ArrayHash.new(file, $native_id)
    end

    # Translate from entrez to native if needed
    if $entrez2native
      translations = {}
      Entrez.entrez2native(*$entrez2native.values_at(:tax,:native,:fix,:check)).
        each{|k,v|
          translations[k] = [v.join("|")]
      }
      translations_data = ArrayHash.new(translations,'Entrez Gene ID', [$native_id])
      if data
        data.merge(translations_data)
      else
        data = translations_data
      end

    end


    # Read from Biomart and merge with previous data
    if $lexicon[:biomart]
      biomart = {}
      
      BioMart.query(
        $lexicon[:biomart][:database],
        $lexicon[:biomart][:main][1],
        $lexicon[:biomart][:extra].collect{|v| v[1]},
        $lexicon[:biomart][:filter]
      ).each{|key, values_list|
        values = values_list.values_at(*$lexicon[:biomart][:extra].collect{|v| v[1]}).compact.collect{|list| list.select{|e| e.to_s != ""}.uniq.join("|")}
        biomart[key] = values
      }

      biomart_data = ArrayHash.new(biomart, $lexicon[:biomart][:main][0], $lexicon[:biomart][:extra].collect{|v| v[0]})

      if data
        if $lexicon[:biomart][:extra].collect{|v| v[1]}.include?( $native_id )|| $lexicon[:biomart][:main][0] == $native_id
          field = $native_id 
        else
          field =  'Entrez Gene ID'
        end
        data.merge(biomart_data, field)
      else
        data = biomart_data
      end
    end

    if $entrez2native
      gene_alias = {}
      Entrez.entrez2native($entrez2native[:tax],4).
        each{|k,v|
        gene_alias[k] = [v.select{|e| e.to_s != ""}.join("|")]
      }
      if gene_alias.keys.any?
        gene_alias_data = ArrayHash.new(gene_alias,'Entrez Gene ID', ['Entrez Gene Alias'])
        data.merge(gene_alias_data, 'Entrez Gene ID')
      end
    end

    data.remove('Entrez Gene ID')
    data.clean
    Open.write('lexicon', data.data.collect{|code, name_lists|
      "#{ code }\t" + name_lists.flatten.select{|n| n.to_s != ""}.uniq.join("\t")
    }.join("\n"))

rescue Entrez::NoFile
  puts "Lexicon not produced for #{$name}, install the entrez gene_info file (rbbt_config install entrez)."
end
end


file 'identifiers' do

  begin
    data = nil
    if $identifiers[:file]
      file = Open.to_hash($identifiers[:file][:url], $identifiers[:file])
      data = ArrayHash.new(file, $native_id, $identifiers[:file][:fields])
    end

    # Translate from entrez to native if needed
    if $entrez2native
      translations = {}
      Entrez.entrez2native(*$entrez2native.values_at(:tax,:native,:fix,:check)).
        each{|k,v|
          translations[k] = [v.join("|")]
      }
      if translations.keys.any?
        translations_data = ArrayHash.new(translations,'Entrez Gene ID', [$native_id])
        if data
          data.merge(translations_data)
        else
          data = translations_data
        end
      end

    end


    # Read from Biomart and merge with previous data
    if $identifiers[:biomart]
      biomart = {}
      
      BioMart.query(
        $identifiers[:biomart][:database],
        $identifiers[:biomart][:main][1],
        $identifiers[:biomart][:extra].collect{|v| v[1]},
        $identifiers[:biomart][:filter]
      ).each{|key, values_list|
        values = values_list.values_at(*$identifiers[:biomart][:extra].collect{|v| v[1]}).compact.collect{|list| list.select{|e| e.to_s != ""}.uniq.join("|")}
        biomart[key] = values
      }

      biomart_data = ArrayHash.new(biomart, $identifiers[:biomart][:main][0], $identifiers[:biomart][:extra].collect{|v| v[0]})
      $identifiers[:biomart][:extra].each{|values|
        if values[2]
          biomart_data.process(values[0]){|n| "#{values[2]}:#{n}"}
        end
      }


      if data
        if $identifiers[:biomart][:extra].collect{|v| v[1]}.include?( $native_id ) || $identifiers[:biomart][:main][0] == $native_id
          field = $native_id 
        else
          field = 'Entrez Gene ID'
        end
        data.merge(biomart_data, field)
      else
        data = biomart_data
      end
    end


    # Add the alias at the end
    if $entrez2native
      gene_alias = {}
      Entrez.entrez2native($entrez2native[:tax],4).
       each{|k,v|
         gene_alias[k] = [v.join("|")]
      }
      if gene_alias.keys.any?
        gene_alias_data = ArrayHash.new(gene_alias,'Entrez Gene ID', ['Entrez Gene Alias'])
        if data
          data.merge(gene_alias_data, 'Entrez Gene ID')
        else
          data = gene_alias_data
        end
      end
    end



    # Write ids to file
    fout = File.open('identifiers', 'w')
    fout.puts "##{$native_id}\t" + data.fields.join("\t")
    data.clean
    data.data.each{|code, values|
      fout.puts code + "\t" + values.join("\t")
    }
    fout.close

  rescue Entrez::NoFile
    puts "Identifiers not produced for #{$name}, install the entrez gene_info file (rbbt_config install entrez)."
  end
end


file 'gene.go' do
  data = Open.to_hash($go[:url], :native => $go[:code], :extra => $go[:go], :exclude => $go[:exclude], :fix => $go[:fix])

  data = data.collect{|code, value_lists|
    [code, value_lists.flatten.select{|ref| ref =~ /GO:\d+/}.collect{|ref| ref.match(/(GO:\d+)/)[1]}]
  }.select{|p|  p[1].any?}

  Open.write('gene.go', 
              data.collect{|p| 
                p[1].uniq.collect{|go|
                  "#{p[0]}\t#{go}"
                }.join("\n")
              }.join("\n")
            )
end

file 'gene_go.pmid' do
  data = Open.to_hash($go[:url], :native => $go[:code], :extra => $go[:pmid], :exclude => $go[:exclude], :fix => $go[:fix])

  data = data.collect{|code, value_lists|
    [code, value_lists.flatten.select{|ref| ref =~ /PMID:\d+/}.collect{|ref| ref.match(/PMID:(\d+)/)[1]}]
  }.select{|p|  p[1].any?}

  Open.write('gene_go.pmid', 
              data.collect{|p| 
                p[1].uniq.collect{|pmid| "#{p[0]}\t#{pmid}" }.join("\n")
              }.join("\n")
            )
end


file 'gene.pmid' do
  begin
    translations = Entrez.entrez2native(*$entrez2native.values_at(:tax,:native,:fix,:check)) if $native_id != "Entrez Gene ID"

    data = Entrez.entrez2pubmed($entrez2native[:tax])

    Open.write('gene.pmid',
               data.collect{|code,pmids|
      next if translations && ! translations[code]
      code = translations[code].first if translations 
      pmids.collect{|pmid|
                 "#{ code }\t#{pmid}"
      }.compact.join("\n")
    }.compact.join("\n")
              )
  rescue Entrez::NoFile
    puts "Gene article associations from entrez not produced, install the gene2pumbed file (rbbt_config install entrez)."
  end

end




task 'all' => ['name', 'lexicon', 'identifiers', 'gene_go.pmid', 'gene.pmid', 'gene.go', 'all.pmid']
task 'clean' do
  `rm -f 'name' 'lexicon' 'identifiers' 'gene_go.pmid' 'gene.pmid' 'gene.go' 'all.pmid'`
end

task 'update' do
  Rake::Task['clean'].invoke if $force
  Rake::Task['all'].invoke
end

