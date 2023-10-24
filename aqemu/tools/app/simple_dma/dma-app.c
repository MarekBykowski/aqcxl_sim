#include <errno.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <string.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <memory.h>

#include "simple2.h"

/*
 * EP MMIO registers (BAR0)
 0x0 host buffer physical address (high)
 0x4 host buffer physical address (low)
 0x8 # of DWs
 0xc opcode (0=RD, 1=WR)
 0x10 enable (1=start)
 0x14 done

 Host creates buffer in host memory for EP to target read/write
   - pins pages
   - gets physical address
 Host programs transaction to EP BAR0 memory
 EP DUT waits for 'enable' and then reads transaction and performs command and sets 'done'
 Host polls the done bit in EP DUT and then frees the pages and buffer

*/

#define EP_BAR0 0xc0900000

volatile int *ep_mmap = NULL; /* global variable method*/
int mem_fd;
int simple_fd;

int map_ep() {
	/* open /dev/mem and error checking */
	int i;
	int mem_fd = open("/dev/mem", O_RDWR | O_SYNC);

	if (mem_fd < 0) {
    	printf("Failed to open /dev/mem: %s !\n",strerror(errno));
    	return errno;
	}

	/* mmap() the opened /dev/mem */
	ep_mmap = (int *) (mmap(0, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, EP_BAR0));
	if(ep_mmap ==(void*) -1) {

    	fprintf(stderr,"map_it: Cannot map memory into user space.\n");
    	return errno;
	}
	return 0;
}


int main(int argc, char** argv) {
    int ret;
    char* simple_fd_path= "/dev/simple0";
    struct dma_io_cb* iocb;
    int is_done;
    int poll_cnt = 0;
    char *allocated = NULL;

    printf("GOT TO 1\n");

    /* open simple */
    if ((simple_fd= open(simple_fd_path, O_RDWR)) < 0) {
	printf("Open error loc: %s\n", simple_fd_path);
	printf("Try sudo %s\n", argv[0]);
	exit(0);
    }

    iocb = malloc(sizeof(struct dma_io_cb));
    iocb->len = 4096;
    posix_memalign((void **)&allocated, 4096 /* alignment */, iocb->len + 4096);
    if (!allocated) {
	    printf("OOM %lu.\n", iocb->len + 4096);
	    exit(0);
    }
    iocb->buf = allocated;
    memset(iocb->buf, 1, 8);

    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+1));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+2));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+3));

    /* pin pages and get phys_addr */
    ioctl(simple_fd, SIMPLE_IOCTL_PIN, iocb);
    printf("phys_addr=%lx\n", iocb->phys_addr);
    printf("phys_addrH=%lx\n", iocb->phys_addr >> 32);
    printf("phys_addrL=%lx\n", iocb->phys_addr & 0xFFFFFFFF);

    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+1));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+2));
    printf("buf[0]=%x\n", *((unsigned int *) iocb->buf+3));


    /* open dev/mem */
    map_ep();
    *ep_mmap = iocb->phys_addr >> 32; /* host SPA HIGH */
    *(ep_mmap+1) = iocb->phys_addr & 0xFFFFFFFF;
    *(ep_mmap+2) = 1024; /* # DWs */
    *(ep_mmap+3) = 1; /*write*/
    *(ep_mmap+4) = 1; /*go*/

    is_done = 0;
    while ((is_done != 1) && (poll_cnt < 10)) {
        printf("ep_mmap is %lx, is_done=%x\n", (unsigned long) ep_mmap, is_done);
	sleep(1);
	poll_cnt++;
        is_done = *(ep_mmap+5);
    }
    poll_cnt = 0;
    printf("free pinned %d\n", iocb->pinned);
    ioctl(simple_fd, SIMPLE_IOCTL_FREE, iocb);
    free(iocb);

    /* iocb = malloc(sizeof(struct dma_io_cb)); */
    iocb = malloc(sizeof(struct dma_io_cb));
    iocb->len = 4096;
    posix_memalign((void **)&allocated, 4096 /* alignment */, iocb->len + 4096);
    if (!allocated) {
	    printf("OOM %lu.\n", iocb->len + 4096);
	    exit(0);
    }
    iocb->buf = allocated;

    /* pin pages and get phys_addr */
    ioctl(simple_fd, SIMPLE_IOCTL_PIN, iocb);
    printf("phys_addr=%lx\n", iocb->phys_addr);
    printf("phys_addrH=%lx\n", iocb->phys_addr >> 32);
    printf("phys_addrL=%lx\n", iocb->phys_addr & 0xFFFFFFFF);

    /* open dev/mem */
    *ep_mmap = iocb->phys_addr >> 32; /* host SPA HIGH */
    *(ep_mmap+1) = iocb->phys_addr & 0xFFFFFFFF;
    *(ep_mmap+2) = 1024;
    *(ep_mmap+3) = 0; /*write*/
    *(ep_mmap+4) = 1; /*go*/

    is_done = 0;
    while ((is_done != 1) && (poll_cnt < 10)) {
        printf("ep_mmap is %lx, is_done=%x\n", (unsigned long) ep_mmap, is_done);
	sleep(1);
	poll_cnt++;
        is_done = *(ep_mmap+5);
    }
    poll_cnt = 0;
    printf("free pinned %d\n", iocb->pinned);
    ioctl(simple_fd, SIMPLE_IOCTL_FREE, iocb);
    free(iocb);

    close(mem_fd);
    close(simple_fd);
    exit(0);
}

