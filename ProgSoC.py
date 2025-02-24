import serial
import time

def transmit_hex_data_with_byte_count(file_path, serial_port, baud_rate=9600, delay=0.05):
    try:
        # Open the serial port connection
        ser = serial.Serial(serial_port, baud_rate, timeout=1)
        print(f"Connected to {ser.port}")

        # Read the hex data from the file
        with open(file_path, 'r') as file:
            hex_lines = file.readlines()
        
        # Calculate the total number of bytes
        total_bytes = len(hex_lines) * 4
        
        # Send the total number of bytes as the first two bytes
        total_bytes_bytes = total_bytes.to_bytes(2, byteorder='little')
        count_index = 1
        for byte in total_bytes_bytes:
            ser.write(byte.to_bytes(1, byteorder='little'))
            ser.flush()
            print(f"Sent count byte [{count_index}]: {hex(byte)}")

            # Listen for a response
            #response = ser.read(1)
            #if response:
            #    print(f"Received response for count byte [{count_index}]: {response.hex()}")
            #else:
            #    print(f"No response for count byte [{count_index}]")

            count_index += 1
            time.sleep(delay)

        # Send each hex data entry
        data_index = 1
        for line in hex_lines:
            hex_value = line.strip()
            if hex_value:
                data_int = int(hex_value, 16)
                data_bytes = data_int.to_bytes(4, byteorder='little')
                for byte in data_bytes:
                    ser.write(byte.to_bytes(1, byteorder='little'))
                    ser.flush()
                    print(f"Sent data byte [{data_index}]: {hex(byte)}")

                    # Listen for a response
                    # response = ser.read(1)
                    # if response:
                    #    print(f"Received response for data byte [{data_index}]: {response.hex()}")
                    #else:
                    #    print(f"No response for data byte [{data_index}]")

                    data_index += 1
                    time.sleep(delay)

        print("All data has been successfully transmitted.")

    except serial.SerialException as e:
        print(f"Serial connection error: {e}")
    except FileNotFoundError:
        print(f"Unable to find the specified file: {file_path}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")
    finally:
        ser.close()
        print("Serial port has been closed.")

if __name__ == "__main__":
    # Path to the file containing hexadecimal data
    file_path = 'inst.mem'
    # Serial port identifier (e.g., '/dev/ttyUSB1' or 'COM3')
    serial_port = '/dev/ttyUSB1'
    transmit_hex_data_with_byte_count(file_path, serial_port)
