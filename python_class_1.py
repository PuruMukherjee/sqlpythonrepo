print('Hello World!')

# atom is an editor where we will write the code
# we will compile the code in the command prompt


# we are calculating the area of the circle
# where radius is a variable and the value of the variable is 40
radius = 40
pi = 22/7
area = pi * (radius ** 2)
print(area)

greetings = 'Hello'
user = 'Shruthi'

greeting_user = greetings + ' ' + user + '!'
print(greeting_user)

# compute the area of a cylinder
# 2πr(r + h)

# the variable names are radius , height, area_cylinder
# all the three variables can hold different values throught the program
radius = 10
height = 25
area_cylinder = 2 * pi * radius * (radius + height)
print('Area of cylinder is', area_cylinder)

radius = 30
height = 90
area_cylinder = 2 * pi * radius * (radius + height)
print('Area of cylinder is', area_cylinder)


# calculate the volume of a sphere with the same radius
# I am going to reuse the variables
vol_sphere = 4/3 * pi * radius ** 3
print('The volume of the sphere is', vol_sphere)


mrp = 1000
discount = 20
discounted_amount = mrp * discount / 100
final_price = mrp - discounted_amount
# build small fail small
print('The discounted amount is',discounted_amount, 'and final price is', final_price)




names = ["Shruthi", "Unmesh", "Shekhar", "Rohit"]
print(names)
print(type(names))

greeting = 'Welcome Back'

# a list is a variable that can hold more than one value.

# to loop over all the elements of the variables one by one
# print the greeting message, so that we do not have to write multiple print statements

# I will use the for loop to loop over all the elements of the variable names
for n in names:
    message = greeting + ' ' + n + '!'
    print('I am in the for loop')
    print(message)


radai = [ 10, 20, 40, 50, 60, 70, 90, 10.45]

radii = [10, 20, 40, 50, 60, 70, 90, 10.45]
for radius  in radii:
    volume = 4 / 3 * 22/7 * radius ** 3
    print('The volume of sphere is',volume)
    print('***********')
