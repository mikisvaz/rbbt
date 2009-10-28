isLetters     /^[A-Z]+$/i 
isUpper       /^[A-Z]+$/ 
isLower       /^[a-z]+$/ 
isDigits      /^[0-9]+$/i 
isRoman       /^[IVX]+$/ 
isGreek       /^(?:alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|mu|nu|xi|omicron|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega)$/i 
isPunctuation /^[,.;]$/ 
isDelim       /^[\/()\[\]{}\-]$/ 
isNonWord     /^[^\w]+$/ 
isConjunction /^and|or|&|,$/

hasLetters    /[A-Z]/i 
hasUpper      /.[A-Z]/ 
hasLower      /[a-z]/ 
hasDigits     /[0-9]/i 
hasGreek      /(?:alpha|beta|gamma|delta|epsilon|zeta|eta|theta|iota|kappa|lambda|mu|nu|xi|omicron|pi|rho|sigma|tau|upsilon|phi|chi|psi|omega)/i 
hasPunctuation /[,.;]/ 
hasDelim      /[\/()\[\]{}\-]/ 
hasNonWord    /[^\w]/ 
caspMix       /[a-z].[A-Z]/ 
keywords      /(?:protein|gene|domain|ase)s?$/
hasSuffix     /[a-z][A-Z0-9]$/

numLetters    do |w| w.scan(/[A-Z]/i).length end
numDigits     do |w| w.scan(/[0-9]/).length end
#
prefix_3      /^(...)/ 
prefix_4      /^(....)/ 
suffix_3      /(...)$/ 
suffix_4      /(....)$/ 


token1        do |w| 
                 w.sub(/[A-Z]/,'A'). 
                   sub(/[a-z]/,'a').
                   sub(/[0-9]/,'0').
                   sub(/[^0-9a-z]/i,'x')
              end
token2        do  |w| 
                 w.sub(/[A-Z]+/,'A'). 
                   sub(/[a-z]+/,'a').
                   sub(/[0-9]+/,'0').
                   sub(/[^0-9a-z]+/i,'x')
               end
token3         do |w| w.downcase end
special        do |w| w.is_special? end

context   %w(special token2 isPunctuation isDelim)
window     %w(1 2 3 -1 -2 -3)
#direction :reverse


