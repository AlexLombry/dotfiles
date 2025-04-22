from fpdf import FPDF
import os

# Création d'un PDF avec le texte retranscrit
class PDF(FPDF):
    def header(self):
        self.set_font("Arial", "B", 12)
        self.cell(0, 10, "Lettre de Pétition - Assistantes Maternelles", ln=True, align="C")

    def footer(self):
        self.set_y(-15)
        self.set_font("Arial", "I", 8)
        self.cell(0, 10, f"Page {self.page_no()}", align="C")

pdf = PDF()
pdf.add_page()
pdf.set_auto_page_break(auto=True, margin=15)
pdf.set_font("Arial", "", 12)

# Contenu de la lettre
texte = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
"""

# Ajouter le texte au PDF
for line in texte.strip().split('\n'):
    pdf.multi_cell(0, 10, line)

# Sauvegarde du fichier
output_path = "./generated_letter.pdf"
pdf.output(output_path)

output_path


# # Corriger les caractères spéciaux pour l'encodage Latin-1
# texte_corrige = texte.replace("’", "'").replace("…", "...").replace("é", "e").replace("è", "e")

# # Re-création du PDF avec le texte corrigé
# pdf = PDF()
# pdf.add_page()
# pdf.set_auto_page_break(auto=True, margin=15)
# pdf.set_font("Arial", "", 12)

# for line in texte_corrige.strip().split('\n'):
#     pdf.multi_cell(0, 10, line)

# # Sauvegarde du fichier
# output_path = "/mnt/data/Lettre_Petition_Assistantes_Maternelles.pdf"
# pdf.output(output_path)

# output_path
