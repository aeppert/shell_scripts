import tkinter as tk
from tkinter import filedialog, messagebox, simpledialog
import subprocess
import datetime

def convert_to_pcap(start, end, outdir, interval):
    # Conversion logic using the updated script name
    start_timestamp = start.strftime('%Y-%m-%d %H:%M:%S')
    end_timestamp = end.strftime('%Y-%m-%d %H:%M:%S')

    command = f"StenoConversion.sh -s \"{start_timestamp}\" -e \"{end_timestamp}\" -o {outdir} -i {interval}"
    subprocess.run(command, shell=True)

    # Update progress and notify completion not completely functional but..
    messagebox.showinfo("Info", "Conversion Completed")

def select_time_range_and_convert():
    start_time = simpledialog.askstring("Input", "Enter start time (YYYY-MM-DD HH:MM:SS)")
    end_time = simpledialog.askstring("Input", "Enter end time (YYYY-MM-DD HH:MM:SS)")
    output_directory = select_output_directory()
    interval = simpledialog.askinteger("Input", "Enter interval in seconds")

    try:
        start = datetime.datetime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
        end = datetime.datetime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
        convert_to_pcap(start, end, output_directory, interval)
    except ValueError:
        messagebox.showerror("Error", "Invalid date format. Please use YYYY-MM-DD HH:MM:SS")

def select_output_directory():
    directory = filedialog.askdirectory(title="Select Output Directory")
    return directory

# GUI setup
root = tk.Tk()
root.title("Stenographer Middleware")

# Buttons and Widgets
select_time_range_button = tk.Button(root, text="Select Time Range and Convert", command=select_time_range_and_convert)
select_time_range_button.pack()

# Rest of the GUI widgets as needed

# Start GUI
root.mainloop()
