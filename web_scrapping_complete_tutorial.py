
from bs4 import BeautifulSoup
import requests
import lxml
import re


URL = "https://www.timesjobs.com/candidate/job-search.html?searchType=personalizedSearch&from=submit&searchTextSrc=ft&searchTextText=&txtKeywords=PYTHON&txtLocation="
html_text = requests.get(url)
print(html_text)
#print(html_text)
