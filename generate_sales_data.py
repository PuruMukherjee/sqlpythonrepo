import random

products = ['Lenovo Thinkpad T14S', 'Dell Inspiron', 'Apple Macbook Air M2',
'Apple MacBook Pro M2', 'hp Inspiron', 'ASUS Rog Gaming Laptop', 'Acer Business']


years = range(2010, 2024)
months = [1,2,3,4,5,6,7,8,9]
months = [f'0{str(month)}' for month in months ]
months.extend(['11', '12', '10'])
days = range(10, 28)
print(months)

for i in range(500):
    sales_date = f'{months[random.randint(0, len(months)-1)]}-{days[random.randint(0, len(days)-1)]}'
    sales_date = f'{years[random.randint(0, len(years)-1)]}-{sales_date}'
    query = f"'{sales_date}', '{products[random.randint(0, len(products)-1)]}'"
    print(query)
