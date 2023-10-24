import "DPI-C" function int spdm_sock_init();
import "DPI-C" function int spdm_sock_fini();
import "DPI-C" function int SendPlatformData(input int unsigned Command, input byte unsigned SendBuffer[QEMU_BUF_SIZE - 1:0], input int unsigned BytesToSend);
import "DPI-C" function int ReceivePlatformData(output int unsigned Command[0:0], output byte unsigned ReceiveBuffer[QEMU_BUF_SIZE - 1:0], input int unsigned BytesToReceive);
