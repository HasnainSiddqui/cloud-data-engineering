# ============================================================
#   CLASS 3 — HOMEWORK QUESTIONS
#   Functions, Loops & OOP
#   Total Questions: 10
# ============================================================
#   Instructions:
#     - Write your answer below each question.
#     - Do NOT delete the question comments.
#     - Run your code after each question to test it.
#     - Questions 1-3  → Functions
#     - Questions 4-6  → Loops
#     - Questions 7-10 → OOP
# ============================================================


# ─────────────────────────────────────────────
# QUESTION 1 — Functions (Basic)
# ─────────────────────────────────────────────
# A mobile phone shop gives discounts based on the price:
#
#   Price >= 100,000  → 15% discount
#   Price >= 50,000   → 10% discount
#   Price >= 20,000   →  5% discount
#   Price <  20,000   →  No discount
#
# Write a function called phone_discount(price) that:
#   1. Figures out the correct discount percentage.
#   2. Calculates the discount amount.
#   3. Calculates the final price after discount.
#   4. RETURNS the final price.
#
# Then call it 3 times with different prices and print results.
#
# Example:
#   phone_discount(120000) → Final price: Rs.102000.0 (15% off)
#   phone_discount(60000)  → Final price: Rs.54000.0  (10% off)
#   phone_discount(15000)  → Final price: Rs.15000.0  (no discount)

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 2 — Functions (Default Parameters + Return)
# ─────────────────────────────────────────────
# Write a function called pizza_order(size, toppings=1, extra_cheese=False)
# that calculates the total price of a pizza order.
#
# Pricing rules:
#   Size:
#     "small"  → Rs. 400
#     "medium" → Rs. 650
#     "large"  → Rs. 900
#   Each topping costs Rs. 80  (toppings default = 1)
#   Extra cheese adds Rs. 120  (extra_cheese default = False)
#
# The function should:
#   - Calculate and RETURN the total price.
#   - Print a short summary inside the function showing what was ordered.
#
# Call the function at least 3 times with different combinations.
#
# Example:
#   pizza_order("large", toppings=3, extra_cheese=True)
#   → Large pizza | 3 toppings | Extra cheese: Yes | Total: Rs.1260

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 3 — Functions (Multiple Return Values + Scope)
# ─────────────────────────────────────────────
# Write a function called analyse_text(sentence) that:
#   1. Counts the total number of words.
#   2. Counts the total number of characters (excluding spaces).
#   3. Finds the longest word.
#   4. Returns ALL THREE values at once.
#
# Then ask the user to enter a sentence and call the function.
# Print the results clearly.
#
# Example:
#   Input   : "Python is an amazing programming language"
#   Output  :
#     Words       : 6
#     Characters  : 36
#     Longest word: programming

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 4 — Loops (for + range + accumulator)
# ─────────────────────────────────────────────
# A factory produces items every day of the week.
# Daily production numbers (Monday to Sunday):
#
#   production = [120, 95, 140, 110, 130, 80, 60]
#
# Write a program using a for loop that:
#   1. Prints each day's production with the day name.
#      (index 0 = Monday, index 1 = Tuesday, ... index 6 = Sunday)
#   2. Tracks and prints the RUNNING TOTAL after each day.
#   3. After the loop, prints:
#        - Total weekly production
#        - Highest single-day production
#        - Lowest single-day production
#        - Average daily production (rounded to 1 decimal)
#        - Number of days that met the target (target = 100 units)
#
# Example output (first 2 lines):
#   Monday    : 120 units | Running Total: 120
#   Tuesday   :  95 units | Running Total: 215

# Write your code below:
production = [120, 95, 140, 110, 130, 80, 60]




# ─────────────────────────────────────────────
# QUESTION 5 — Loops (while + break + continue)
# ─────────────────────────────────────────────
# Build a simple QUIZ GAME using a while loop.
#
# Rules:
#   - Store at least 4 questions in a list. Each question is a
#     tuple: (question_text, correct_answer)
#   - Ask each question one by one.
#   - If the answer is correct → print "Correct! ✔" and add 1 point.
#   - If the answer is wrong   → print "Wrong! The answer was X."
#   - If the user types "skip" → use continue to skip that question.
#   - If the user types "quit" → use break to end the game early.
#   - At the end, print the final score out of total questions asked.
#
# Sample questions you can use (or make your own):
#   ("What is the capital of Pakistan?", "islamabad")
#   ("How many days are in a week?", "7")
#   ("What language are we learning?", "python")
#   ("What is 15 + 27?", "42")

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 6 — Loops (Nested loops — real-world)
# ─────────────────────────────────────────────
# A school has 3 classes: A, B, C.
# Each class has 4 students with the following marks:
#
#   class_data = {
#       "Class A": [85, 72, 91, 68],
#       "Class B": [55, 78, 63, 90],
#       "Class C": [40, 88, 74, 59],
#   }
#
# Write a program using NESTED LOOPS that:
#   1. Loops through each class.
#   2. Inside, loops through each student's marks.
#   3. Prints each student's mark and whether they Passed (>=50) or Failed.
#   4. After each class, prints the class average.
#   5. After all classes, prints which class had the HIGHEST average.
#
# Example (for Class A):
#   Class A:
#     Student 1: 85 → Pass
#     Student 2: 72 → Pass
#     Student 3: 91 → Pass
#     Student 4: 68 → Pass
#   Class A Average: 79.0

# Write your code below:
class_data = {
    "Class A": [85, 72, 91, 68],
    "Class B": [55, 78, 63, 90],
    "Class C": [40, 88, 74, 59],
}




# ─────────────────────────────────────────────
# QUESTION 7 — OOP (Class + __init__ + Methods)
# ─────────────────────────────────────────────
# Create a class called MobilePhone with:
#
#   Attributes (set in __init__):
#     brand       → e.g. "Samsung"
#     model       → e.g. "Galaxy S24"
#     battery     → starts at 100 (always, regardless of input)
#     is_on       → starts as False (phone is off by default)
#
#   Methods:
#     power_on()        → if already on, print "Already on."
#                         otherwise set is_on = True and print a message.
#     power_off()       → if already off, print "Already off."
#                         otherwise set is_on = False and print a message.
#     make_call(mins)   → if phone is off, print "Turn on the phone first."
#                         otherwise reduce battery by (mins * 2).
#                         If battery drops below 0, set it to 0 and
#                         print "Battery died during the call!"
#                         Otherwise print call duration and remaining battery.
#     charge(percent)   → increase battery by percent, max 100.
#                         Print the new battery level.
#     status()          → print brand, model, battery %, and on/off state.
#
# Create TWO phones and test all methods on each.

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 8 — OOP (Class with a list + methods)
# ─────────────────────────────────────────────
# Create a class called ShoppingCart that models an
# online shopping cart.
#
#   Attributes (set in __init__):
#     customer_name  → name of the customer
#     items          → empty list (will store dictionaries)
#
#   Each item in the list is a dictionary:
#     { "name": "Milk", "price": 120, "qty": 2 }
#
#   Methods:
#     add_item(name, price, qty=1)
#       → Add the item to the list. If the item already exists,
#         increase its quantity instead.
#
#     remove_item(name)
#       → Remove the item by name. If not found, print a message.
#
#     get_total()
#       → Return the total cost (price × qty for all items).
#
#     view_cart()
#       → Print a formatted receipt showing all items,
#         their quantities, prices, and the grand total.
#
# Create a cart, add 4 items, remove 1, then print the receipt.

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 9 — OOP (Inheritance)
# ─────────────────────────────────────────────
# Create a base class called Employee with:
#   Attributes: name, employee_id, base_salary
#   Methods:
#     get_info()     → print name, ID, and base salary
#     get_salary()   → return base_salary
#
# Then create TWO child classes that inherit from Employee:
#
#   class FullTimeEmployee(Employee):
#     Extra attribute: department
#     Overrides get_salary() → adds a monthly bonus of Rs. 5,000
#     Overrides get_info()   → also shows department + final salary
#
#   class PartTimeEmployee(Employee):
#     Extra attribute: hours_per_week
#     Overrides get_salary() → salary = base_salary × (hours_per_week / 40)
#     Overrides get_info()   → also shows hours per week + final salary
#
# Create at least 2 full-time and 2 part-time employees.
# Store all 4 in a single list.
# Loop through the list and call get_info() on each.
# At the end, print who earns the most.

# Write your code below:




# ─────────────────────────────────────────────
# QUESTION 10 — OOP (Full Mini Project)
# ─────────────────────────────────────────────
# Build a HOSPITAL APPOINTMENT SYSTEM using OOP.
#
# Create a class called Doctor with:
#   Attributes: name, specialization, fee
#   Method: get_info() → print doctor details
#
# Create a class called Appointment with:
#   Attributes:
#     patient_name
#     doctor         → a Doctor OBJECT (not just a name)
#     date
#     is_confirmed   → starts as False
#   Methods:
#     confirm()      → set is_confirmed = True, print confirmation
#     cancel()       → set is_confirmed = False, print cancellation
#     summary()      → print full details of the appointment
#
# Create a class called Hospital with:
#   Attributes:
#     hospital_name
#     appointments   → empty list
#   Methods:
#     book_appointment(patient_name, doctor, date)
#       → create an Appointment object and add to the list
#     view_all()     → print summary of every appointment
#     count_confirmed() → return how many appointments are confirmed
#
# Demo:
#   1. Create 2 or 3 Doctor objects.
#   2. Create a Hospital object.
#   3. Book 3 or 4 appointments using different doctors.
#   4. Confirm some, cancel some.
#   5. Call view_all() and count_confirmed().

# Write your code below:




# ============================================================
#   END OF CLASS 3 HOMEWORK
#   Submit your completed file to your instructor.
# ============================================================