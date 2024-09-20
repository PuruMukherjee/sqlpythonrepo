# -*- coding: utf-8 -*-
"""
Created on Sat Nov 25 06:19:28 2023

@author: ADMIN
"""

from bs4 import BeautifulSoup
import requests
import lxml
import re

url = \
    'https://www.timesjobs.com/candidate/job-search.html?searchType=personalizedSearch&from=submit&txtKeywords=PYTHON&txtLocation='
    
html_text = requests.get(url)
#print(html_text)

html_text = requests.get(url).text
#print(html_text)
soup = BeautifulSoup(html_text, 'lxml')
# It makes sense to catch a certain element on the post and then inspect
# get all the jobs

# Work with a single job listing first
job = soup.find("li", class_="clearfix job-bx wht-shd-bx")
print(job.prettify())

company_name = job.find_all("h3", class_="joblist-comp-name")[0].text
company_name = company_name.strip()
print(company_name.strip())

job_title = job.a.text
print(job_title)

# get the skill set needed to do the job

skill_sets = \
    job.find("span", class_="srp-skills").text.strip()
    
print(skill_sets)

# get the experience information
experience = \
    job.find("ul", class_="top-jd-dtl clearfix").find_all("li")[0].text
    
pattern  = re.compile(r'\d{1,2}\s.+\d{1,2}\syrs$')
matches = pattern.finditer(experience)
matches = list(matches)
exp_text = matches[0].group(0).strip()
print(exp_text)

# Location
location = \
    job.find("ul", class_="top-jd-dtl clearfix").span.text.strip()
print(location)


# Can I repeat this for all the job listings in this page
jobs = soup.find_all("li", class_="clearfix job-bx wht-shd-bx")
for job in jobs:
    company_name = job.find_all("h3", class_="joblist-comp-name")[0].text
    company_name = company_name.strip()
    print(company_name.strip())
    
    # get the job title
    job_title = job.a.text
    print(job_title)
    
    skill_sets = \
        job.find("span", class_="srp-skills").text.strip()
        
    print(skill_sets)
    
    experience = \
        job.find("ul", class_="top-jd-dtl clearfix").find_all("li")[0].text
        
    pattern  = re.compile(r'\d{1,2}\s.+\d{1,2}\syrs$')
    matches = pattern.finditer(experience)
    matches = list(matches)
    exp_text = matches[0].group(0).strip()
    print(exp_text)
    
    location = \
        job.find("ul", class_="top-jd-dtl clearfix").span.text.strip()
    print(location)

    # job posted time
    job_posted_time = job.find("span", class_="sim-posted").text.strip()
    print(job_posted_time)
    print('*************************************************')
    
# Scrap the world biggest companies
import requests
import requests
from bs4 import BeautifulSoup

url = 'https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue'
html_contents = requests.get(url).text

soup = BeautifulSoup(html_contents, 'lxml')

table_text = \
    soup.find("table",class_="wikitable sortable")
    
table_headers = \
    table_text.find_all("th")
    
#print(table_headers)
    
column_names =[]
for table_header  in table_headers:
    #print(table_header.text)
    column_names.append(table_header.text.strip())
# The table_text

print(column_names)
    



    
    
    
    