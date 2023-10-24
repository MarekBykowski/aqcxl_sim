/**
 * @struct - dma_io_cb
 * @brief	character device io call back book keeping parameters
 */
struct dma_io_cb {
	void *private;
	/** user buffer */
	void *buf;
	/** length of the user buffer */
	size_t len;
	/** page number */
	unsigned int pages_nr;
	/** pages allocated to accommodate the scatter gather list */
	struct page **pages;
	/* physical address of page */
	unsigned long phys_addr;
	int pinned;
} __attribute__((__packed__));

enum dma_cdev_ioctl_cmd {
	SIMPLE_IOCTL_PIN,
	SIMPLE_IOCTL_FREE
};
