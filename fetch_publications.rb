require 'net/http'
require 'json'
require 'uri'

# Exemple de requête pour récupérer des publications d'une collection spécifique ici LS2N-TALN
#url = URI("https://api.archives-ouvertes.fr/search/?q=collCode_s:LS2N-TALN&fl=title_s,authFullName_s,linkExtUrl_s,producedDateY_i&wt=json")

# Requête pour récupérer des publications du projet ANR spécifié ici MALADES
#url = URI("https://api.archives-ouvertes.fr/search/?q=anrProjectAcronym_s:MALADES&fl=title_s,authFullName_s,linkExtUrl_s,producedDateY_i&wt=json")

# Récupération des données de l'API avec le numero ANR
url = URI("https://api.archives-ouvertes.fr/search/?q=anrProjectReference_s:ANR-23-IAS1-0005&fl=title_s,authFullName_s,linkExtUrl_s,producedDateY_i&wt=json")

# Récupération des données de l'API
response = Net::HTTP.get(url)
response.force_encoding('UTF-8')

puts "Réponse de l'API : #{response}"
data = JSON.parse(response)

# Génération du contenu Markdown pour la page Publications
markdown_content = "---
layout: page
title: Publications
permalink: publications.html
---\n"

# Vérification et traitement des documents
if data['response'] && data['response']['docs']
  # Trier les publications par date
  sorted_docs = data['response']['docs'].sort_by { |doc| -doc['producedDateY_i'].to_i }

  sorted_docs.each do |doc|
    title = doc['title_s'] || 'Titre inconnu'
    authors = doc['authFullName_s'] ? doc['authFullName_s'].join(', ') : 'Auteur inconnu'
    year = doc['producedDateY_i'] || 'Année inconnue'
    
    if doc['linkExtUrl_s'] && !doc['linkExtUrl_s'].empty?
      link = doc['linkExtUrl_s']
      markdown_content += "## #{title} (#{year})\n"
      markdown_content += "*Auteurs:* #{authors}\n"
      markdown_content += "[Lire plus](#{link})\n\n"
    else
      markdown_content += "## #{title} (#{year})\n"
      markdown_content += "*Auteurs:* #{authors}\n\n"
      markdown_content += "Pas de lien sur HAL disponible.\n\n"
    end
  end
else
  puts "Aucune donnée trouvée ou format de réponse inattendu."
end

# Écrire ou mettre à jour publications.md
File.write('_pages/publications.md', markdown_content)
