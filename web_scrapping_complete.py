
courses = []
prices = []
file_path = "C://Work//Python//home.html"

with open(file_path, "r") as html_file:
    contents = html_file.read()

    soup = BeautifulSoup(contents, 'lxml')
    #print(soup.prettify())
    # Grabs all the h5 tags
    first_h5_tag = soup.find("h5")
    print(first_h5_tag.string)

    # The find method finds the first element and then stops the searching of the
    # HTML element


    h5_tags = soup.find_all("h5")
    for h5_tag in h5_tags:
        print(h5_tag.text)

    # To get the name of the courses
    courses.append(h5_tag.text)

    # we have the browser tools to inspect the html elements that make up
    # the web page. We must use the inspect options to inspect the element

    # to get the div tag for all the courses

    div_tags = soup.find_all("div", class_="card")
    # to grab the price

    for div_tag in div_tags:

        course_price = div_tag.find("a").text

        matches =  re.compile(r'\d{2,3}\$$').finditer(course_price)
        price_course_ind = list(matches)[0].group(0)
        price_course_ind = int(price_course_ind.replace('$',''))
        prices.append(price_course_ind)

print(f'All the courses = {courses}')
print(f'Prices of each course is {prices}')

for course, price in zip(courses, prices):
    print(f'{course} costs {price}')


# Scrap a real website
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
