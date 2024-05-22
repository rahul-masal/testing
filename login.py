import tkinter as tk
import subprocess

def submit_login():
    # Disable the submit button
    submit_button.config(state=tk.DISABLED)

    entered_username = username_entry.get()
    entered_password = password_entry.get()

    with open('/home/admin/vpn/data.txt', 'r') as file:
        stored_username = file.readline().strip()
        stored_password = file.readline().strip()

    if entered_username == stored_username and entered_password == stored_password:
        message_label.config(text="Login successful!") 
        # print("Login successful!")

        # Run the command
        command = 'xfreerdp /v:10.10.10.242 /f /u:testing /p:"Windows@123" /cert-ignore'
        subprocess.run(command, shell=True)

    else:
        message_label.config(text="Login failed. Incorrect username or password.")
        print("Login failed. Incorrect username or password.")

    # Clear the input fields after submission
    username_entry.delete(0, tk.END)
    password_entry.delete(0, tk.END)

def update_timer(counter):
    timer_label.config(text=f"Timer: {counter} seconds remaining")
    if counter > 0:
        window.after(1000, update_timer, counter - 1)
    else:
        submit_button.config(state=tk.NORMAL)  # Enable the submit button

# Create the main window
window = tk.Tk()
window.title(" ")
window.configure(bg="black")  # Set black background color

# Calculate the desired top margin
top_margin = 19

# Set the window's geometry with a top margin
window.geometry(f"{window.winfo_screenwidth()}x{window.winfo_screenheight()-top_margin}+0+{top_margin}")

# Create labels for space between login and box
username_label = tk.Label(window, text=" ", bg="black", fg="white")
username_label.pack()

# Create labels for Login
username_label = tk.Label(window, text="LOGIN", bg="black", fg="white")
username_label.pack()

# Create labels for space between login and username box
username_label = tk.Label(window, text=" ", bg="black", fg="white")
username_label.pack()

# Create labels for space between login and username box
username_label = tk.Label(window, text=" ", bg="black", fg="white")
username_label.pack()

# Create labels for username and password
username_label = tk.Label(window, text="Username:", bg="black", fg="white")
username_label.pack()

# Create an entry field for username
username_entry = tk.Entry(window)
username_entry.pack()

# Create labels for space between login and username box
username_label = tk.Label(window, text=" ", bg="black", fg="white")
username_label.pack()

password_label = tk.Label(window, text="Password:", bg="black", fg="white")
password_label.pack()

# Create an entry field for password
password_entry = tk.Entry(window, show="*")
password_entry.pack()

# Create labels for space between pass and submit box
username_label = tk.Label(window, text=" ", bg="black", fg="white")
username_label.pack()

# Create a submit button
submit_button = tk.Button(window, text="Submit", command=submit_login, state=tk.DISABLED, bg="blue", fg="white")
submit_button.pack()

# Create a label for displaying the login status message
message_label = tk.Label(window, text="", bg="black", fg="white")
message_label.pack()

# Create a label for displaying the timer
timer_label = tk.Label(window, text="10 seconds remaining", bg="black", fg="white")
timer_label.pack()

# Start the timer
update_timer(30)

# Run the main window's event loop
window.mainloop()
