# 1) Ajouter et committer les fichiers
git add .
git commit -m "initial commit"

# 2) Renommer la branche locale en main (si nécessaire)
git branch -M main

# 3) Pousser vers le remote
git push -u origin main

# Alternative : si vous avez déjà un commit sur master et voulez le pousser comme main
# git push -u origin master:main
