import os

# 除外するファイルやフォルダ
EXCLUDE = ['.git', '.github', 'generate_index.py', 'index.html']

def generate_html():
    files = [f for f in os.listdir('.') if f not in EXCLUDE]
    files.sort()

    html_content = "<html><head><title>File Index</title></head><body>"
    html_content += "<h1>Repository Files</h1><ul>"
    
    for f in files:
        html_content += f'<li><a href="./{f}">{f}</a></li>'
        
    html_content += "</ul></body></html>"

    with open("index.html", "w", encoding="utf-8") as f:
        f.write(html_content)

if __name__ == "__main__":
    generate_html()
