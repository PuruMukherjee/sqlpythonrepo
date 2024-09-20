# enter a number and check if the number is an odd or even number
number  = 30 #int(input("Enter a number??"))

if number %2 == 0 :
    print(f'{number} is even')
else:
    print(f'{number} is odd')

# check for leap year
year = 2024 #int(input("Enter a year"))
if year % 4 == 0 :
    print(f'{year} is a leap year')
else:
    print(f'{year} is not a leap year')


# extra condiiton - Nested condition
height = 130
age = 8

if height >= 120:
    print("You can ride the rollercoaster  ")
    if age < 12:
        ticket_price = 5
    elif age <=18:
        ticket_price = 7
    elif age > 18:
        ticket_price = 12
    print(f'The ticket price is {ticket_price}')
else:
    print("You cannot ride the rollercoaster")

# BMI calculator
# bmi = weight(kg)/ height**2 (meters)
weight_val = 120
height_val = 1.8
height = float(height_val)
weight = float(weight_val)
bmi = weight / (height ** 2)
print(f'The bmi value is {bmi}')
