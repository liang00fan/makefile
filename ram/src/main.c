#include <stdio.h>
#include <fcntl.h>
#include <linux/ioctl.h>
#include <linux/serial.h>
#include <asm-generic/ioctls.h> /* TIOCGRS485 + TIOCSRS485 ioctl definitions */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <termios.h>
#include <unistd.h>
//#include <linux/pthread.h>
#include <sched.h>

//#include <sys/types.h>
//#include <sys/stat.h>

#include <fcntl.h>
//#include <sys/ioctl.h>

#include <errno.h>

int set_baud(int fd, int baud_rate);
int init_serial(char *path, int baud_rate);

int set_baud(int fd, int baud_rate) {
	struct termios attr;

	if (tcgetattr(fd, &attr) < 0) {
		printf("get serial attribute failed\n");
		return -1;
	}

	cfsetispeed(&attr, baud_rate);
	cfsetospeed(&attr, baud_rate);

	if (tcsetattr(fd, TCSANOW, &attr) < 0) {
		printf("get serial attribute failed\n");
		return -1;
	}

	return 0;
}

int init_serial(char *path, int baud_rate) {
	struct termios attr;
	int fd;

	fd = open(path, O_RDWR);

	if (fd <= 0) {
		printf("open serial %s failed\n", path);
		perror("");
		return -1;
	}
	printf("open serial %s ok\n", path);
	attr.c_cflag = 0;

	if (tcgetattr(fd, &attr) < 0) {
		printf("get serial attribute\n");
		close(fd);
		return -1;
	}
	printf("get attr ok\n", path);
	// Set to 8 bits, not parity 1 stop bit
	cfmakeraw(&attr);
#if 0
	cfsetispeed(&attr, baud_rate);
	cfsetospeed(&attr, baud_rate);

	attr.c_cflag &= ~PARENB;
	attr.c_cflag &= ~CSTOPB;
	attr.c_cflag &= ~CRTSCTS;
	attr.c_cflag |= CS8;
#endif
	cfsetispeed(&attr, baud_rate);
	cfsetospeed(&attr, baud_rate);

	attr.c_cflag &= ~PARENB;
	attr.c_cflag &= ~CSTOPB;
	attr.c_cflag |= CS8;

	if (tcsetattr(fd, 0, &attr) < 0) {
		printf("failed to set serial attribute\n");
		close(fd);
		return -1;
	}
	fcntl(fd, F_SETFL, FNDELAY);

	return fd;
}

union U {
	float v;
	unsigned char c[4];
	unsigned int i;
} uu;

int main(int argc, char **argv) {
	struct serial_rs485 rs485conf;

	char inbuff[256];
	int fd;
	char txtbuf[512];
	char outbuff[256];
	char databuff[256];
	memset(inbuff, 0x0, 256);
	inbuff[0] = 0x01;
	inbuff[1] = 0x03;
	inbuff[2] = 0x00;
	inbuff[3] = 0x00;
	inbuff[4] = 0x00;
	inbuff[5] = 0x08;
	inbuff[6] = 0x44;
	inbuff[7] = 0x0c;

	fd = init_serial(argv[1], B38400);

	if (fd < 0) {
		printf("Initialize the serial port  failed %s\n", argv[1]);
		return -1;
	}

	/* Don't forget to read first the current state of the RS-485 options with ioctl.
	 If You don't do this, You will destroy the rs485conf.delay_rts_last_char_tx
	 parameter which is automatically calculated by the driver when You opens the
	 port device. */
	if (ioctl(fd, TIOCGRS485, &rs485conf) < 0) {
		printf("Error: TIOCGRS485 ioctl not supported.\n");
	}

	/* Enable RS-485 mode: */
	rs485conf.flags |= SER_RS485_ENABLED;

	/* Set rts/txen delay before send, if needed: (in microseconds) */
	rs485conf.delay_rts_before_send = 0;

	/* Set rts/txen delay after send, if needed: (in microseconds) */
	rs485conf.delay_rts_after_send = 0;

	if (ioctl(fd, TIOCSRS485, &rs485conf) < 0) {
		printf("Error: TIOCSRS485 ioctl not supported.\n");
	}

	fcntl(fd, F_SETFL, 0);
	//int n = write(fd, "ABC\r\n", 5);
/////
	while (1) {
		//printf ( "write begin-----11111\r\n");
		memset(outbuff, 0x0, 256);
		memset(databuff, 0x0, 256);
		int n = write(fd, &inbuff[0], 8);
		if (n < 0) {
			/* Error handling */
			//printf ( "write error-----22222\r\n");
			printf("write error \r\n");
		} else
			printf("write data: 01 03 00 00 00 08 44 0C \r\n");
		printf("please input data from pc serial debug assistant! \r\n");
		//printf ( "write ok-----33333\r\n");

		int readnum = read(fd, &outbuff[0], 128);
		int i = 0;
		printf("recv data: ");
		for (i = 0; i < readnum; i++) {
			printf("%02x ", outbuff[i]);
		}
		printf("\r\n");
		//printf ( "read ok-----44444\r\n");
		/*sprintf(databuff, "%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x%x",outbuff[0],outbuff[1],outbuff[2],outbuff[3],outbuff[4],outbuff[5],outbuff[6],outbuff[7],outbuff[8],outbuff[9],outbuff[10],outbuff[11],outbuff[12],outbuff[13],outbuff[14],outbuff[15],outbuff[16],outbuff[17],outbuff[18],outbuff[19],outbuff[20]);
		 printf ( "recv  %s\r\n",databuff);*/

		uu.c[0] = outbuff[8];
		uu.c[1] = outbuff[7];
		uu.c[2] = outbuff[6];
		uu.c[3] = outbuff[5];

		if (outbuff[2] + 1 + 2 + 2 == 21) {
			printf("Temperatur---------------%.2f\n", uu.v);
			printf("Humidity  ---------------%.2f\n",
					(float) (outbuff[9] * 128 + outbuff[10]));
			printf("PM2.5     ---------------%d\n",
					outbuff[11] * 256 + outbuff[12]);
			printf("PM10      ---------------%d\n",
					outbuff[13] * 256 + outbuff[14]);
			printf("CO2       ---------------%d\n",
					outbuff[15] * 256 + outbuff[16]);
			printf("TVOC      ---------------%d\n",
					outbuff[17] * 256 + outbuff[18]);
			printf("\n\n");

			memset(txtbuf, 0, 512);
			/*sprintf(txtbuf, "Temperatur %.2f\nHumidity %.2f\nPM2.5 %d\nPM10 %d\nCO2 %d\nTVOC %d\n\n\n", uu.v,(float)(outbuff[9]*128+outbuff[10]), outbuff[11]*256+outbuff[12], outbuff[13]*256+outbuff[14], outbuff[15]*256+outbuff[16], outbuff[17]*256+outbuff[18]);

			 FILE *pFile = fopen("/1.txt", "w");

			 fwrite (txtbuf, 1, strlen(txtbuf), pFile);
			 fflush(pFile);*/
		}
		sleep(1);
	}
/////

	if (close(fd) < 0) {
		printf("Error: Can't close: %s\n", argv[1]);
	}
}
