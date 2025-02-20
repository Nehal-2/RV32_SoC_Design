import serial
import time

def continuous_test():
    try:
        ser = serial.Serial('/dev/ttyUSB1', 9600, timeout=1)
        print(f"Connected to {ser.port}")
        
        count = 0
        while count < 10: 

            test_data = f"Test {count}\n".encode()
            ser.reset_input_buffer()
            ser.reset_output_buffer()
            
            ser.write(test_data)
            ser.flush()
            print(f"Sent: Test {count}")
            
            time.sleep(0.5) 

            start_time = time.time()
            if ser.in_waiting:
                data = ser.read(ser.in_waiting)
                print(f"Received: {data.hex()}")
            else:
                print("No data received")
                
            count += 1
            time.sleep(0.5) 

    except serial.SerialException as e:
        print(f"Error: {e}")
    finally:
        print("Port closed")

# ✅ Fixed "__name__" and "__main__" issue
if __name__ == "__main__":
    continuous_test()

