#
TARGET = skynet

#
CROSS_COMPILE = arm-linux-gnueabihf-
CFLAGS = -static -g -Wall -Wno-unused-value  -I${SOCEDS_DEST_ROOT}/ip/altera/hps/altera_hps/hwlib/include -Ilibev
LDFLAGS =  -g -Wall -lm
CC = $(CROSS_COMPILE)gcc
ARCH= arm

all: build

build: $(TARGET)
$(TARGET): src\main.o src\fpga_interface.o src\motor_driver.o src\line_analyzer.o src\control_loop.o src\camera_control.o src\camera_data.o   
	$(CC) $(LDFLAGS)   $^ -o $@  
%.o : %.c
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.a *.o *~ src/*.o
